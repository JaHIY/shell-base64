#!/bin/sh -

calc() {
    printf '%s\n' "$*" | bc
}

add() {
    calc "$1" '+' "$2"
}

minus() {
    calc "$1" '-' "$2"
}

multiply() {
    calc "$1" '*' "$2"
}

div() {
    calc "$1" '/' "$2"
}

mod() {
    calc "$1" '%' "$2"
}

bit_and() {
    local min=0
    local max=0
    local d=0
    local ret=0
    local i=1
    if [ "$1" -gt "$2" ]; then
        min="$2"
        max="$1"
    else
        min="$1"
        max="$2"
    fi
    while [ "$min" -gt 0 ]; do
        d="$(mod "$min" 2)"
        if [ "$d" -eq "$(mod "$max" 2)" ]; then
            ret="$(add "$ret" "$(multiply "$d" "$i")")"
        fi
        i="$(multiply "$i" 2)"
        min="$(div "$min" 2)"
        max="$(div "$max" 2)"
    done
    printf '%s\n' "$ret"
}

bit_or() {
    local min=0
    local max=0
    local d=0
    local ret=0
    local i=1
    if [ "$1" -gt "$2" ]; then
        min="$2"
        max="$1"
    else
        min="$1"
        max="$2"
    fi
    while [ "$max" -gt 0 ]; do
        d="$(mod "$max" 2)"
        if [ "$d" -eq "$(mod "$min" 2)" ]; then
            ret="$(add "$ret" "$(multiply "$d" "$i")")"
        else
            ret="$(add "$ret" "$i")"
        fi
        i="$(multiply "$i" 2)"
        min="$(div "$min" 2)"
        max="$(div "$max" 2)"
    done
    printf '%s\n' "$ret"
}

bit_xor() {
    local min=0
    local max=0
    local ret=0
    local i=1
    if [ "$1" -gt "$2" ]; then
        min="$2"
        max="$1"
    else
        min="$1"
        max="$2"
    fi
    while [ "$max" -gt 0 ]; do
        if [ "$(mod "$max" 2)" -ne "$(mod "$min" 2)" ]; then
            ret="$(add "$ret" "$i")"
        fi
        i="$(multiply "$i" 2)"
        min="$(div "$min" 2)"
        max="$(div "$max" 2)"
    done
    printf '%s\n' "$ret"
}

bit_not() {
    printf '%s\n' "$(minus -1 "$1")"
}

bit_left_shift() {
    local var="$1"
    local x="$2"
    if [ "$var" -ne 0 ]; then
        while [ "$x" -gt 0 ]; do
            var="$(multiply "$var" 2)"
            x="$(minus "$x" 1)"
        done
    fi
    printf '%s\n' "$var"
}

bit_right_shift() {
    local var="$1"
    local x="$2"
    while [ "$x" -gt 0 ] && [ "$var" -ne 0 ]; do
        var="$(div "$var" 2)"
        x="$(minus "$x" 1)"
    done
    printf '%s\n' "$var"
}
