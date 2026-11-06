--- configure.py.orig	2026-10-24 15:23:04 UTC
+++ configure.py
@@ -2116,7 +2116,7 @@ def configure_node(o):
   else:
     if (options.without_lief is not None):
       o['variables']['node_use_lief'] = b(not options.without_lief)
-    elif flavor in ('mac', 'linux', 'win'):
+    elif flavor in ('mac', 'linux', 'win', 'freebsd'):
       o['variables']['node_use_lief'] = 'true'
     else:
       o['variables']['node_use_lief'] = 'false'
@@ -2969,6 +2969,8 @@ configure_library('cares', output, pkgname='libcares')
 # Only cctest uses gtest; keep it out of the node binary's link line.
 output['variables']['node_shared_gtest_libraries'] = []
 configure_library('gtest', output, 'node_shared_gtest_libraries')
+output['libraries'] = [l for l in output['libraries'] if l != '-lgtest']
+output['variables']['node_shared_gtest_libraries'] = ['-lgtest']
 configure_library('hdr_histogram', output)
 configure_library('highway', output, pkgname='libhwy')
 configure_library('merve', output)
