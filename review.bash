#!/bin/bash
. review-funcs.bash
while test $# -gt 0 ; do
    case $1 in
        spicy) mode=spicy;;
        *) echo "Unrecognised command $*"; exit 1;;
    esac
    shift
done
timestamp=$(date --iso-8601)
read -r -p "Title of reviewed stuff: " title
fileid=$(filenamify "$title")
outfile=docs/$fileid.markdown
if ! touch "$outfile" ; then
    echo "cannot write to $outfile"
    exit 2
fi
echo "creating template to $outfile"
echo "---" > "$outfile"
echo "title: \"$title\"" >> "$outfile"
echo "date: $timestamp" >> "$outfile"
read -r -p "Score out of 10 (decimals allowed): " score
echo "score: $score" >> "$outfile"
if test $mode = spicy ; then
    read -r -p "Spice out of 10: " chilis
    echo "spice: $chilis" >> "$outfile"
fi
echo "Add new metadata headers?"
select a in yes no ; do
    if test -z $a ; then
        echo Huh?
        continue
    fi
    if test $a = no ; then
        break
    fi
    read -r -p "header name? " header
    read -r -p "header value? " value
    echo "$header: $value" >> "$outfile"
    echo "Add new metadata headers?"
done
echo "---" >> "$outfile"
echo >> "$outfile"
echo "# Flammie reviews: $title" >> "$outfile"
echo >> "$outfile"
echo "Now just write your review stub in markdown and end with EOF (CTRL-D)"
while read -r l ; do
    echo "$l"
done | fmt >> "$outfile"
echo >> "$outfile"
echo "> *Score*: $(score_stars "$score")" >> "$outfile"
if test -n "$chilis" ; then
    echo "> *Spice*: $(score_chilis "$chilis")" >> "$outfile"
fi
