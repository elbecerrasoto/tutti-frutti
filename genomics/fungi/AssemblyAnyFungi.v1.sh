#!/bin/bash
# 03 Octuber 2017
# Author Emanuel Becerra

# This script assembles a bunch of genomes in the target directory
# Using the abyss a software

################ Parameters ################

# Change the input
# and output directories paths
# according to your needs

# Also you can tweak the other parameters

dir_input=$PWD/$1
# dir_input='/home/ubuntu/FUNGAL_DNA_BASESPACE_DATA'

# Output directory
# Default name to current date and time (at $PWD)
dir_output="`date +%d-%b-%y_%Hh%Mm%Ss`"
dir_logs="$dir_output/logs"

# Regular expression to differentiate
# Forward and reverse reads
# (bash grep regex)
# Forward regex
F_regex='1\.fastq'
R_regex='2\.fastq'

# CPUs per assembly
CPUs_per_JOB='4'

# Guidelines
# 8 CPUs for a fastq pair of 1.5 Gb each
# consumes like 15 Gb RAM and takes 2 hours

# Abyss parameters
kmer=24

################ Main Code ################

mkdir $dir_output
mkdir $dir_logs

FORWARDS=`ls $dir_input | grep $F_regex | sort`
REVERSES=`ls $dir_input | grep $R_regex | sort`

parallel --xapply bash AbyssLoop.sh {1} {2} {3} {4} {5} {6} {7}\
 ::: $FORWARDS ::: $REVERSES ::: $dir_output ::: $dir_input ::: $dir_logs ::: $kmer ::: $CPUs_per_JOB

