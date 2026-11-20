--- tidewave-core/src/server.rs.orig	2026-10-30 21:48:45 UTC
+++ tidewave-core/src/server.rs
@@ -1184,11 +1184,26 @@ async fn open_handler(Json(payload): Json<OpenParams>)
                     .spawn()
             }
         }
+        #[cfg(target_os = "freebsd")]
+        {
+            let open_path = if path.is_file() {
+                path.parent()
+                    .map(|p| p.to_string_lossy().into_owned())
+                    .unwrap_or(payload.path.clone())
+            } else {
+                payload.path.clone()
+            };
+            crate::command::command_with_limited_env("xdg-open")
+                .arg(&open_path)
+                .spawn()
+        }
     } else {
         #[cfg(target_os = "macos")]
         let program = "open";
         #[cfg(target_os = "linux")]
         let program = "xdg-open";
+        #[cfg(target_os = "freebsd")]
+        let program = "xdg-open";
         #[cfg(target_os = "windows")]
         let program = "explorer.exe";
 
@@ -1436,12 +1451,41 @@ async fn shell_env_handler(Json(params): Json<ShellEnv
 
 async fn shell_env_handler(Json(params): Json<ShellEnvParams>) -> Json<ShellEnvResponse> {
     match crate::shell_env::capture_shell_env(&params.path, params.wsl_distro.as_deref()).await {
-        Ok(env) => Json(ShellEnvResponse::ShellEnvResponseOk { success: true, env }),
+        #[cfg_attr(not(target_os = "freebsd"), allow(unused_mut))]
+        Ok(mut env) => {
+            #[cfg(target_os = "freebsd")]
+            freebsd_set_acp_executable(&mut env);
+            Json(ShellEnvResponse::ShellEnvResponseOk { success: true, env })
+        }
         Err(error) => Json(ShellEnvResponse::ShellEnvResponseErr {
             success: false,
             error,
         }),
     }
+}
+
+/// The client only knows how to download claude-agent-acp for platforms that
+/// Bun supports, so on FreeBSD point it at the binary installed by the
+/// misc/claude-agent-acp port unless the user has already chosen one, either
+/// in their shell or in the environment the CLI was started with.
+#[cfg(target_os = "freebsd")]
+fn freebsd_set_acp_executable(env: &mut HashMap<String, String>) {
+    const VAR: &str = "TIDEWAVE_CLAUDE_AGENT_ACP_EXECUTABLE";
+    const DEFAULT: &str = "/usr/local/bin/claude-agent-acp";
+
+    if env.contains_key(VAR) {
+        return;
+    }
+
+    let executable = env::var(VAR).unwrap_or_else(|_| DEFAULT.to_string());
+
+    if !Path::new(&executable).is_file() {
+        error!("{} not found. {}", executable, crate::ws::acp::FREEBSD_ACP_HINT);
+    }
+
+    // Set it even when missing, so the client fails to spawn it and reports
+    // the hint, rather than attempting an unsupported download.
+    env.insert(VAR.to_string(), executable);
 }
 
 fn tidewave_cache_dir() -> String {
