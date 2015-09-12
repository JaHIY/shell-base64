#!/bin/sh -

. "${LIB_DIR}/operators.sh"
. "${LIB_DIR}/strings.sh"

strict_encode_base64() {
    local base64chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    od -tu1 -An -v | grep -o '[^[:space:]]\{1,\}' | \
      { local buf=0
        local iter=0
        while read -r input; do
            buf="$(calc "bit_or(bit_left_shift($buf, 8), bit_and($input, 255))")"
            iter="$(calc "$iter + 1")"

            if [ "$iter" -eq 3 ]; then
                local i=18
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
            local p="$(calc "3 - $iter")"

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
}

encode_base64() {
    strict_encode_base64 "$@" | grep -o '[^[:space:]]\{,76\}'
}

urlsafe_encode_base64() {
    strict_encode_base64 "$@" | tr -d '=' | tr '/+' '_-'
}

decode_base64() {
    local base64chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    od -tu1 -An -v | grep -o '[^[:space:]]\{1,\}' | \
      { local enter_loop=1
        local buf=0
        local iter=0
        while read -r raw_input && [ "$enter_loop" -eq 1 ]; do
            local input="$(chr "$raw_input")"

            case "$input" in
                '=')
                    enter_loop=0
                    continue
                    ;;
                *)
                    local c="$(index "$base64chars" "$input")"
                    [ "$c" -lt 0 ] && continue
                    buf="$(calc "bit_or(bit_left_shift($buf, 6), $c)")"
                    iter="$(calc "$iter + 1")"

                    if [ "$iter" -eq 4 ]; then
                        local i=16
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
                local i=10
                while true; do
                    printf '%s' "$(chr "$(calc "bit_and(bit_right_shift($buf, $i), 255)")")"
                    i="$(cal  "$i - 8")"
                    [ "$i" -lt 0 ] && break
                done
                ;;
        esac;}
}

urlsafe_decode_base64() {
    tr -d '[[:space:]]' | tr '_-' '/+' | od -An -tu1 -v | grep -o '[^[:space:]]\{1,\}' | \
        { local len=0
        while read -r input; do
            printf "$(chr "$input")"
            len="$(calc "$len + 1")"
        done

        local padding_width="$(calc "4 - ($len % 4)")"
        printf '%s' "$(repeat '=' "$padding_width")"; } | \
        decode_base64
}
