#!/bin/bash
#PBS -M ebecerra@ufl.edu
#PBS -m ae
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=1
#PBS -l pmem=500mb
#PBS -V
[[ -d $PBS_O_WORKDIR ]] && cd $PBS_O_WORKDIR #Change to directory of this script -d option is true if the file exists

#Emanuel Becerra Soto
#04 February 2016


module load sra

paste ${temp_dir}/${sra_names_chunk} | while read -r sra_id;
do
	fastq-dump --split-files --readids --gzip -O "${o_dir}"  "$sra_id" 
done



#Line need to be out of spaces
#If not modify IFS variable

#This option --origfmt mainteins the original header
#The original header usually doesnt provide relevant information
#origfmt over rides the readids option
#Always run fastq-dump with the readids option


############# Waysof read line by line in BASH #########################################


#module load sra
#while read -r line;  #sh script.sh file.txt #IFS vacio creo que para ser robusto a lineas con espacios
#do
#        fastq-dump --split-files -X 1 --readids -Z  "$line" 
#done < "$1"

#for i in $(cat file.txt); #Another way of interating over a file
#do
#	echo "$i"
#done
