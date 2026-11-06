// Build a single-file claude-agent-acp executable (node SEA) from an installed
// @agentclientprotocol/claude-agent-acp npm tree.  Must be run by
// www/node26-sea: injection uses process.execPath, and that interpreter is
// linked with the spare program header slots its --build-sea appends the blob
// into.  A stock node cannot be used here; it rewrites the whole binary with
// LIEF, which grew n_namesz of foreign ELF notes and hid the FreeBSD ABI-tag
// and feature notes from the kernel and rtld.
//
// Unlike www/tailwindcss4 there are no native addons and nothing is read from
// disk at runtime: the whole dependency closure is JavaScript, so it all goes
// into the blob and the port installs exactly one file.
//
// Environment
//   CAACP_TREE    node_modules root containing @agentclientprotocol/claude-agent-acp
//                                            [/usr/local/lib/node_modules]
//   CAACP_OUT     output directory           [./dist]
//   CAACP_CLAUDE  Claude Code executable baked in as the default when
//                 $CLAUDE_CODE_EXECUTABLE is unset (required; no fallback)
//
// esbuild is resolved relative to this script.
//
// Outputs in CAACP_OUT:
//   claude-agent-acp   the single-file executable, no runtime assets

import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';

const esbuild = createRequire(import.meta.url)('esbuild');

// path.resolve: WRKDIRPREFIX can leave a doubled slash (/tmp//usr/ports/...)
// which esbuild normalizes away in onLoad paths.  The rewrite key below is
// built from TREE and must match what esbuild reports.
const TREE = path.resolve(process.env.CAACP_TREE || '/usr/local/lib/node_modules');
const OUT = path.resolve(process.env.CAACP_OUT || 'dist');
const CLAUDE = process.env.CAACP_CLAUDE;
if (!CLAUDE) {
  throw new Error('CAACP_CLAUDE is required: the bundle has no fallback claude path');
}

const PKG = `${TREE}/@agentclientprotocol/claude-agent-acp`;
const ENTRY = `${PKG}/dist/index.js`;
const AGENT = path.resolve(`${PKG}/dist/acp-agent.js`);

const version = JSON.parse(fs.readFileSync(`${PKG}/package.json`, 'utf8')).version;

// ---------------------------------------------------------------------------
// The one rewrite.  Upstream resolves the Claude Code CLI from platform-gated
// optional dependencies of @anthropic-ai/claude-agent-sdk, which exist only for
// linux, darwin and win32; on FreeBSD it throws.  Bake in misc/claude-code's
// wrapper as the default and keep $CLAUDE_CODE_EXECUTABLE as the override.
//
// Replacing the whole function, not just its head, also removes the
// `import.meta.resolve(...)` of a bare specifier, which cannot work inside a
// bundle.  The lazy match ends at the first `}` in column 0, i.e. this
// function's own closing brace: everything nested is indented.
const CLI_PATH_RE = /export async function claudeCliPath\(\) \{[\s\S]*?\n\}\n/;
let cliPathPatched = 0;

const rewritePlugin = {
  name: 'caacp-rewrites',
  setup(build) {
    build.onLoad({ filter: /acp-agent\.js$/ }, (args) => {
      if (path.resolve(args.path) !== AGENT) return null;
      const src = fs.readFileSync(args.path, 'utf8');
      if (!CLI_PATH_RE.test(src)) throw new Error('claudeCliPath() not found in ' + args.path);
      const out = src.replace(CLI_PATH_RE, () => {
        cliPathPatched++;
        return `export async function claudeCliPath() {\n` +
          `    return process.env.CLAUDE_CODE_EXECUTABLE || __CAACP_CLAUDE__;\n}\n`;
      });
      return { contents: out, loader: 'js', resolveDir: path.dirname(args.path) };
    });
  },
};

// ---------------------------------------------------------------------------
fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });

// CJS deps in an ESM bundle need require/__filename/__dirname.  In a SEA
// import.meta.url is not a file: URL, so derive one from the executable and
// hand it to every consumer, our own banner and the Anthropic SDK's
// createRequire(import.meta.url) alike (see the define below).
const banner = `
import { createRequire as __caacp_cr } from 'node:module';
import { fileURLToPath as __caacp_f2p, pathToFileURL as __caacp_p2f } from 'node:url';
import { dirname as __caacp_dn } from 'node:path';
const __caacp_url = __caacp_p2f(process.execPath).href;
const require = __caacp_cr(__caacp_url);
const __filename = __caacp_f2p(__caacp_url);
const __dirname = __caacp_dn(__filename);
`;

await esbuild.build({
  entryPoints: [ENTRY],
  outfile: `${OUT}/bundle.mjs`,
  bundle: true,
  platform: 'node',
  format: 'esm',
  target: 'node26',
  banner: { js: banner },
  define: {
    __CAACP_CLAUDE__: JSON.stringify(CLAUDE),
    'import.meta.url': '__caacp_url',
  },
  plugins: [rewritePlugin],
  logLevel: 'warning',
});

if (cliPathPatched !== 1) {
  throw new Error(`claudeCliPath rewrite applied ${cliPathPatched} times, expected 1`);
}

// Nothing may reach outside the blob at runtime: the package ships no native
// addons and the port installs no assets, so either of these in the output
// means an upstream change we have to handle rather than silently ship.
const bundle = fs.readFileSync(`${OUT}/bundle.mjs`, 'utf8');
if (bundle.includes('import.meta.resolve')) {
  throw new Error('bundle still contains import.meta.resolve');
}
if (/require\((['"`])[^'"`]*\.node\1\)|\.node['"`]\s*\)/.test(bundle)) {
  throw new Error('bundle references a native .node addon');
}

const seaConfig = {
  main: `${OUT}/bundle.mjs`,
  mainFormat: 'module',
  output: `${OUT}/claude-agent-acp`,
  disableExperimentalSEAWarning: true,
  useCodeCache: true,
};
fs.writeFileSync(`${OUT}/sea-config.json`, JSON.stringify(seaConfig, null, 2));

execFileSync(process.execPath, ['--build-sea', `${OUT}/sea-config.json`], { stdio: 'inherit' });
fs.chmodSync(`${OUT}/claude-agent-acp`, 0o755);

const size = fs.statSync(`${OUT}/claude-agent-acp`).size;
console.log(`built ${OUT}/claude-agent-acp (${(size / 1024 / 1024).toFixed(1)} MB, ` +
  `claude-agent-acp ${version}, claude ${CLAUDE}, ${process.platform}-${process.arch})`);
