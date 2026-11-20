--- src/cares_wrap.h.orig	2026-08-05 09:31:13 UTC
+++ src/cares_wrap.h
@@ -24,7 +24,7 @@
 # include <netdb.h>
 #endif  // __POSIX__
 
-# include <ares_nameser.h>
+# include <arpa/nameser.h>
 
 namespace node {
 namespace cares_wrap {
