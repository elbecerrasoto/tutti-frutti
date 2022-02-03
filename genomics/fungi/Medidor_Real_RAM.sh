#!/bin/bash
# 12 Sep 2017
# Author Emanuel Becerra

track_file='RAM_watcher.txt'

echo -e \\n"This program is infinite, stop it with Ctrl + C"\\n

while [ true ];
do
	sleep 10m
	echo -e \\n"###############################"\\n >> $track_file
	date >>  $track_file
	free -h >> $track_file
	echo -e \\n"###############################"\\n >> $track_file
done
