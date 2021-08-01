--- lib/ansible/module_utils/facts/hardware/freebsd.py.orig	2021-08-01 13:10:11 UTC
+++ lib/ansible/module_utils/facts/hardware/freebsd.py
@@ -71,6 +71,9 @@ class FreeBSDHardware(Hardware):
             rc, out, err = self.module.run_command("%s -n hw.ncpu" % sysctl, check_rc=False)
             cpu_facts['processor_count'] = out.strip()
 
+            rc, out, err = self.module.run_command("%s -n hw.model" % sysctl, check_rc=False)
+            cpu_facts['processor'] = out.strip()
+
         dmesg_boot = get_file_content(FreeBSDHardware.DMESG_BOOT)
         if not dmesg_boot:
             try:
