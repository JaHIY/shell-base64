#!/bin/sh -

WHO_AM_I="$(which "$0")"
LIB_DIR="$(dirname "$(readlink -f "$WHO_AM_I")")/lib"
. "${LIB_DIR}/base64.sh"

decode_base64 "$@"
