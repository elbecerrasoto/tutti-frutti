#!/bin/bash
# 15 April 2018
# Author Emanuel Becerra

re_input=$1

parser='re2AFN.py'
output="`date +%d%b%y_%Hh%Mm%Ss`.sif"

python re2AFN.py $re_input | sed -r 's/S=\{([0-9]+)\}/S START \1/' | sed '1d;3d' | sed 's/,/ /' | sed 's/->/ /' > $output
