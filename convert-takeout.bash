#!/bin/bash
# converts google maps data fetched using google takeout into flammie reviews
# everything.
#
# Google Takeout json format as seen on 2022, https://takeout.google.com
. review-funcs.bash
if test $# != 1 ; then
    echo "Usage: $0 GOOGLE-TAKEOUT-MAPS-REVIEWS.json"
    exit 1
fi

jq '.features[].properties.location.name ' "$1" > gmaps.names
while read -r line ; do
    name=$line
    review=$(jq ".features[] | select(.properties.location.name == $name) |
        .properties.review_text_published" "$1")
    stars=$(jq ".features[] | select(.properties.location.name == $name) |
        .properties.five_star_rating_published" "$1" | head -n 1)
    score=$((stars * 2))
    lat=$(jq ".features[] | select(.properties.location.name == $name) |
        .geometry.coordinates[1]" "$1")
    long=$(jq ".features[] | select(.properties.location.name == $name) |
        .geometry.coordinates[0]" "$1")
    address=$(jq ".features[] | select(.properties.location.name == $name) |
        .properties.location.address" "$1")
    google=$(jq ".features[] | select(.properties.location.name == $name) |
        .properties.google_maps_url" "$1")
    timing=$(jq ".features[] | select(.properties.location.name == $name) |
        .properties.date" "$1")
    outfile=docs/$(filenamify "${name//\"}").markdown
    echo "writing to $outfile"
    echo "---" > "$outfile"
    echo "title: $name" >> "$outfile"
    echo "date: $timing" >> "$outfile"
    echo "score: $score" >> "$outfile"
    echo "latitude: $lat" >> "$outfile"
    echo "longitude: $long" >> "$outfile"
    echo "---" >> "$outfile"
    echo "# Flammie reviews: ${name//\"/}" >> "$outfile"
    echo >> "$outfile"
    echo "$review" | sed -e 's/^"//' -e 's/"$//' | fmt >> "$outfile"
    echo >> "$outfile"
    echo "> parts of review were originally posted on [Google Maps page of" \
        >> "$outfile"
    echo "  $name](${google//\"/})" >> "$outfile"
    echo "---" >> "$outfile"
    echo "> *Score*: $(score_stars $score)" >> "$outfile"
    echo "> *Address*: $address" >> "$outfile"
    echo -n "> *Map location*: [$long $lat" >> "$outfile"
    echo "(OpenStreetMap)](https://www.openstreetmap.org/?mlat=$lat&mlon=$long&zoom=12)"    >> "$outfile"
done <  gmaps.names

