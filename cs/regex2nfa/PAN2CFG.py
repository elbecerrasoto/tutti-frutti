#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 16 19:36:51 2018

@author: ebecerra
"""

'''
Realizar un programa que convierta la descripcion
de un automata de pila a una gramatica libre de contexto


{f,g,h}         // Conjunto de estados del autómata de pila
f               // estado inicial
{h}             // conjunto de estados de aceptación
{c,/}           // conjunto de símbolos de la pila (gamma) unión lambda (representada por "/"
(f, c, /; g, c)
(g, b, /; g, c)
(g, c, c; h, /)

El programa debe ser una aplicación de consola escrita en cualquier lenguaje de
programación que sea portable.
Un ejemplo de invocación sería:

python ap2glc.py archivo.ap
'''

import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("AutomataFile", help="Ingrese .ap file (formato automata de pila)")
args = parser.parse_args()

in_file = args.AutomataFile

############## Reading the Automata ##############

my_automaton = open(in_file, 'r')

Automaton={}
Estados=[]
Finales=[]
SPila=[]
Transiciones=[]
Automaton['Estados']=Estados
Automaton['Finales']=Finales
Automaton['SPila']=SPila
Automaton['Transiciones']=Transiciones
n_line = 1
for line in my_automaton:
    line = line.strip()
    if n_line == 1:
        for char in line:
            if char == '{' or char == '}' or char == ',':
                continue
            else:
                Automaton['Estados'].append(char)  
    if n_line == 2:
        Automaton['Inicial']=line
    if n_line == 3:
        for char in line:
            if char == '{' or char == '}' or char == ',':
                continue
            else:
                Automaton['Finales'].append(char)         
    if n_line == 4:
        for char in line:
            if char == '{' or char == '}' or char == ',':
                continue
            else:
                Automaton['SPila'].append(char)
    if n_line >= 5:
        line = re.sub(' ', '', line)
        line = re.sub(',', '', line)
        line = re.sub(';', '', line)
        line = re.sub('\(', '', line)
        line = re.sub('\)', '', line)
        Automaton['Transiciones'].append(line)
    n_line += 1

############## Four Steps to convert to Context Free Grammar ##############

def paso1(inicial,finales):
    for final in finales:
        print('S -> <{},/,{}>'.format(inicial,final))

def paso2(estados):
    for estado in estados:
        print('<{},/,{}> -> /'.format(estado,estado))

def paso3(transiciones,estados):
    for transicion in transiciones:
        if transicion[2] != '/':
            for estado in estados:
                print('<{},{},{}> -> {} <{},{},{}>'.format(transicion[0],
                      transicion[2],estado,transicion[1],transicion[3],
                      transicion[4],estado))
        else:
            continue

def paso4(transiciones,estados,simbolos_pila):
    for transicion in transiciones:
        if transicion[2] == '/':
            for w in simbolos_pila:
                for k in estados:
                    for r in estados:
                        print('<{},{},{}> -> {} <{},{},{}> <{},{},{}>'.format(
                                transicion[0],w,r,transicion[1],
                                transicion[3],transicion[4],k,k,w,r))                      
        else:
            continue

############## Main Code ##############
 
paso1(Automaton['Inicial'],Automaton['Finales'])
paso2(Automaton['Estados'])
paso3(Automaton['Transiciones'],Automaton['Estados'])
paso4(Automaton['Transiciones'],Automaton['Estados'],Automaton['SPila'])

