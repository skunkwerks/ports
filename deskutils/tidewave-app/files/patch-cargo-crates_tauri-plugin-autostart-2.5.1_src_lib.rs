--- cargo-crates/tauri-plugin-autostart-2.5.1/src/lib.rs.orig	2006-07-24 01:21:28 UTC
+++ cargo-crates/tauri-plugin-autostart-2.5.1/src/lib.rs
@@ -222,6 +222,11 @@ impl Builder {
                     builder.set_app_path(&current_exe.display().to_string());
                 }
 
+                // FreeBSD has no AppImage, and `Env` has no `appimage` field there,
+                // so the executable path is always the right autostart target.
+                #[cfg(target_os = "freebsd")]
+                builder.set_app_path(&current_exe.display().to_string());
+
                 app.manage(AutoLaunchManager(
                     builder.build().map_err(|e| e.to_string())?,
                 ));
