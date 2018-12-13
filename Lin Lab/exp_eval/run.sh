#!/usr/bin/env bash

my_dir=`dirname $0`

# Build and run.
make && ${my_dir}/exp_eval "1 + 2" \
    "1 + 2 + 3" \
    "1 + 2 * 3" \
    "(1 + 2) * 3" \
    "(1 + 2) * (3^2 / 3)" \
    "sqrt(3^2)" \
    "1 <= 2" \
    "1 > 2" \
    "1 - -1" \
    "1.2 - .2" \
    " ((13 + 14))+2 - 1   " \

