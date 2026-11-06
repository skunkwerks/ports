// SEA launcher for the tailwindcss CLI.
//
// Runs before any @tailwindcss code: locates the runtime assets (native
// .node addons + the tailwindcss stylesheet/JS package), exposes a dlopen
// helper for the rewritten native loaders, and points NODE_PATH at the
// asset node_modules so enhanced-resolve can find `@import "tailwindcss"`
// and jiti-loaded user configs can import "tailwindcss/plugin" etc.
//
// Assets come from $TAILWINDCSS_SEA_ASSETS, else the baked-in
// __TWSEA_SYSTEM_DIR__ where the port installs them.  They are NOT embedded
// in the executable and there is no extraction fallback: if the directory is
// missing, this crashes.
//
// __TWSEA_SYSTEM_DIR__ is injected by sea-build.mjs.

import module from 'node:module';
import path from 'node:path';

const assetDir = process.env.TAILWINDCSS_SEA_ASSETS || __TWSEA_SYSTEM_DIR__;

// Let enhanced-resolve (modules: ["node_modules", ...NODE_PATH]) and CJS
// require find the tailwindcss package shipped with the assets.
{
  const nm = path.join(assetDir, 'node_modules');
  process.env.NODE_PATH = process.env.NODE_PATH
    ? nm + path.delimiter + process.env.NODE_PATH
    : nm;
  // The CJS loader snapshots NODE_PATH before this launcher runs; re-read it
  // so require.resolve("tailwindcss/...") also finds the package.
  module.Module._initPaths();
}

// Native addon loader used by the build-time rewrites of
// @tailwindcss/oxide, lightningcss and @parcel/watcher.
const nativeCache = new Map();
globalThis.__TWSEA__ = {
  assetDir,
  native(name) {
    let mod = nativeCache.get(name);
    if (mod === undefined) {
      mod = { exports: {} };
      process.dlopen(mod, path.join(assetDir, 'native', `${name}.node`));
      nativeCache.set(name, mod);
    }
    return mod.exports;
  },
};

// Hand over to the real CLI (bundled by esbuild; the dynamic import keeps
// the setup above ahead of the CLI's top-level await).
await import('__TWSEA_CLI_ENTRY__');
