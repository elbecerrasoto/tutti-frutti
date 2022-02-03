#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l pmem=16gb
#PBS -l walltime=2:00:00
#PBS -V
[[ -d $PBS_O_WORKDIR ]] && cd $PBS_O_WORKDIR #Change to directory of this script -d option is true if the file exists

echo "#### Job Number ${contador} #### "
echo "#### Job ID ${PBS_JOBID} ####"
echo "The current directory is:`pwd`"
echo "The current date is: `date`"
echo "The current user is: `whoami`"
echo "The current server is: `hostname`"

mkdir ${o_bin_dir}copy_of_genomes${contador}/ #The parallel bin_dir #NEW bin
mkdir ${o_bin_dir}output_${contador}/ #Making the parallel o_bin #NEW o_bin

#########################################

#Populate the new parallel bin_dir

paste ${temp_dir}divisions/${splitted_file} | while read -r genome;
do
cp ${bin_dir}${genome} ${o_bin_dir}copy_of_genomes${contador}/
done
##########################################

#Running checkm

module load python
module load checkm
module load hmmer

time checkm lineage_wf -t 1 -x fasta --reduced_tree ${o_bin_dir}copy_of_genomes${contador}/ ${o_bin_dir}output_${contador}/
