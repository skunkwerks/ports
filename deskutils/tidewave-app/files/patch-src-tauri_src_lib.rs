--- src-tauri/src/lib.rs.orig	2026-09-15 10:01:27 UTC
+++ src-tauri/src/lib.rs
@@ -9,8 +9,9 @@ use tauri_plugin_dialog::{DialogExt, MessageDialogButt
 use tauri_plugin_autostart::ManagerExt;
 use tauri_plugin_cli::CliExt;
 use tauri_plugin_dialog::{DialogExt, MessageDialogButtons, MessageDialogKind};
-#[cfg(not(target_os = "linux"))]
+#[cfg(not(any(target_os = "linux", target_os = "freebsd")))]
 use tauri_plugin_opener::OpenerExt;
+#[cfg(not(target_os = "freebsd"))]
 use tauri_plugin_updater::UpdaterExt;
 use tracing::{debug, error, info};
 use tracing_subscriber::filter::LevelFilter;
@@ -47,13 +48,23 @@ pub fn run() {
 "#;
 
 pub fn run() {
-    tauri::Builder::default()
-        .plugin(tauri_plugin_updater::Builder::new().build())
+    let builder = tauri::Builder::default()
         .plugin(tauri_plugin_cli::init())
-        .plugin(tauri_plugin_dialog::init())
-        .plugin(tauri_plugin_single_instance::init(|_app, args, _cwd| {
-            debug!("a new app instance was opened with {args:?} and the deep link event was already triggered");
-        }))
+        .plugin(tauri_plugin_dialog::init());
+
+    // No AppImage or deb on FreeBSD, and a ported app is updated by pkg, not by
+    // itself, so the updater is left out entirely there.
+    #[cfg(not(target_os = "freebsd"))]
+    let builder = builder.plugin(tauri_plugin_updater::Builder::new().build());
+
+    // tauri-plugin-single-instance is only declared for these targets in Cargo.toml,
+    // and is linux/macos/windows-only internally, so it is unavailable on FreeBSD.
+    #[cfg(any(target_os = "macos", windows, target_os = "linux"))]
+    let builder = builder.plugin(tauri_plugin_single_instance::init(|_app, args, _cwd| {
+        debug!("a new app instance was opened with {args:?} and the deep link event was already triggered");
+    }));
+
+    builder
         .plugin(tauri_plugin_autostart::init(
             tauri_plugin_autostart::MacosLauncher::LaunchAgent,
             None,
@@ -163,12 +174,16 @@ pub fn run() {
             let is_autostart = app.autolaunch().is_enabled().unwrap_or(false);
             let launch_at_login_i = CheckMenuItem::with_id(app, "launch_at_login", "Launch at Login", true, is_autostart, None::<&str>)?;
             let view_logs_i = MenuItem::with_id(app, "view_logs", "View Logs", true, maybe_hotkey("Command+L"))?;
+            #[cfg(not(target_os = "freebsd"))]
             let check_for_updates_i = MenuItem::with_id(app, "check_for_updates", "Check for Updates…", true, None::<&str>)?;
             let restart_i = MenuItem::with_id(app, "restart", "Restart", true, None::<&str>)?;
             let separator = PredefinedMenuItem::separator(app)?;
             let separator2 = PredefinedMenuItem::separator(app)?;
             let quit_i = MenuItem::with_id(app, "quit", "Quit Tidewave IDE", true, maybe_hotkey("Command+Q"))?;
+            #[cfg(not(target_os = "freebsd"))]
             let menu = Menu::with_items(app, &[&open_tidewave_i, &separator, &open_config_i, &view_logs_i, &separator2, &launch_at_login_i, &check_for_updates_i, &restart_i, &quit_i])?;
+            #[cfg(target_os = "freebsd")]
+            let menu = Menu::with_items(app, &[&open_tidewave_i, &separator, &open_config_i, &view_logs_i, &separator2, &launch_at_login_i, &restart_i, &quit_i])?;
 
             let launch_at_login_item = launch_at_login_i.clone();
             TrayIconBuilder::new()
@@ -233,6 +248,7 @@ pub fn run() {
                         }
                     }
                 }
+                #[cfg(not(target_os = "freebsd"))]
                 "check_for_updates" => {
                     check_for_updates(app.clone());
                 }
@@ -242,12 +258,15 @@ pub fn run() {
             })
             .build(app)?;
 
-            let app_handle_for_updates = app.handle().clone();
-            tauri::async_runtime::spawn(async move {
-                if let Err(e) = check_for_updates_on_boot(app_handle_for_updates).await {
-                    error!("Failed to check for updates on boot: {}", e);
-                }
-            });
+            #[cfg(not(target_os = "freebsd"))]
+            {
+                let app_handle_for_updates = app.handle().clone();
+                tauri::async_runtime::spawn(async move {
+                    if let Err(e) = check_for_updates_on_boot(app_handle_for_updates).await {
+                        error!("Failed to check for updates on boot: {}", e);
+                    }
+                });
+            }
 
             Ok(())
         }))
