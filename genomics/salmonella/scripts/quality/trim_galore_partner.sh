#!/bin/bash
#PBS -M ebecerra@ufl.edu
#PBS -m ae
#PBS -l nodes=1:ppn=1
#PBS -l pmem=1gb
#PBS -l walltime=24:00:00
#PBS -V

echo "The current directory is:`pwd`"
echo "The current date is: `date`"
echo "The current user is: `whoami`"
echo "The current server is: `hostname`"

module load cutadapt
module load fastqc
module load trim_galore

trim_galore --version

paste ${temp_dir}/${split_file_f} ${temp_dir}/${split_file_r} | while read -r forward reverse;
do
trim_galore --fastqc --paired --clip_R1 20 --clip_R2 20 --three_prime_clip_R1 20 --three_prime_clip_R2 20\
 -o "${o_dir}" "${fastq_dir}/${forward}" "${fastq_dir}/${reverse}"
done
