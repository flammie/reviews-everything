#!/bin/bash
# converts google maps data fetched using google takeout into flammie reviews
# everything.
#
# Google Takeout json format as seen on 2022, https://takeout.google.com
. review-funcs.bash
set -x
if test $# != 1 ; then
    echo "Usage: $0 GOOGLE-TAKEOUT-MAPS-REVIEWS.json"
    exit 1
fi

jq '.features[].properties.Location."Business Name" ' "$1" > gmaps.names
while read -r line ; do
    name=$line
    review=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.\"Review Comment\"" "$1")
    stars=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.\"Star Rating\"" "$1" | head -n 1)
    score=$((stars * 2))
    lat=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.Location.\"Geo Coordinates\".Latitude" "$1")
    long=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.Location.\"Geo Coordinates\".Longitude" "$1")
    address=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.Location.Address" "$1")
    google=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.\"Google Maps URL\"" "$1")
    timing=$(jq ".features[] | select(.properties.Location.\"Business Name\" ==
    $name) | .properties.Published" "$1")
    outfile=docs/$(filenamify "${name//\"}").markdown
    echo "writing to $outfile"
    echo "---" > "$outfile"
    echo "title: $name" >> "$outfile"
    echo "date: $timing" >> "$outfile"
    echo "score: $score" >> "$outfile"
    echo "latitude: $lat" >> "$outfile"
    echo "longitude: $long" >> "$outfile"
    echo "---" >> "$outfile"
    echo "$review" | fmt >> "$outfile"
    echo >> "$outfile"
    echo "> parts of review were originally posted on [Google Maps page of " \
        >> "$outfile"
    echo "  $name]($google)" >> "$outfile"
    echo "---" >> "$outfile"
    echo "Score: $(score_stars $score)" >> "$outfile"
    echo "Address: $address" >> "$outfile"
    echo -n "Map location: [$long $lat" >> "$outfile"
    echo "(OpenStreetMap)](https://www.openstreetmap.org/?mlat=$lat&mlon=$long&zoom=12)"    >> "$outfile"
done <  gmaps.names

