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

job_name='4Typm_Comp'

bin_dir='/scratch/lfs/ebecerra/TYPHIMURIUM/partitions/04/'

#list_fasta_file='/path/something.txt'
#Or better generated this files from bin_dir
#Let the user guess and worry the less

########## Output ###############################################

o_bin_dir='/scratch/lfs/ebecerra/TYPHIMURIUM/o_bins_fasta4/'

#Temp directory used for this script, after finish all parallel jobs could be deleted
#WARNING no delete temp dir before finishing all the jobs launched by this script
temp_dir='/scratch/lfs/ebecerra/SCRIPTS/typm_completness/4temp/' #This directorie will be eliminated

#Log files storage folder


##### for future scripts simplify everything and delete log variables #####
log_dir="${temp_dir}log/" #If not existent create new directory
err_dir="${temp_dir}err/"

########## Parallel #############################################

parallel_number='463' #If division is not exact this will give parallel_number + 1
partner_file='/scratch/lfs/ebecerra/SCRIPTS/typm_completness/checkm_partner.sh'

####################################################################
#-p check for the existence of the directory and creates a new one if necessary
mkdir -p $log_dir
mkdir -p $err_dir
mkdir -p $o_bin_dir
mkdir -p $temp_dir

ls ${bin_dir} > ${temp_dir}list_of_bins.txt

let lines_list_file=`wc --lines ${temp_dir}list_of_bins.txt | cut -d ' ' -f 1`
let chunks=${lines_list_file}/${parallel_number}

mkdir ${temp_dir}divisions/ #Creating a new dir for the splitted files
cd ${temp_dir}divisions/
#WARNING THIS SCRIPT IT IS NO LONGER IN THE BEGINNING $PWD
split --lines  $chunks ${temp_dir}list_of_bins.txt fastas_ #split output is in $PWD
#--numeric-suffixes only reach 99 after that a error happends error
#split: output file suffixes exhausted
#Max parallel number using letter suffixes 676

ls fastas_*  > ${temp_dir}splitted_files.txt

cd ${temp_dir}
number_of_jobs=`wc --lines splitted_files.txt | cut -d ' ' -f 1`
contador=0
paste splitted_files.txt | while read -r splitted_file;
do
qsub -N "${job_name}${contador}"\
 "${partner_file}" -o "${log_dir}${job_name}${contador}.log" -e "${err_dir}${job_name}${contador}.err"\
 -v splitted_file=${splitted_file},temp_dir=${temp_dir},bin_dir=${bin_dir},o_bin_dir=${o_bin_dir},contador=${contador}
#Exportation of $contador is for testing
echo $contador
echo "This file with genomes is now in the queue: ${temp_dir}divisions/${splitted_file}"
let contador="$contador + 1" #let sometimes cries without quotes
done

echo "SUCCESS: The launching of ${number_of_jobs} jobs is done"
echo 'WARNING: Do not delete the temp directories before completely finishing all the launched jobs'
echo 'Please have fun while the computer works for you'
