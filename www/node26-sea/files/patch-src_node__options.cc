--- src/node_options.cc.orig	2026-08-05 09:31:00 UTC
+++ src/node_options.cc
@@ -105,10 +105,11 @@
   if (!build_sea.empty()) {
 #if defined(DISABLE_SINGLE_EXECUTABLE_APPLICATION)
     errors->push_back("Single executable application is disabled.\n");
-#elif !defined(HAVE_LIEF)
+#elif !defined(HAVE_LIEF) && !defined(__FreeBSD__)
+    // On FreeBSD the ELF injector in node_sea_bin.cc needs no LIEF.
     errors->push_back(
         "Node.js must be built with LIEF to build support --build-sea.\n");
-#endif  // !defined(HAVE_LIEF)
+#endif  // !defined(HAVE_LIEF) && !defined(__FreeBSD__)
   }
 
   if (use_largepages != "off" &&
