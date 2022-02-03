#!/bin/bash

FORWARD=$1
REVERSE=$2
dir_output=$3
dir_input=$4
dir_logs=$5
kmer=$6
CPUs_per_JOB=$7

fna_name=${FORWARD%%.*}
mkdir $dir_output/$fna_name
abyss-pe np=$CPUs_per_JOB -C "$dir_output/$fna_name" name=$fna_name k=$kmer in="${dir_input}/$FORWARD ${dir_input}/$REVERSE" > $dir_logs/${fna_name}.log
