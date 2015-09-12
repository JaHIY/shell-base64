#!/bin/sh -

. "${LIB_DIR}/operators.sh"
. "${LIB_DIR}/strings.sh"

strict_encode_base64() (
    base64chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    od -tu1 -An -v | grep -o '[^[:space:]]\{1,\}' | \
      { buf=0
        iter=0
        while read -r input; do
            buf="$(calc "bit_or(bit_left_shift($buf, 8), bit_and($input, 255))")"
            iter="$(calc "$iter + 1")"

            if [ "$iter" -eq 3 ]; then
                i=18
                while true; do
                    printf '%s' "$(substr "$base64chars" "$(calc "bit_and(bit_right_shift($buf, $i), 63)")" 1)"
                    i="$(calc "$i - 6")"
                    [ "$i" -lt 0 ] && break
                done
                iter=0
                buf=0
            fi
        done

        if [ "$iter" -gt 0 ]; then
            p="$(calc "3 - $iter")"

            case "$iter" in
                '1')
                    buf="$(calc "bit_left_shift($buf, 4)")"
                    ;;
                '2')
                    buf="$(calc "bit_left_shift($buf, 2)")"
                    ;;
            esac

            while true; do
                printf '%s' "$(substr "$base64chars" "$(calc "bit_and(bit_right_shift($buf, $iter * 6), 63)")" 1)"
                iter="$(calc "$iter - 1")"
                [ "$iter" -lt 0 ] && break
            done

            repeat '=' "$p"
        fi; }
)

encode_base64() {
    strict_encode_base64 "$@" | grep -o '[^[:space:]]\{1,76\}'
}

urlsafe_encode_base64() {
    strict_encode_base64 "$@" | tr -d '=' | tr '/+' '_-'
}

decode_base64() (
    base64chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    od -tu1 -An -v | grep -o '[^[:space:]]\{1,\}' | \
      { enter_loop=1
        buf=0
        iter=0
        while read -r raw_input && [ "$enter_loop" -eq 1 ]; do
            input="$(chr "$raw_input")"

            case "$input" in
                '=')
                    enter_loop=0
                    continue
                    ;;
                *)
                    c="$(index "$base64chars" "$input")"
                    [ "$c" -lt 0 ] && continue
                    buf="$(calc "bit_or(bit_left_shift($buf, 6), $c)")"
                    iter="$(calc "$iter + 1")"

                    if [ "$iter" -eq 4 ]; then
                        i=16
                        while true; do
                            printf '%s' "$(chr "$(calc "bit_and(bit_right_shift($buf, $i), 255)")")"
                            i="$(calc "$i - 8")"
                            [ "$i" -lt 0 ] && break
                        done
                        iter=0
                        buf=0
                    fi
                    ;;
            esac
        done

        case "$iter" in
            '2')
                printf '%s' "$(chr "$(calc "bit_and(bit_right_shift($buf, 4), 255)")")"
                ;;
            '3')
                i=10
                while true; do
                    printf '%s' "$(chr "$(calc "bit_and(bit_right_shift($buf, $i), 255)")")"
                    i="$(cal  "$i - 8")"
                    [ "$i" -lt 0 ] && break
                done
                ;;
        esac;}
)

urlsafe_decode_base64() {
    tr -C -d '[[:alnum:]_-]' | tr '_-' '/+' | decode_base64
}
