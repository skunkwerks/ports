--- install.sh.orig	2018-12-23 06:27:59 UTC
+++ install.sh
@@ -5,27 +5,26 @@ PROGRAM="prince"
 VERSION="12.4"
 WEBSITE="http://www.princexml.com"
 
-prefix=/usr/local
+prefix=${1:-/usr/local}
 
 base=$( dirname "$0" )
 
 cd "$base" || exit 1
 
-echo "$PRODUCT $VERSION"
-echo
-echo "Install directory"
-echo "    This is the directory in which $PRODUCT $VERSION will be installed."
-echo "    Press Enter to accept the default directory or enter an alternative."
-printf "    [%s]: " "$prefix"
+echo "Installing $PRODUCT $VERSION..."
 
-IFS= read -r input
-if [ ! -z "$input" ] ; then
-    prefix="$input"
-fi
+install_dir () {
+    install -d "$1"
+}
 
-echo
-echo "Installing $PRODUCT $VERSION..."
+install_bin () {
+    install -m 755 "$1" "$2"
+}
 
+install_data () {
+    install -m 644 "$1" "$2"
+}
+
 # Create shell script
 
 cat > prince <<EOF
@@ -36,7 +35,7 @@ EOF
 
 # Test that we can create directories
 
-install -d "$prefix/bin" 2>/dev/null ||
+install_dir "$prefix/bin" 2>/dev/null ||
 {
 echo "    Unable to create directories in $prefix"
 echo "    (You may need to be logged in as root to install programs in system"
@@ -48,7 +47,7 @@ exit 1
 
 # Install shell script
 
-install -m 755 prince "$prefix/bin" || exit 1
+install_bin prince "$prefix/bin" || exit 1
 
 # Install everything else
 
@@ -56,7 +55,7 @@ echo "Creating directories..."
 
 for dir in $( find "lib/$PROGRAM" -type d ) ; do
 
-    install -d "$prefix/$dir" || exit 1
+    install_dir "$prefix/$dir" || exit 1
 
 done
 
@@ -67,14 +66,14 @@ for file in $( find "lib/$PROGRAM" -type f ) ; do
     dir=$( dirname "$file" )
 
     if [ -x "$file" ] ; then
-	install -m 755 "$file" "$prefix/$dir" || exit 1
+	install_bin "$file" "$prefix/$dir" || exit 1
     else
 	if [ "$file" = "lib/$PROGRAM/license/license.dat" ] ; then
 	    if [ ! -f "$prefix/$file" ] ; then
-		install -m 644 "$file" "$prefix/$dir" || exit 1
+		install_data "$file" "$prefix/$dir" || exit 1
 	    fi
 	else
-	    install -m 644 "$file" "$prefix/$dir" || exit 1
+	    install_data "$file" "$prefix/$dir" || exit 1
 	fi
     fi
 
