--- deps/v8/include/v8config.h.orig	2026-08-05 09:31:09 UTC
+++ deps/v8/include/v8config.h
@@ -1030,7 +1030,7 @@ arm64 host
 #define V8_TARGET_LITTLE_ENDIAN 1
 #endif
 #elif V8_TARGET_ARCH_PPC64
-#if V8_OS_AIX
+#if defined(__BIG_ENDIAN__) || defined(V8_OS_AIX)
 #define V8_TARGET_BIG_ENDIAN 1
 #else
 #define V8_TARGET_LITTLE_ENDIAN 1
