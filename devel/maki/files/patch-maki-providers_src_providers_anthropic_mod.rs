--- maki-providers/src/providers/anthropic/mod.rs.orig	2026-10-23 21:07:12 UTC
+++ maki-providers/src/providers/anthropic/mod.rs
@@ -1165,6 +1165,36 @@ data: {\"type\":\"message_delta\",\"usage\":{\"output_
         })
     }
 
+    #[test_case("" ; "stream_ends_before_block_stop")]
+    #[test_case("event: content_block_delta\n\
+data: {\"type\":\"content_block_delta\",\"index\":0,\"delta\":{\"type\":\"input_json_delta\",\"partial_json\":\"\\\"ls\\\"\"}}\n\
+\n\
+event: content_block_stop\n\
+data: {\"type\":\"content_block_stop\"}\n" ; "input_is_not_an_object")]
+    fn parse_sse_tool_use_input_is_always_an_object(tail: &str) {
+        smol::block_on(async {
+            let sse_data = format!(
+                "\
+event: message_start\n\
+data: {{\"type\":\"message_start\",\"message\":{{\"usage\":{{\"input_tokens\":10}}}}}}\n\
+\n\
+event: content_block_start\n\
+data: {{\"type\":\"content_block_start\",\"index\":0,\"content_block\":{{\"type\":\"tool_use\",\"id\":\"tu_1\",\"name\":\"bash\"}}}}\n\
+\n\
+{tail}"
+            );
+
+            let (tx, _rx) = flume::unbounded();
+            let resp = parse_sse(mock_response(sse_data.as_bytes()), &tx, TEST_STREAM_TIMEOUT)
+                .await
+                .unwrap();
+
+            let tools: Vec<_> = resp.message.tool_uses().collect();
+            assert_eq!(tools.len(), 1);
+            assert!(tools[0].2.is_object(), "input was {}", tools[0].2);
+        })
+    }
+
     fn text_block(text: &str) -> ContentBlock {
         ContentBlock::Text { text: text.into() }
     }
@@ -1309,6 +1339,21 @@ data: {\"type\":\"message_delta\",\"usage\":{\"output_
                 },
                 "cache_control": {"type": "ephemeral"},
             })
+        );
+    }
+
+    #[test_case(Value::Null ; "null")]
+    #[test_case(json!("ls") ; "string")]
+    fn wire_messages_replay_tool_use_input_as_object(input: Value) {
+        let messages = vec![message(
+            Role::Assistant,
+            vec![ContentBlock::tool_use("tu_1", "bash", input)],
+        )];
+        let json: Value =
+            serde_json::to_value(shared::wire_messages(&messages, &json!([]))).unwrap();
+        assert_eq!(
+            json[0]["content"][0],
+            json!({"type": "tool_use", "id": "tu_1", "name": "bash", "input": {}})
         );
     }
 
