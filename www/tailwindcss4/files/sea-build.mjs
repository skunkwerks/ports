// Build a single-file tailwindcss executable (node SEA) from an installed
// @tailwindcss/cli npm tree.  Must be run by www/node26-sea: injection uses
// process.execPath, and that interpreter is linked with the spare program
// header slots its --build-sea appends the blob into.  A stock node cannot
// be used here; it rewrites the whole binary with LIEF, which grew n_namesz
// of foreign ELF notes and hid the FreeBSD ABI-tag/feature notes from the
// kernel and rtld.
//
// Environment
//   TWSEA_TREE        node_modules root containing @tailwindcss/cli and
//                     @parcel/watcher            [/usr/local/lib/node_modules]
//   TWSEA_OUT         output directory           [./dist]
//   TWSEA_SYSTEM_DIR  baked-in asset directory the launcher reads at runtime
//                     (required; there is no fallback)
//
// esbuild and sea-launcher.mjs are resolved relative to this script.
//
// Outputs in TWSEA_OUT:
//   tailwindcss       the single-file executable
//   assets/           the runtime assets in their on-disk layout; MUST be
//                     installed at TWSEA_SYSTEM_DIR or the binary crashes

import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const esbuild = createRequire(import.meta.url)('esbuild');

// path.resolve: WRKDIRPREFIX can leave a doubled slash (/tmp//usr/ports/...)
// which esbuild normalizes away in onLoad paths.  The rewrite keys below are
// built from TREE and must match what esbuild reports, or the native require()s
// get bundled as .node files and the build fails.
const TREE = path.resolve(process.env.TWSEA_TREE || '/usr/local/lib/node_modules');
const OUT = path.resolve(process.env.TWSEA_OUT || 'dist');
const SYSTEM_DIR = process.env.TWSEA_SYSTEM_DIR;
if (!SYSTEM_DIR) throw new Error("TWSEA_SYSTEM_DIR is required: the launcher has no fallback");

const CLI = `${TREE}/@tailwindcss/cli`;
const NM = `${CLI}/node_modules`;
const WATCHER = `${TREE}/@parcel/watcher`;

const version = JSON.parse(fs.readFileSync(`${CLI}/package.json`, 'utf8')).version;

// ---------------------------------------------------------------------------
// Locate the native addons in the tree (names differ per arch).
function findOne(dir, pattern) {
  const hits = fs.readdirSync(dir).filter((f) => pattern.test(f));
  if (hits.length !== 1) {
    throw new Error(`expected exactly one ${pattern} in ${dir}, got: ${hits}`);
  }
  return path.join(dir, hits[0]);
}
const oxidePkgDir = findOne(`${NM}/@tailwindcss`, /^oxide-freebsd-/);
const lcssPkgDir = findOne(NM, /^lightningcss-freebsd-/);
const natives = {
  oxide: findOne(oxidePkgDir, /\.node$/),
  lightningcss: findOne(lcssPkgDir, /\.node$/),
  watcher: `${WATCHER}/build/Release/watcher.node`,
};

// ---------------------------------------------------------------------------
// Assets: [runtime-relative path, source path].
const assets = [];
for (const [name, src] of Object.entries(natives)) {
  fs.accessSync(src);
  assets.push([`native/${name}.node`, src]);
}
// The upstream licences travel with the blobs they cover; on aarch64 the
// port installs them into the arm64 package dirs it creates.
const licenses = {
  oxide: `${oxidePkgDir}/LICENSE`,
  lightningcss: `${lcssPkgDir}/LICENSE`,
  watcher: `${WATCHER}/LICENSE`,
};
for (const [name, src] of Object.entries(licenses)) {
  fs.accessSync(src);
  assets.push([`native/${name}.LICENSE`, src]);
}
// The whole tailwindcss package: the CSS that `@import "tailwindcss"`
// resolves, plus the JS API (tailwindcss/plugin, /colors, ...) that user
// configs and plugins import at runtime via jiti.
(function walk(dir, rel) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const src = path.join(dir, e.name);
    const r = rel ? `${rel}/${e.name}` : e.name;
    if (e.isDirectory()) walk(src, r);
    else if (e.isFile()) assets.push([`node_modules/tailwindcss/${r}`, src]);
  }
})(`${NM}/tailwindcss`, '');

// ---------------------------------------------------------------------------
// Rewrites of the three platform-binding loaders.
const rewrites = {
  [`${NM}/@tailwindcss/oxide/index.js`]: () =>
    `module.exports = globalThis.__TWSEA__.native('oxide');\n`,

  [`${NM}/lightningcss/node/index.js`]: (src) => {
    const block = /let native;\ntry \{\n  native = require\(`lightningcss-\$\{parts\.join\('-'\)\}`\);\n\} catch \(err\) \{\n  native = require\(`\.\.\/lightningcss\.\$\{parts\.join\('-'\)\}\.node`\);\n\}/;
    if (!block.test(src)) throw new Error('lightningcss native-loader block not found');
    return src.replace(block, `let native = globalThis.__TWSEA__.native('lightningcss');`);
  },

  [`${WATCHER}/index.js`]: () => `
const {createWrapper} = require('./wrapper');
const wrapper = createWrapper(globalThis.__TWSEA__.native('watcher'));
exports.writeSnapshot = wrapper.writeSnapshot;
exports.getEventsSince = wrapper.getEventsSince;
exports.subscribe = wrapper.subscribe;
exports.unsubscribe = wrapper.unsubscribe;
`,
};

