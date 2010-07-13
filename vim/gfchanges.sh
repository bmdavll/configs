#!/bin/bash

exitcode=0

echoc blue "ADDED"
gf '\([[:blank:]]\|^\)"+$' -n "$@"
[ $? -ne 0 ] && exitcode=1

echoc blue "DELETED"
gf '^[[:blank:]]*"-[[:blank:]]' -n "$@"
[ $? -ne 0 ] && exitcode=1

exit $exitcode
