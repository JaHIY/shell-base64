#!/bin/sh -

readlink_canonicalize() (
    cd "$(dirname "$1")"

    local target_file="$(basename "$1")"

    while [ -L "$target_file" ]; do
        target_file="$(readlink "$target_file")"
        cd "$(dirname "$target_file")"
        target_file="$(basename "$target_file")"
    done

    local phys_dir="$(pwd -P)"
    printf '%s\n' "${phys_dir}/${target_file}"
)

WHO_AM_I="$(which "$0")"
LIB_DIR="$(dirname "$(readlink_canonicalize "$WHO_AM_I")")/lib"
. "${LIB_DIR}/base64.sh"

BASENAME="$(basename "$0")"

case "$BASENAME" in
    'encode_base64'*)
        encode_base64 "$@"
        ;;
    'strict_encode_base64'*)
        strict_encode_base64 "$@"
        ;;
    'decode_base64'*)
        decode_base64 "$@"
        ;;
    'urlsafe_encode_base64'*)
        urlsafe_encode_base64 "$@"
        ;;
    'urlsafe_decode_base64'*)
        urlsafe_decode_base64 "$@"
        ;;
    *)
        printf '%s\n' 'Error: not matching a pattern' 1>&2
        ;;
esac
