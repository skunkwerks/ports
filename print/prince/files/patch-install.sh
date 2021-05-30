--- install.sh.orig	2020-05-25 15:44:54 UTC
+++ install.sh
@@ -11,19 +11,6 @@ base=$( dirname "$0" )
 
 cd "$base" || exit 1
 
-echo "$PRODUCT $VERSION"
-echo
-echo "Install directory"
-echo "    This is the directory in which $PRODUCT $VERSION will be installed."
-echo "    Press Enter to accept the default directory or enter an alternative."
-printf "    [%s]: " "$prefix"
-
-IFS= read -r input
-if [ ! -z "$input" ] ; then
-    prefix="$input"
-fi
-
-echo
 echo "Installing $PRODUCT $VERSION..."
 
 install_dir () {
