#!/bin/sh -

substr() {
    awk -v s="$1" -v i="$2" -v l="$3" 'BEGIN { print substr(s, i+1, l); }'
}

index() {
    awk -v s="$1" -v c="$2" 'BEGIN { print index(s, c) - 1; }'
}

trim() {
    tr -d '[:blank:]'
}

length() {
    printf '%s' "$1" | wc -m | trim
}

ord() {
    LC_CTYPE=C printf '%d' "'$1"
}

chr() {
    [ "$1" -lt 256 ] || return 1
    printf '%b' "$(printf '\%04o' "$1")"
}

repeat() {
    printf '%*s' "$2" | sed -e "s/[[:blank:]]/$1/g"
}
