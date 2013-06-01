# bashdb - header
# This file gets prepended to the file we are debugging when generating the
# temporary file.
#
# Arguments:
# $1 - The name of the original script we are debugging
# $2 - The directory where temporary files are stored
# $3 - The directory where bashdb.pre and bashdb.fns are stored
# 
# Author: Ryan Kadwell <ryan@riaka.ca>

_debugfile=$0
_guineapig=$1
_tmpdir=$2
_libdir=$3

shift 3

source $_libdir/functions.sh
_linebp=
let _trace=0
let _i=1
let _steps=1

OLDIFS=$IFS
IFS=$'\n'
tmplines=( $(cat "$_guineapig") )
for line in "${tmplines[@]}"; do
    _lines[$_i]=$line;
    let _i=$(($_i+1))
done
IFS=$OLDIFS

trap _cleanup EXIT
trap '_step_trap $(( $LINENO -35 ))' DEBUG;
