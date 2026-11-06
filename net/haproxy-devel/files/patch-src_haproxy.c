--- src/haproxy.c.orig	2026-10-13 19:21:58 UTC
+++ src/haproxy.c
@@ -3799,19 +3799,14 @@ int main(int argc, char **argv)
 			chroot_permitted = 0;
 		/* errors mean prctl() not supported, so don't update the verdict */
 #endif
-		if (chroot_permitted && do_chroot(argv[0], "auto") != 0) {
+		if (chroot_permitted) {
 			ha_warning("[%s.main()] HAProxy was started as root without any 'chroot' "
-			           "directive, and an attempt at automatically chrooting failed, "
-			           "so the haproxy process is not as protected as it could be. "
-			           "Please report this event to developers with as many details as "
-			           "possible about your execution environment so they can evaluate "
-			           "if anything can be done to better support it. A chroot limits "
-			           "filesystem access of an intruder to a single, preferably empty, "
-			           "directory. It is strongly recommended to enable this feature "
-			           "whenever possible (it's always possible when starting as root), "
-			           "via 'chroot auto' in the global section. If you think you have "
-			           "good reasons for running outside a chroot, explicitly configure "
-			           "'chroot /' to silence this warning.\n", argv[0]);
+				   "directive. A chroot limits filesystem access of an intruder "
+				   "to a single, preferably empty, directory. It is strongly recommended "
+				   "to enable this feature whenever possible (it's always possible when "
+				   "starting as root), via 'chroot auto' in the global section. If you "
+				   "think you have good reasons for running outside a chroot, explicitly "
+				   "configure 'chroot /' to silence this warning.\n", argv[0]);
 		}
 	}
 
