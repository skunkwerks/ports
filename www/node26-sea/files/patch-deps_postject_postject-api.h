--- deps/postject/postject-api.h.orig	2026-08-05 09:31:00 UTC
+++ deps/postject/postject-api.h
@@ -9,10 +9,13 @@
 #if defined(__APPLE__) && defined(__MACH__)
 #include <mach-o/dyld.h>
 #include <mach-o/getsect.h>
-#elif defined(__linux__)
+#elif defined(__linux__) || defined(__FreeBSD__)
 #include <elf.h>
 #include <link.h>
 #include <sys/param.h>
+#if defined(__FreeBSD__) && !defined(ElfW)
+#define ElfW(type) Elf_##type
+#endif
 #elif defined(_WIN32)
 #include <windows.h>
 #endif
@@ -43,7 +46,7 @@
   return sentinel[sizeof(POSTJECT_SENTINEL_FUSE)] == '1';
 }
 
-#if defined(__linux__)
+#if defined(__linux__) || defined(__FreeBSD__)
 static int postject__dl_iterate_phdr_callback(struct dl_phdr_info* info,
                                               size_t size,
                                               void* data) {
@@ -117,7 +120,7 @@
   }
 
   return ptr;
-#elif defined(__linux__)
+#elif defined(__linux__) || defined(__FreeBSD__)
 
   if (options != NULL && options->elf_section_name != NULL) {
     name = options->elf_section_name;
