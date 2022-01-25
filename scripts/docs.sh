#!/usr/bin/env bash

SOURCE="${1}"
TARGET="${2}"

source $(dirname $0)/utils/core.sh

# --------------------- #
#       PANVIMDOC       #
# --------------------- #
SRCDIR="./panvimdoc"
REMOTE="https://github.com/kdheepak/panvimdoc/raw/main/scripts"
 FILES="include-files.lua inspect.lua panvimdoc.lua"

DOWNLOAD=0
for FILE in ${FILES}; do
	[ ! -r "${SRCDIR}/${FILE}" ] && DOWNLOAD=1
done

if [ ${DOWNLOAD} -eq 1 ]; then
	mkdir "${SRCDIR}" 2>/dev/null

	:: DOWNLOADING PANVIMDOC
	for FILE in ${FILES}; do
		if curl -sLJO "${REMOTE}/${FILE}" --output-dir "${SRCDIR}"; then
			log 2 "${SRCDIR}/${FILE}"
		else
			log 1 "${SRCDIR}/${FILE}"
			exit 1
		fi
	done
	:: DONE
fi

# --------------------- #
#         MAIN          #
# --------------------- #
LOGFILE="$(mktemp)"

:: RUNNING PANVIMDOC
if pandoc \
	-M 'project:tangerine' -M 'vimversion:Neovim v0.5.0' \
	-t           "${SRCDIR}/panvimdoc.lua" \
	--lua-filter "${SRCDIR}/include-files.lua" \
	--lua-filter "${SRCDIR}/inspect.lua" \
	"${SOURCE}" -o "${TARGET}" 2> "${LOGFILE}"; then
	log 2 DONE
else
	log 1 ERROR
	logcat "${LOGFILE}"
fi
