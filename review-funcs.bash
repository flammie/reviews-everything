#!/bin/bash
# common functions for Flammie reviews everything
function filenamify() {
    echo $1 | uconv -x ascii | tr -d '\n' |\
        tr -s '[:blank:][:cntrl:][^!*().'\''\\{|};:@&=+$,/?#][][]' '-'
}
function score_stars() {
    stars=$(echo $1 | sed -e 's/[.,].*//')
    emptystars=$((10 - $stars))
    for i in $(seq $stars) ; do
        echo -n ★
    done
    for i in $(seq $emptystars) ; do
        echo -n ☆
    done
    echo " ($score out of 10)"
}
function score_chilis() {
    chilis=$(echo $1 | sed -e 's/[.,].*//')
    for i in $(seq $chilis) ; do
        echo -n 🌶
    done
    echo " ($chilis out of 10)"
}

