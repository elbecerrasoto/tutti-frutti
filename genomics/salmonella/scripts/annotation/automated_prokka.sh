#!/bin/bash
#PBS -l nodes=1:ppn=8
#PBS -l pmem=800mb
#PBS -l walltime=02:00:00
#PBS -V

#This script runs Prokka on a list of Contigs
#The output is a directory with contigs

module load prokka
module load barrnap
module load rnammer

## Catching the variable from the para;elizer script ##

contigs_dir=$bin_dir
o_dir=$o_bin_dir
contigs_file="${temp_dir}divisions/${splitted_file}"

echo "$contigs_dir"
echo "$o_dir"
echo "$contigs_file"

###### required options ##############

#contigs_dir='/scratch/lfs/ebecerra/examples/contigs_examples'

#####################################

#Make the output dir
#And the list of contigs file

#o_dir="${PWD}/o_dir" #o_dir recived by paralelizer
#mkdir -p $o_dir

#contigs_file="${o_dir}/contigs_list.txt" #contigs_dir recived by paralelizer
#ls $contigs_dir > $contigs_file

############################################


old_headers="${o_dir}/old_headers/"
mkdir -p "${o_dir}/old_headers/" #dir for bakup the old names

trim_ext_file="${o_dir}/trim_ext.txt" #Trimming the extension for better printing options
sed 's/\.fasta//' ${contigs_file} > ${trim_ext_file}

echo -e \\n'All working files have been created'\\n
echo "The INPUT directory is ${contigs_dir}"
echo "The OUTPUT directory is ${o_dir}"
echo -e \\n'Starting PROKKA execution'\\n
echo -e 'On the following genomes'\\n
#cat $contigs_file
echo
####### PROKKA execution ######

i='1'
paste ${contigs_file} ${trim_ext_file} | while read -r CONTIG TCONTIG
do
	grep '>' ${contigs_dir}/${CONTIG} > ${old_headers}/headers_${TCONTIG}.txt
	trim_contig_header.sed -i ${contigs_dir}/${CONTIG}
	time prokka --locustag "${TCONTIG}"  --cpus 8 ${contigs_dir}/${CONTIG} --outdir "${o_dir}/prokka_${TCONTIG}"
	echo -n  '.'
	echo -n "${i}"
	let i="$i + 1"
done

####### PROKKA end ######

echo -e \\n\\n'Finishig Execution'\\n
