#!/bin/bash
pushd docs || exit
outfile=index.md
cat ../index-blurb.md > $outfile
echo >> $outfile
echo "## Index alphabetically" >> $outfile
echo >> $outfile
for f in *.markdown ; do
    filename=${f%.markdown}
    link=${filename}.html
    title=${filename//-/ }
    echo "* [${title}]($link)" >> $outfile
done
popd || exit
