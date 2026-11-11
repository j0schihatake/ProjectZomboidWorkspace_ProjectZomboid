#!/bin/bash

SCRIPT="`basename \"$0\"`"
GAMEDIR="${HOME}/Zomboid"
LOGFILE="${GAMEDIR}/${SCRIPT}.log"
INSTDIR="`dirname \"$0\"`"/projectzomboid ; cd "${INSTDIR}" ; INSTDIR="`pwd`"

[[ ! -d "${GAMEDIR}" ]] && mkdir -m 0755 "${GAMEDIR}"

if "${INSTDIR}/jre64/bin/java" -version > /dev/null 2>&1; then
	export PATH="${INSTDIR}/jre64/bin:$PATH"
	export LD_LIBRARY_PATH="${INSTDIR}/natives:${INSTDIR}:${INSTDIR}/jre64/lib:${LD_LIBRARY_PATH}"
	JSIG="libjsig.so"
	# XMODIFIERS is cleared here to prevent SCIM screwing up keyboard input
	XMODIFIERS= LD_PRELOAD="${LD_PRELOAD}:${JSIG}:libPZXInitThreads64.so" ./ProjectZomboid64 "$@" >"${LOGFILE}"
else
	echo "Only 64bit is supported"
fi
exit 0
