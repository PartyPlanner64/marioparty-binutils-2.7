#!/bin/sh

cat << 'EOF'
$! Set the def dir to proper place for use in batch. Works for interactive to.
$flnm = f$enviroment("PROCEDURE")     ! get current procedure name
$set default 'f$parse(flnm,,,"DEVICE")''f$parse(flnm,,,"DIRECTORY")'
$v = 'f$verify(0)'
$!
$!	Command file to build a GNU assembler on VMS
$!
$!	If you are using a version of GCC that supports global constants
$!	you should remove the define="const=" from the gcc lines.
$!
$!	Caution:  Versions 1.38.1 and earlier had a bug in the handling of
$!	some static constants. If you are using such a version of the
$!	assembler, and you wish to compile without the "const=" hack,
$!	you should first build this version *with* the "const="
$!	definition, and then use that assembler to rebuild it without the
$!	"const=" definition.  Failure to do this will result in an assembler
$!	that will mung floating point constants.
$!
$!	Note: The version of gas shipped on the GCC VMS tapes has been patched
$!	to fix the above mentioned bug.
$!
$	!The gcc-vms driver was modified to use `-1' quite some time ago,
$	!so don't echo this text any more...
$ !write sys$output "If this assembler is going to be used with GCC 1.n, you"
$ !write sys$output "need to modify the driver to supply the -1 switch to gas."
$ !write sys$output "This is required because of a small change in how global"
$ !write sys$output "constant variables are handled.  Failure to include this"
$ !write sys$output "will result in linker warning messages about mismatched
$ !write sys$output "psect attributes."
$!
$ C_DEFS :="""VMS"""
$! C_DEFS :="""VMS""","""const="""
$ C_INCLUDES	= "/Include=([],[.config],[-.include],[-.include.aout])"
$ C_FLAGS	= "/noVerbose/Debug" + c_includes
$!
$!
$ on error then  goto bail
$ if f$search("[-.libiberty]liberty.olb").eqs.""
$ then	@[-.libiberty]vmsbuild.com
$	write sys$output "Now building gas."
$ endif
$ if "''p1'" .eqs. "LINK" then goto Link
$!
$!  This helps gcc 1.nn find the aout/* files.
$!
$ aout_dev = f$parse(flnm,,,"DEVICE")
$ tmp = aout_dev - ":"
$if f$trnlnm(tmp).nes."" then aout_dev = f$trnlnm(tmp)
$ aout_dir = aout_dev+f$parse(flnm,,,"DIRECTORY")' -
	- "GAS]" + "INCLUDE.AOUT.]" - "]["
$assign 'aout_dir' aout/tran=conc
$ opcode_dir = aout_dev+f$parse(flnm,,,"DIRECTORY")' -
	- "GAS]" + "INCLUDE.OPCODE.]" - "]["
$assign 'opcode_dir' opcode/tran=conc
$!
$ set verify
$!
EOF

cfiles="`echo $* | sed -e 's/\.o/.c/g' -e 's!../\([^ /]*\)/\([^ /]*\.c\)![-.\1]\2!g'`"

for cfile in $cfiles ; do
  case $cfile in
    "[-."*)
	base=`echo $cfile | sed -e 's/\[.*\]//' -e 's/\.c$//'`
	echo "\$ gcc 'c_flags'/Define=('C_DEFS')/Object=[]$base.obj $cfile"
	;;
    *)
	echo "\$ gcc 'c_flags'/Define=('C_DEFS') $cfile"
	;;
  esac
done

cat << 'EOF'
$link:
$!'f$verify(0)'
$ set verify=(Proc,noImag)
$ link/noMap/Exec=gcc-as version.opt/Opt+sys$input:/Opt
!
!	Linker options file for GNU assembler
!
EOF

for obj in $* ; do
  # Change "foo.o" into "foo.obj".
  echo ${obj}bj,- | sed 's!.*/!!g'
done

cat << 'EOF'
[-.libiberty]liberty.olb/Lib
gnu_cc:[000000]gcclib.olb/Lib,sys$library:vaxcrtl.olb/Lib
! Tell linker exactly what psect attributes we want -- match VAXCRTL.
psect_attr=ENVIRON,long,pic,ovr,rel,gbl,noshr,noexe,rd,wrt
$!
$bail: exit $status + 0*f$verify(v)	!'f$verify(0)'
EOF
