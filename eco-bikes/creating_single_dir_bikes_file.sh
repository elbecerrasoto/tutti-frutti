#!/bin/bash

# This program adds a new field to a bunch of csv
# and then concatenates them into a single big csv

# Emauel Becerra Soto March 2019

###### Definitions ######

target_dir='DIRECTIONS'
out_dir='out_single'

out_file='all_dir.csv'

header='m,km,miles,seconds,minutes,hours,leg,lon,lat,from_to'

###### Main Program ######

out="$out_dir/$out_file"
echo -n '' > $out

echo -e \\n'Starting'

# Delete first line and add a new field
# Output everything onto the same file
ls $target_dir | while read -r  line;
do
	sed "1d ; s/$/,${line%.csv}/" $target_dir/$line >> $out
	echo -n '.'
done

# Adding header
if [ -e $out ]; then
	sed -i "1 i $header" $out
else
	echo "Error: output file doesn't exit"
	exit 25
fi

echo -e \\n'Done'\\n
