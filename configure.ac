dnl Process this file with autoconf to produce a configure script.
AC_INIT(gtkgl, 2.0.2)
AC_CONFIG_AUX_DIR(.auto)
AC_CONFIG_HEADER(config.h)
AM_INIT_AUTOMAKE([no-define])

#shared library versioning
GTKGL_LIBRARY_VERSION=1:1:0
#                     | | |
#              +------+ | +---+
#              |        |     |
#           current:revision:age
#              |        |     |
#              |        |     +- increment if interfaces have been added
#              |        |        set to zero if interfaces have been removed or changed
#              |        +- increment if source code has changed
#              |           set to zero if current is incremented
#              +- increment if interfaces have been added, removed or changed
# 
# Value of current - age. Used by libtool in Win32 DLL names. We need
# to know the DLL name to build MSVC import libraries.
LT_CURRENT_MINUS_AGE=1

AC_SUBST(GTKGL_LIBRARY_VERSION)
AC_SUBST(LT_CURRENT_MINUS_AGE)
AC_SUBST(VERSION)

dnl Checks for programs.
AC_PROG_CC
AC_PROG_CPP
AC_LIBTOOL_WIN32_DLL
AM_PROG_LIBTOOL
AM_SANITY_CHECK
AM_MAINTAINER_MODE

dnl
dnl  Check for the operating system
dnl
AC_MSG_CHECKING([for Win32])
case "$host" in
  *mingw* | pw32* | *cygwin*)
    native_win32=yes
    ;;
  *)
    native_win32=no
    ;;
esac
AC_MSG_RESULT([$native_win32])
AM_CONDITIONAL(OS_WIN32, test "$native_win32" = "yes")

if test "$native_win32" = "yes"; then
  AC_CHECK_PROG(ms_librarian, lib.exe, yes, no)
fi
AM_CONDITIONAL(MS_LIB_AVAILABLE, test x$ms_librarian = xyes)

dnl
dnl  Check for GTK libraries
dnl
GTK_REQUIRED_VERSION=2.0.0
PKG_CHECK_MODULES(GTK, gtk+-2.0 >= $GTK_REQUIRED_VERSION gmodule-2.0 >= $GTK_REQUIRED_VERSION)

AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

dnl
dnl  Check for GL/MesaGL libraries
dnl
AC_ARG_WITH(GL-prefix,  [  --with-GL-prefix=DIR    Prefix where GL/MesaGL is installed])
AC_ARG_WITH(lib-GL,     [  --with-lib-GL           use '-lGL'])
AC_ARG_WITH(lib-MesaGL, [  --with-lib-MesaGL       use '-lMesaGL'])
AC_ARG_WITH(lib-opengl32,[ --with-lib-opengl32     use '-lopengl32'])

if test "x$with_GL_prefix" = "x" ; then
 GL_LDOPTS=""
 GL_CFLAGS=""
else
 GL_LDOPTS="-L$with_GL_prefix/lib"
 GL_CFLAGS="-I$with_GL_prefix/include"
fi

saved_LIBS="$LIBS"

AC_MSG_CHECKING([OpenGL])
LIBS="$saved_LIBS $GTK_LIBS $GL_LDOPTS -lGL"
AC_TRY_LINK( ,[ char glBegin(); glBegin(); ], have_GL=yes, 
  LIBS="$saved_LIBS $GTK_LIBS $GL_LDOPTS -lopengl32"
  [AC_TRY_LINK([ #include <windows.h>
                 #include <GL/gl.h>], 
               [ glBegin(GL_TRIANGLES); ], 
    [have_opengl32=yes
     have_GL=yes],
    have_GL=no)])
AC_MSG_RESULT($have_GL)

AC_MSG_CHECKING([Mesa])
LIBS="$saved_LIBS $GTK_LIBS $GL_LDOPTS -lMesaGL"
AC_TRY_LINK( ,[ char glBegin(); glBegin(); ], have_MesaGL=yes, have_MesaGL=no)
AC_MSG_RESULT($have_MesaGL)

if test "x$have_MesaGL" = "xno"; then
 AC_MSG_CHECKING([Mesa with pthreads])
 LIBS="$saved_LIBS $GTK_LIBS $GL_LDOPTS -lMesaGL -lpthread"
 AC_TRY_LINK( ,[ char glBegin(); glBegin(); ], have_MesaGL_pthread=yes, have_MesaGL_pthread=no)
 AC_MSG_RESULT($have_MesaGL_pthread)
fi

LIBS="$saved_LIBS"

if test "x$with_lib_GL" = "xyes"; then

 if test "x$have_GL" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lGLU -lGL"
 else
  AC_MSG_ERROR([Missing GL library])
 fi

elif test "x$with_lib_MesaGL" = "xyes"; then

 if test "x$have_MesaGL" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lMesaGLU -lMesaGL"
 elif test "x$have_MesaGL_pthread" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lMesaGLU -lMesaGL -lpthread"
 else
  AC_MSG_ERROR([Missing MesaGL library])
 fi

elif test "x$with_lib_opengl32" = "xyes"; then

 if test "x$have_opengl32" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lglu32 -lopengl32"
 else
  AC_MSG_ERROR([Missing OpenGL32 library])
 fi

else

 if test "x$have_opengl32" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lglu32 -lopengl32"
 elif test "x$have_GL" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lGLU -lGL"
 elif test "x$have_MesaGL" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lMesaGLU -lMesaGL"
 elif test "x$have_MesaGL_pthread" = "xyes"; then
  GL_LIBS="$GL_LDOPTS -lMesaGLU -lMesaGL -lpthread"
 else
  AC_MSG_ERROR([You need GL or MesaGL libraries])
 fi

fi

saved_LIBS="$LIBS"
AC_MSG_CHECKING([OpenGL shaders])
LIBS="$saved_LIBS $GTK_LIBS $GL_LDOPTS $GL_LIBS"
AC_TRY_LINK( ,[ char glCreateProgram(); glCreateProgram(); ],
            have_shaders=yes, have_shaders=no)
AC_MSG_RESULT($have_shaders)
LIBS="$saved_LIBS"
AM_CONDITIONAL(HAVE_SHADERS, test "$have_shaders" = "yes")

AC_SUBST(GL_CFLAGS)
AC_SUBST(GL_LIBS)

CFLAGS="$CFLAGS $GTK_CFLAGS $GL_CFLAGS"
CFLAGS="$CFLAGS -Wall -lm"

dnl Checks for header files.
AC_HEADER_STDC


dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

dnl Checks for library functions.

AC_OUTPUT(
  Makefile
  gtkgl-2.0.pc
  gtkgl/Makefile
  gtkgl/makefile.mingw
  docs/Makefile
  examples/Makefile
  examples/makefile.mingw
)


echo "---"
echo "Configuration summary"
echo ""
echo "   * Installation prefix: $prefix"
echo "   * Win32:               $native_win32"
echo "   * OpenGL:              $have_GL"
echo ""
echo "---"
