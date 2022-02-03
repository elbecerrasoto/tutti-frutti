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

fastq_dir='/scratch/lfs/ebecerra/SCRIPTS/TYPHIMURIUM/clean_fq/'
f_file='/scratch/lfs/ebecerra/SCRIPTS/TYPHIMURIUM/f_typm_clean.txt'
r_file='/scratch/lfs/ebecerra/SCRIPTS/TYPHIMURIUM/r_typm_clean.txt'

################################################
                                               #
job_name='Typm_Assembly'                        #
                                               #
################################################

########## Parallel #############################################

parallel_number='300' #If division is not exact this will give parallel_number + 1
partner_file='/scratch/lfs/ebecerra/SCRIPTS/typm_assembly/spades_partner.sh'

########## Output ###############################################
o_dir='/scratch/lfs/ebecerra/SCRIPTS/TYPHIMURIUM/o_spades/'

#In this directory the spades output is going to be stored
temp_dir='/scratch/lfs/ebecerra/SCRIPTS/typm_assembly/temp/' #This directorie will be eliminated

#Log files storage folder

log_dir='/scratch/lfs/ebecerra/SCRIPTS/typm_assembly/log/' #If not existent create new directory
err_dir='/scratch/lfs/ebecerra/SCRIPTS/typm_assembly/log/'

####################################################################
#-p check for the existence of the directory and creates a new one is necessary
mkdir -p $log_dir
mkdir -p $err_dir
mkdir -p $o_dir
mkdir -p $temp_dir

cd $temp_dir

let num_lines_f_file=`wc -l ${f_file} | cut -d ' ' -f 1`
let chunks=${num_lines_f_file}/${parallel_number}

let num_lines_r_file=`wc -l ${r_file} | cut -d ' ' -f 1`
let chunks=${num_lines_r_file}/${parallel_number}

split --lines  $chunks ${f_file} f_ #--numeric-suffixes only reach 99 after that error
split --lines  $chunks ${r_file} r_
#split: output file suffixes exhausted

#unzip '*' #When unziping all

ls f_*  > all_split_files_f.txt
ls r_*  > all_split_files_r.txt

contador=0
paste all_split_files_f.txt all_split_files_r.txt | while read -r split_file_f split_file_r;
do
qsub -N "${job_name}${contador}"\
 "${partner_file}" -o "${log_dir}${job_name}${contador}.log" -e "${err_dir}${job_name}${contador}.err" \
 -v split_file_f=${split_file_f},split_file_r=${split_file_r},temp_dir=${temp_dir},o_dir=${o_dir},contador=${contador},fastq_dir=${fastq_dir}
#Exportation of $i for testing
echo $contador
echo "The pair sent to the queue is: $split_file_f $split_file_r"
let contador="$contador + 1" #let sometimes cries without quotes
done

#Changes
# & backgound command removed
# $PBS_O_HOST removed variable
# Cannot remove temp files because are job running
#Idea is that qsub return a finish variable
echo "Execution finished"