// Stock Phoenix / daisyUI setups reference extensionless plugin ids
// (`@plugin "daisyui/packages/bundle/daisyui-theme"`) whose target may exist
// only as .mjs, but upstream's JS resolvers probe only .js/.json/.node/.ts
// (packages/@tailwindcss-node/src/compile.ts).  Append .mjs/.cjs so those
// resolve too.
const extensionsRe =
  /extensions:\s*\[\s*(['"])\.js\1,\s*(['"])\.json\2,\s*(['"])\.node\3,\s*(['"])\.ts\4\s*\]/g;
let extensionsPatched = 0;

// A plugin bundled as CJS by esbuild exports {__esModule:true, default:fn}, so
// upstream's `module: m.default ?? m` hands tailwind the wrapper rather than the
// plugin and it reports `does not accept options`.  daisyUI ships such a bundle,
// both in deps/daisyui/packages/bundle and Elixir's phx.new vendored copy.
// Unwrap the extra default the way an ESM importer would.
const interopRe = /module:\s*([A-Za-z_$][A-Za-z0-9_$]*)\.default\s*\?\?\s*\1\b/g;
let interopPatched = 0;

const seen = new Set();
const rewritePlugin = {
  name: 'twsea-rewrites',
  setup(build) {
    // The launcher hands over to the CLI through this virtual specifier.
    build.onResolve({ filter: /^__TWSEA_CLI_ENTRY__$/ }, () => ({
      path: `${CLI}/dist/index.mjs`,
    }));
    // jiti's default entry lazily require()s ../dist/babel.cjs, which a
    // bundler can't follow; jiti ships lib/jiti-static.mjs (same API,
    // static imports) exactly for single-binary builds.
    build.onResolve({ filter: /^jiti$/ }, () => ({
      path: `${NM}/jiti/lib/jiti-static.mjs`,
    }));
    build.onLoad({ filter: /(index\.js)$/ }, (args) => {
      const rewrite = rewrites[path.resolve(args.path)];
      if (!rewrite) return null;
      seen.add(path.resolve(args.path));
      const src = fs.readFileSync(args.path, 'utf8');
      return { contents: rewrite(src), loader: 'js', resolveDir: path.dirname(args.path) };
    });
    build.onLoad({ filter: /@tailwindcss\/node\/dist\/[^\/]+\.m?js$/ }, (args) => {
      const src = fs.readFileSync(args.path, 'utf8');
      let out = src.replace(extensionsRe, (m) => {
        extensionsPatched++;
        return `${m.slice(0, -1)}, ".mjs", ".cjs"]`;
      });
      out = out.replace(interopRe, (m, id) => {
        interopPatched++;
        return `module:(m=>m&&m.__esModule&&"default" in m?m.default:m)(${id}.default??${id})`;
      });
      if (out === src) return null;
      return { contents: out, loader: 'js', resolveDir: path.dirname(args.path) };
    });
  },
};

// ---------------------------------------------------------------------------
fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });

// CJS deps in an ESM bundle need require/__filename/__dirname; in a SEA,
// import.meta.url may not be a file: URL, so fall back to the executable.
const banner = `
import { createRequire as __twsea_cr } from 'node:module';
import { fileURLToPath as __twsea_f2p, pathToFileURL as __twsea_p2f } from 'node:url';
import { dirname as __twsea_dn } from 'node:path';
const __twsea_url = (typeof import.meta.url === 'string' && import.meta.url.startsWith('file:'))
  ? import.meta.url : __twsea_p2f(process.execPath).href;
const require = __twsea_cr(__twsea_url);
const __filename = __twsea_f2p(__twsea_url);
const __dirname = __twsea_dn(__filename);
`;

await esbuild.build({
  entryPoints: [path.join(HERE, 'sea-launcher.mjs')],
  outfile: `${OUT}/bundle.mjs`,
  bundle: true,
  platform: 'node',
  format: 'esm',
  target: 'node26',
  banner: { js: banner },
  // Dead branch on node >= 22.15 (module.registerHooks exists); leaving it
  // external keeps esbuild from trying to bundle the loader file.
  external: ['@tailwindcss/node/esm-cache-loader'],
  define: {
    __TWSEA_SYSTEM_DIR__: JSON.stringify(SYSTEM_DIR),
  },
  plugins: [rewritePlugin],
  logLevel: 'warning',
});

for (const p of Object.keys(rewrites)) {
  if (!seen.has(p)) throw new Error(`rewrite never applied: ${p}`);
}
// one esm + one cjs resolver; anything else means upstream changed the list
if (extensionsPatched !== 2) {
  throw new Error(`resolver extensions patch applied ${extensionsPatched} times, expected 2`);
}
// two plugin-load sites in the same resolver file, as for the extensions above
if (interopPatched !== 2) {
  throw new Error(`CJS default unwrap applied ${interopPatched} times, expected 2`);
}

// Stage the assets in their runtime layout, for the port to install at
// SYSTEM_DIR.  They are deliberately not embedded in the executable.
const staging = `${OUT}/assets`;
for (const [rel, src] of assets) {
  const dest = path.join(staging, rel);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

const seaConfig = {
  main: `${OUT}/bundle.mjs`,
  mainFormat: 'module',
  output: `${OUT}/tailwindcss`,
  disableExperimentalSEAWarning: true,
  useCodeCache: true,
};
fs.writeFileSync(`${OUT}/sea-config.json`, JSON.stringify(seaConfig, null, 2));

execFileSync(process.execPath, ['--build-sea', `${OUT}/sea-config.json`], { stdio: 'inherit' });
fs.chmodSync(`${OUT}/tailwindcss`, 0o755);

const size = fs.statSync(`${OUT}/tailwindcss`).size;
console.log(`built ${OUT}/tailwindcss (${(size / 1024 / 1024).toFixed(1)} MB, tailwindcss ${version}, ${process.platform}-${process.arch})`);
