builddir=`pwd`
srcdir=`dirname $0`
cd $srcdir

mkdir -p .auto

echo "Running glib-gettextize ..."
glib-gettextize --force --copy || {
  echo "**Error**: glib-gettextize failed."; exit 1; }

# echo "Running intltoolize ..."
# intltoolize --force --copy --automake ||
# 	{ echo "**Error**: intltoolize failed."; exit 1; }

libtoolize --force --copy || {
  echo "**ERROR**: libtoolize failed."; exit 1; }

echo "Running aclocal $ACLOCAL_FLAGS ..."
aclocal $ACLOCAL_FLAGS || {
  echo
  echo "**Error**: aclocal failed. This may mean that you have not"
  echo "installed all of the packages you need, or you may need to"
  echo "set ACLOCAL_FLAGS to include \"-I \$prefix/share/aclocal\""
  echo "for the prefix where you installed the packages whose"
  echo "macros were not found"
  exit 1
}

echo "Running autoconf ..."
WANT_AUTOCONF=2.5 autoconf || {
  echo "**Error**: autoconf failed."; exit 1; }

echo "Running autoheader..."
WANT_AUTOCONF=2.5 autoheader --force || {
  echo "**Error**: autoheader failed."; exit 1; }

# checking for automake 1.9+
am_version=`automake --version | head -n 1 | cut -f2- -d1 | cut -f2 -d.`
[ "${am_version}" -ge 9 ] || {
  echo "**Error**: automake 1.9+ required."; exit 1; }

echo "Running automake --gnu $am_opt ..."
automake --add-missing --gnu $am_opt || {
  echo "**Error**: automake failed."; exit 1; }

conf_flags="--enable-maintainer-mode --enable-compile-warnings"

if test x$NOCONFIGURE = x; then
  echo Running $srcdir/configure $conf_flags "$@" ...
  cd $builddir
  $srcdir/configure $conf_flags "$@" \
  && echo Now type \`make\' to compile $PKG_NAME || exit 1
else
  echo Skipping configure process.
fi
