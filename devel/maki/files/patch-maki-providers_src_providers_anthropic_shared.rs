--- maki-providers/src/providers/anthropic/shared.rs.orig	2026-10-17 11:44:48 UTC
+++ maki-providers/src/providers/anthropic/shared.rs
@@ -231,6 +231,16 @@ fn wire_block<'a>(
     block: &'a ContentBlock,
     unreferenced: &mut HashSet<&str>,
 ) -> (WireBlock<'a>, Option<Value>) {
+    // Sessions saved before the parser forced an object can still hold a
+    // null input, and the API rejects the whole request over it.
+    if let ContentBlock::ToolUse {
+        id, name, input, ..
+    } = block
+        && !input.is_object()
+    {
+        let fixed = json!({"type": "tool_use", "id": id, "name": name, "input": {}});
+        return (WireBlock::Rebuilt(fixed), None);
+    }
     let ContentBlock::ToolResult {
         tool_use_id,
         content,
@@ -516,11 +526,15 @@ impl EventParser {
                 if let Some(ContentBlock::ToolUse { name, input, .. }) =
                     self.content_blocks.get_mut(self.current_block_idx)
                 {
-                    *input = match serde_json::from_str(&self.current_tool_json) {
-                        Ok(v) => {
+                    *input = match serde_json::from_str::<Value>(&self.current_tool_json) {
+                        Ok(v) if v.is_object() => {
                             debug!(tool = %name, json = %self.current_tool_json, "tool input JSON");
                             v
                         }
+                        Ok(_) => {
+                            warn!(json = %self.current_tool_json, "tool input is not an object, falling back to {{}}");
+                            Value::Object(Default::default())
+                        }
                         Err(e) => {
                             warn!(error = %e, json = %self.current_tool_json, "malformed tool JSON, falling back to {{}}");
                             Value::Object(Default::default())
@@ -579,7 +593,17 @@ impl EventParser {
         Ok(ControlFlow::Continue(()))
     }
 
-    pub fn finish(self) -> StreamResponse {
+    /// A stream cut before `content_block_stop` leaves the open tool call
+    /// with its placeholder null input, which the API refuses on replay.
+    pub fn finish(mut self) -> StreamResponse {
+        for block in &mut self.content_blocks {
+            if let ContentBlock::ToolUse { input, .. } = block
+                && !input.is_object()
+            {
+                warn!("tool input never completed, falling back to {{}}");
+                *input = Value::Object(Default::default());
+            }
+        }
         StreamResponse {
             message: Message {
                 role: Role::Assistant,
