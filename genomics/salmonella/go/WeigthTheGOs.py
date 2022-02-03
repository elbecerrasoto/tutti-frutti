#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Sat Jan 28 18:54:03 2017

@author: ebecerra
"""

import csv
import os

WorkDir='/home/ebecerra/UF/06_Nov/New_Join/Finals'
os.chdir(WorkDir)

IDs={}

print 'Getting Started'+'\n\n'

filename='/home/ebecerra/UF/06_Nov/New_Join/Finals/Overlap.PanProkkaTnSeq.csv'
with open(filename,'rb') as f:
    reader=csv.reader(f)
    line=1
    for row in reader:
        if line==1: # Skip the header
            header=','.join(row)
            line+=1
            continue
        name=row[1]
        # Ordering of the list 0:Cov 1:Line
        Info=[]
        strRow=','.join(row)
        if name in IDs:
            cov_stored=IDs[name][0]
            cov_coming=row[0]
            if cov_coming > cov_stored:
                Info=[row[0],strRow]
                IDs[name]=Info
        else:
            Info=[row[0],strRow]
            IDs[name]=Info
        line+=1    

      
new_file_name='NonRepetitionsOverlap.csv'
print 'Writing a new file: '+new_file_name+'\n\n'
with open(new_file_name,'w') as out_file:
    out_file.write(header+'\n')
    for key in IDs.keys():
        out_file.write(IDs[key][1]+'\n')