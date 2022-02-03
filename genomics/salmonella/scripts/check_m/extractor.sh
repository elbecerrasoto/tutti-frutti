#!/bin/bash

#Author:Emanuel Becerra Soto cc

#Redirect output to a file is more control is needed

#The bash script is always executed in $PWD

##### This code copy and rename some files ########

##### Magic Variables ###########

dir_ospades='/scratch/lfs/ebecerra/TYPHIMURIUM/o_spades/' #Dir with the directories of genomes
file_fasta='contigs.fasta' #File to extract from  spades output 

dir_new_names='/scratch/lfs/ebecerra/TYPHIMURIUM/bins_fasta/'
###################################

mkdir -p $dir_new_names
ls $dir_ospades | sort -n > ~/list_of_genomes.txt #The temp file is in the home dir

paste ~/list_of_genomes.txt | while read -r name;
do
cp ${dir_ospades}/${name}/${file_fasta} $dir_new_names #copy to the new directory
mv ${dir_new_names}/${file_fasta} ${dir_new_names}/${name} #Change the name
echo -n  '.' #-n no new line
done


###### This parts manages the extension of the file ###############
ls -1 $dir_new_names | sort -n > ~/old_names.txt
sed 's/_1_val_1.fq.gz/.fasta/g' ~/old_names.txt > ~/new_names.txt #2> redirection of sterr

paste ~/old_names.txt ~/new_names.txt | while read -r OLD NEW;
do
mv ${dir_new_names}/${OLD} ${dir_new_names}/${NEW}
done

#######################################


echo 'Removing all the temporary files'
rm  ~/list_of_genomes.txt ~/old_names.txt ~/new_names.txt

echo 'Execution Finished'
