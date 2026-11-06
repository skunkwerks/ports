--- src/unix/poll.c.orig	2025-12-11 09:35:28 UTC
+++ src/unix/poll.c
@@ -83,6 +83,14 @@ int uv_poll_init(uv_loop_t* loop, uv_poll_t* handle, i
     err = uv__nonblock_fcntl(fd, 1);
 #endif
 
+  /* FreeBSD implements fcntl(F_SETFL) in terms of fo_ioctl(FIONBIO) and its
+   * kqueue descriptors reject that with ENOTTY, so neither of the above can
+   * succeed.  Such descriptors are readiness-pollable all the same; there is
+   * nothing to read() from them, so O_NONBLOCK is immaterial.  Don't fail.
+   */
+  if (err == UV_ENOTTY)
+    err = 0;
+
   if (err)
     return err;
 
