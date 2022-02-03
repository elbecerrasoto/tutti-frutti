#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May  2 19:14:37 2018

@author: ebecerra
"""

IN=[1,3,5,9,11,13,15,17,19,23,25,27]

def pAllMultMod(group,mod,long=False):
    if not long:
        desfase = 0
        for idx,elem in enumerate(group):
            for i in range(idx+desfase,len(group)):
                mult = elem * group[i] % mod
                print('{} X{} {} = {}'.format(elem,mod,group[i],mult))
    else:
        for idx,elem in enumerate(group):
            for i in range(0,len(group)):
                mult = elem * group[i] % mod
                print('{} X{} {} = {}'.format(elem,mod,group[i],mult))
      
pAllMultMod(IN,28,True)
