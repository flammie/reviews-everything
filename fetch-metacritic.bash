#!/bin/bash
if test $# != 1 ; then
    echo "Usage: $0 USERNAME"
    exit 1
fi

function filenamify() {
    echo "$1" | uconv -x ascii | tr -d '\n' |\
        tr -s '[:blank:][:cntrl:][^!*();:@&=+$,/?#][][]' '-'
}
function score_stars() {
    stars=$(echo "$1" | sed -e 's/[.,].*//')
    emptystars=$((10 - stars))
    for i in $(seq "$stars") ; do
        echo -n ★
    done
    for i in $(seq "$emptystars") ; do
        echo -n ☆
    done
    echo " ($score out of 10)"
}
echo newest versions of metacritics have hidden the review texts from crawlers
exit 1
if ! test -f "$1" ; then
    wget https://www.metacritic.com/user/"$1"
    for i in $(seq 1 64) ; do
        if ! wget "https://www.metacritic.com/user/$1?page=$i" -O $1.$i; then
            break
        else
            cat $1.$i >> $1
        fi
    done
fi

fgrep 'product_title"><a' < $1 |\
    sed -e 's/^.*product_title"><a href[^>]*>//'\
        -e 's:</a></div>::' > metacritics
while read t ; do
    echo found review $t
    fnt=$(filenamify "$t")
    awk "/$t/,/review_actions/ {print;}" < $1 > $fnt.xml
    score=$(fgrep metascore_w < $fnt.xml | tail -n 1 |\
        sed -e 's/^<div[^>]*>//' \
            -e 's:</div>::')
    echo "# Flammie reviews: $t" > docs/$fnt.markdown
    awk '/review_body/,/review_section/ {print;}' < $fnt.xml |\
        sed -e 's/<[^>]*>//g' >> docs/$fnt.markdown
    score_stars "$score" >> docs/$fnt.markdown
    echo >> docs/$fnt.markdown
    echo '*(A version of this review was submitted to metacritic)*' \
        >> docs/$fnt.markdown
done < metacritics

