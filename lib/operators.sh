#!/bin/sh -

calc() {
    printf '%s\n' \
        'define bit_and (x, y) {
            auto min, max, d, i, ret
            i = 1
            ret = 0
            if (x > y) {
                min = y
                max = x
            } else {
                min = x
                max = y
            }
            while (min > 0) {
                d=min % 2
                if (d == (max % 2)) {
                    ret += d * i
                }
                i *= 2
                min /= 2
                max /= 2
            }
            return (ret)
        }

        define bit_or (x, y) {
            auto min, max, d, ret, i
            i = 1
            ret = 0
            if (x > y) {
                min = y
                max = x
            } else {
                min = x
                max = y
            }
            while (max > 0) {
                d = max % 2
                if (d == (min % 2)) {
                    ret += d * i
                } else {
                    ret += i
                }
                i *= 2
                min /= 2
                max /= 2
            }
            return (ret)
        }

        define bit_xor (x, y) {
            auto min, max, ret, i
            i = 1
            ret = 0
            if (x > y) {
                min = y
                max = x
            } else {
                min = x
                max = y
            }
            while (max > 0) {
                if ((max % 2) != (min % 2)) {
                    ret += i
                }
                i *= 2
                min /= 2
                max /= 2
            }
            return (ret)
        }

        define bit_not (x) {
            return (-1 - x)
        }

        define bit_left_shift (x, y) {
            return (x * 2 ^ y)
        }

        define bit_right_shift(x, y) {
            return (x / 2 ^ y)
        }' "$*" | bc
}
