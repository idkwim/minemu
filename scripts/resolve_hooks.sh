#!/bin/bash

LIBC=/lib/i386-linux-gnu/i686/cmov/libc-2.13.so

get_file_id()
{
	stat -c 'print ":".join( "%%x" %% (x,) for x in (%i, %d, %Y) )' $1 | python
}

get_file_offset()
{
	SYM="$(readelf -s "$1" | grep "$2"'$'|awk '{print $2}')"
	readelf -l "$1" | grep '  LOAD' | awk '{printf ("x=0x'"$SYM"'\nif 0x%x <= x < 0x%x: print \"%%x\" %% (x-0x%x)\n", $3,$3+$5,$3-$2)}'|python
}

resolve_hook()
{
	OFFSET=$(get_file_offset "$2" "$3")
	FILEID="$(get_file_id "$2")"
	echo "$1:$FILEID:$OFFSET"
}

resolve_hook 'fmt_check' "$LIBC" '_IO_vfprintf@@.*'
resolve_hook 'fmt_check' test/testcases/fork 'main'
