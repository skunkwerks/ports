--- node.gyp.orig	2026-08-05 09:31:13 UTC
+++ node.gyp
@@ -651,6 +651,14 @@
       'msvs_disabled_warnings!': [4244],
 
       'conditions': [
+        # Reserve spare Elf64_Phdr slots so that "node --build-sea" can inject
+        # the blob without relocating the program header table, which FreeBSD's
+        # image activator requires to stay in the first page. The script uses
+        # INSERT BEFORE .interp, so it is applied to this dynamically linked
+        # executable only, never to shared libraries or host tools.
+        [ 'OS=="freebsd"', {
+          'ldflags': [ '-Wl,--script,%%SEA_PAD_LD%%' ],
+        }],
         [ 'node_shared_hdr_histogram=="false"', {
           'dependencies': [
             'deps/histogram/histogram.gyp:histogram',
