--- maki-lua/src/lib.rs.orig	2026-10-17 11:44:48 UTC
+++ maki-lua/src/lib.rs
@@ -1,3 +1,16 @@
+// Luau raises Lua errors as C++ exceptions, and they unwind through mlua's
+// Rust callbacks on the way to Luau's catch. Under panic=abort rustc marks
+// those frames nounwind, so the throw never reaches the catch and a plain
+// Lua error from any plugin aborts the whole process. Packagers sometimes
+// turn this on through CARGO_PROFILE_RELEASE_PANIC, which beats Cargo.toml,
+// so we stop the build here instead of shipping a binary that crashes.
+#[cfg(panic = "abort")]
+compile_error!(
+    "maki-lua must be built with panic = \"unwind\": Luau errors are C++ exceptions \
+     that unwind through Rust frames. Drop CARGO_PROFILE_RELEASE_PANIC=abort, or pass \
+     --config 'profile.release.panic=\"unwind\"' to cargo, which wins over the env var."
+);
+
 pub mod agent_autocmd;
 mod api;
 mod background;
