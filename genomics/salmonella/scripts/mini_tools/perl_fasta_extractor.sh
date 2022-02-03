#!/bin/bash


# In the conditional specify how many sequnces you want
# For example ($i >= 6 && $i <= 40)
# This means extract from the seq number 6 to the seq number 40

perl -e '$i = 0; while (<>){    if (m/^>/) {$i++;} if ($i >= 6 && $i <= 40) {print;}     }' core_gene_alignment.aln > fasta.fna