@@ -300,7 +319,7 @@ fn has_pwa_handler() -> bool {
         matches!(output, Ok(o) if o.status.success())
     }
 
-    #[cfg(target_os = "linux")]
+    #[cfg(any(target_os = "linux", target_os = "freebsd"))]
     {
         let output = command_with_limited_env("xdg-mime")
             .args(["query", "default", "x-scheme-handler/web+tidewave"])
@@ -322,14 +341,14 @@ fn open_tidewave(app: &tauri::AppHandle, port: u16, ht
         }
     };
 
-    #[cfg(target_os = "linux")]
+    #[cfg(any(target_os = "linux", target_os = "freebsd"))]
     let result = command_with_limited_env("xdg-open")
         .arg(&url)
         .spawn()
         .map(|_| ())
         .map_err(|e| e.to_string());
 
-    #[cfg(not(target_os = "linux"))]
+    #[cfg(not(any(target_os = "linux", target_os = "freebsd")))]
     let result = app
         .opener()
         .open_url(&url, None::<&str>)
@@ -366,7 +385,7 @@ fn open_config_file(app: &tauri::AppHandle) -> Result<
             .spawn()?;
     }
 
-    #[cfg(target_os = "linux")]
+    #[cfg(any(target_os = "linux", target_os = "freebsd"))]
     {
         let _ = app;
         command_with_limited_env("xdg-open")
@@ -383,6 +402,7 @@ fn open_config_file(app: &tauri::AppHandle) -> Result<
     Ok(())
 }
 
+#[cfg(not(target_os = "freebsd"))]
 async fn check_for_updates_on_boot(app: tauri::AppHandle) -> tauri_plugin_updater::Result<()> {
     if let Some(update) = app.updater()?.check().await? {
         let should_install = app
@@ -416,6 +436,7 @@ async fn check_for_updates_on_boot(app: tauri::AppHand
     Ok(())
 }
 
+#[cfg(not(target_os = "freebsd"))]
 fn check_for_updates(app: tauri::AppHandle) {
     tauri::async_runtime::spawn(async move {
         match check_for_updates_async(app.clone()).await {
@@ -432,6 +453,7 @@ fn check_for_updates(app: tauri::AppHandle) {
     });
 }
 
+#[cfg(not(target_os = "freebsd"))]
 async fn check_for_updates_async(app: tauri::AppHandle) -> tauri_plugin_updater::Result<()> {
     if let Some(update) = app.updater()?.check().await? {
         let should_install = app
@@ -572,13 +594,13 @@ fn open_log_file(app: &tauri::AppHandle) {
 
 fn open_log_file(app: &tauri::AppHandle) {
     if let Some(log_state) = app.try_state::<LogState>() {
-        #[cfg(target_os = "linux")]
+        #[cfg(any(target_os = "linux", target_os = "freebsd"))]
         {
             let _ = command_with_limited_env("xdg-open")
                 .arg(log_state.log_path.display().to_string())
                 .spawn();
         }
-        #[cfg(not(target_os = "linux"))]
+        #[cfg(not(any(target_os = "linux", target_os = "freebsd")))]
         {
             let _ = app
                 .opener()
@@ -587,7 +609,7 @@ fn open_log_file(app: &tauri::AppHandle) {
     }
 }
 
-#[cfg(target_os = "linux")]
+#[cfg(any(target_os = "linux", target_os = "freebsd"))]
 fn command_with_limited_env(program: &str) -> std::process::Command {
     let mut cmd = std::process::Command::new(program);
     tidewave_core::cleanup_appimage_env(&mut cmd);
