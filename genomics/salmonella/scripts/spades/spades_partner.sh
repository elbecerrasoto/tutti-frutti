#!/bin/bash
#PBS -M ebecerra@ufl.edu
#PBS -m ae
#PBS -l nodes=1:ppn=8
#PBS -l pmem=1gb
#PBS -l walltime=48:00:00
#PBS -V
[[ -d $PBS_O_WORKDIR ]] && cd $PBS_O_WORKDIR #Change to directory of this script -d option is true if the file exists

echo "The current directory is:`pwd`"
echo "The current date is: `date`"
echo "The current user is: `whoami`"
echo "The current server is: `hostname`"

module load python
module load spades

echo "The current python version is: `python --version`"

paste ${temp_dir}${split_file_f} ${temp_dir}${split_file_r} | while read -r forward reverse;
do
mkdir -p ${o_dir}${forward}
time spades.py -t 8 --pe1-1 ${fastq_dir}${forward} --pe1-2 ${fastq_dir}${reverse} -o ${o_dir}${forward}
done
