#!/bin/bash
pushd docs
outfile=index.md
echo "# Flammie reviews everything" > $outfile
echo >> $outfile
cat <<- EOT | fmt >> $outfile
This website contains *reviews* made by [Flammie](../), some made
specifally for this website and some rescued from other websites, as I
realise that I shouldn't rely on googles and tripadvisors to archive my
valuable reviews and ratings, and I want to organise them myself and so on
and so forth. So that's why I made this website and accompanying content
management system called: *Flammie reviews everything*
EOT
echo >> $outfile
echo "## Index by date" >> $outfile
echo >> $outfile
for f in 2*.markdown ; do
    year=$(echo $f | cut -d- -f 1)
    month=$(echo $f | cut -d- -f 2)
    day=$(echo $f | cut -d- -f 3)
    title=$(fgrep "title:" -m 1 $f | sed -e 's/^title: "//' -e 's/"$//')
    link=${f%.markdown}.html
    echo "* $day.$month.$year: [$title]($link)" >> $outfile
done
popd
