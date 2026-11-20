--- setup.py.orig	2026-11-08 17:33:25 UTC
+++ setup.py
@@ -9,11 +9,7 @@ for argument in sys.argv:
 for argument in sys.argv:
     if argument.startswith('--libdir='):
         libdir = argument
-if libdir is None:
-    if 'bdist_wheel' in sys.argv:
-        print('Need to specify location of liblame')
-        sys.exit(1)
-else:
+if libdir is not None:
     sys.argv.remove(libdir)
     libdir = libdir[len('--libdir='):]
 
@@ -22,11 +18,7 @@ for argument in sys.argv:
 for argument in sys.argv:
     if argument.startswith('--incdir='):
         incdir = argument
-if incdir is None:
-    if 'bdist_wheel' in sys.argv:
-        print('Need to specify location of liblame source')
-        sys.exit(1)
-else:
+if incdir is not None:
     sys.argv.remove(incdir)
     incdir = incdir[len('--incdir='):]
 
@@ -34,7 +26,7 @@ lameenc = setuptools.Extension(
 lameenc = setuptools.Extension(
     'lameenc',
     include_dirs=[incdir] if incdir else [],
-    libraries=['libmp3lame'] if sys.platform == 'win32' else [],
+    libraries=['libmp3lame'] if sys.platform == 'win32' else ['mp3lame'],
     extra_objects=
         [] if sys.platform == 'win32' or not libdir else [os.path.join(libdir, 'libmp3lame.a')],
     library_dirs=[libdir] if sys.platform == 'win32' and libdir else [],
