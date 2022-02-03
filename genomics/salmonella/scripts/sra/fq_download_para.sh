#!/bin/bash
#11 January 2016
#Author: Emanuel Becerra Soto
#GNU license
#No run using qsub
#Cause The cluster may not allow you to submit jobs from working nodes in the cluster.

#This script takes a list of fastq_files
#then split them in a certain number
#and then runs a program in each split
#The program to run is specified in the parallel_partner.sh file

echo "The current directory is:`pwd`"
echo "The current date is: `date`"
echo "The current user is: `whoami`"
echo "The current server is: `hostname`"


######## Input #################################################

all_ids_file='/scratch/lfs/ebecerra/SCRIPTS/typhimurium_download/remaining_to_download.txt'

################################################
                                               #
job_name='Typm_Download'                       #
                                               #
################################################

########## Parallel #############################################

parallel_number='200' #If division is not exact this will give parallel_number + 1
partner_file='/scratch/lfs/ebecerra/SCRIPTS/typhimurium_download/sra_partner.sh'

########## Output ###############################################
o_dir='/scratch/lfs/ebecerra/SCRIPTS/typhimurium_download/fastq_typm/'

#In this directory the spades output is going to be stored
temp_dir='/scratch/lfs/ebecerra/SCRIPTS/typhimurium_download/temp/' #This directorie will be eliminated

#Log files storage folder

log_dir='/scratch/lfs/ebecerra/log_files/typm/' #If not existent create new directory
err_dir='/scratch/lfs/ebecerra/log_files/typm/'

####################################################################
#-p check for the existence of the directory and creates a new one is necessary
mkdir -p $log_dir
mkdir -p $err_dir
mkdir -p $o_dir
mkdir -p $temp_dir

cd $temp_dir

let total_lines=`wc -l ${all_ids_file} | cut -d ' ' -f 1`
let chunks=${total_lines}/${parallel_number}

split --lines  $chunks ${all_ids_file} sra_ #--numeric-suffixes only reach 99 after that error
#split: output file suffixes exhausted

ls sra_*  > all_sra.txt

i=0
paste all_sra.txt | while read -r sra_names_chunk;
do
qsub -N "${job_name}${i}" "${partner_file}" -o "${log_dir}${job_name}${i}.log" -e "${err_dir}${job_name}${i}.err" \
 -v sra_names_chunk=$sra_names_chunk,temp_dir=$temp_dir,o_dir=$o_dir,i=$i
#Exportation of $i for testing
echo $i
echo $sra_names_chunk
let i="$i + 1" #let sometimes cries without quotes
done

#Changes
# & backgound command removed
# $PBS_O_HOST removed variable
# Cannot remove temp files because are job running
#Idea is that qsub return a finish variable
echo "Execution finished"
