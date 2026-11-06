--- ocijail/main.cpp.orig	2026-11-01 22:24:48 UTC
+++ ocijail/main.cpp
@@ -154,13 +154,9 @@ main_app::main_app(const std::string& title) : CLI::Ap
 main_app::main_app(const std::string& title) : CLI::App(title) {
     add_option(
         "--root", state_db_, "Override default location for state database");
-    add_flag(
-        "--version",
-        [](size_t) {
-            std::cout << "ocijail version " << ::version << "\n";
-            std::exit(0);
-        },
-        "Print runtime version");
+    set_version_flag("--version",
+                     std::string("ocijail version ") + ::version,
+                     "Print runtime version");
 
     std::map<std::string, test_mode> test_modes{
         {"none", test_mode::NONE},
