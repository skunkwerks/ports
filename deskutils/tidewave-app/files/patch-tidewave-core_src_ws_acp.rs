--- tidewave-core/src/ws/acp.rs.orig	2026-09-15 10:01:27 UTC
+++ tidewave-core/src/ws/acp.rs
@@ -223,6 +223,11 @@ pub struct TidewaveExitParams {
     pub stderr: Option<String>,
 }
 
+#[cfg(target_os = "freebsd")]
+pub const FREEBSD_ACP_HINT: &str = "On FreeBSD, install the port misc/claude-agent-acp \
+     (pkg install claude-agent-acp), or set TIDEWAVE_CLAUDE_AGENT_ACP_EXECUTABLE \
+     to a custom executable.";
+
 #[derive(Debug, Clone)]
 pub struct AgentExitEvent {
     pub error: String,
@@ -1834,7 +1839,16 @@ async fn start_acp_process(process_state: Arc<ProcessS
                                     ("process_exit", format!("ACP process exited with code {}", s.code().unwrap_or(0)))
                                 } else {
                                     debug!("Process exited with status: {}", s);
-                                    ("process_exit", format!("ACP process exited with code {}", s.code().unwrap_or(-1)))
+                                    #[cfg_attr(not(target_os = "freebsd"), allow(unused_mut))]
+                                    let mut message = format!("ACP process exited with code {}", s.code().unwrap_or(-1));
+                                    // 127 is the shell's "command not found"
+                                    #[cfg(target_os = "freebsd")]
+                                    if s.code() == Some(127)
+                                        && process_state_exit.spawn_opts.command.contains("claude-agent-acp")
+                                    {
+                                        message = format!("{}. {}", message, FREEBSD_ACP_HINT);
+                                    }
+                                    ("process_exit", message)
                                 }
                             }
                             Err(e) => {
