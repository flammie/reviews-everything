#!/bin/bash
function filenamify() {
    echo $1 | uconv -x ascii | tr -d '\n' |\
        tr -s '[:blank:][:cntrl:][^!*();:@&=+$,/?#][][]' '-'
}
timestamp=$(date --iso-8601)
read -p "Title of reviewed stuff: " title
fileid=$(filenamify "$title")
outfile=docs/$timestamp-$fileid.markdown
if ! touch $outfile ; then
    echo "cannot write to $outfile"
    exit 2
fi
echo "creating template to $outfile"
echo "---" > $outfile
echo "title: \"$title\"" >> $outfile
echo "date: $timestamp" >> $outfile
read -p "Score out of 10 (decimals allowed): " score
echo "score: $score" >> $outfile
echo "Add new metadata headers?"
select a in yes no ; do
    if test x$a = xno ; then
        break
    fi
    read -p "header name? " header
    read -p "header value? " value
    echo "$header: $value" >> $outfile
done
echo "---" >> $outfile
echo >> $outfile
echo "# Flammie reviews: $title" >> $outfile
echo "Now just write your review stub in markdown and end with EOF (CTRL-D)"
while read l ; do
    echo $l >> $outfile
done
