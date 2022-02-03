#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 15 21:02:16 2018

@author: ebecerra
"""

################## Imports ##################

import sys
import argparse

################## Functions ##################

def parse(expr):
    def _helper(iter):
        items = []
        for item in iter:
            if item == '(':
                result, closeparen = _helper(iter)
                if not closeparen:
                    raise ValueError("bad expression -- unbalanced parentheses")
                items.append(result)
            elif item == ')':
                return items, True
            else:
                items.append(item)
        return items, False
    return _helper(iter(expr))[0]

def anyNotList(list_in):    
    Base=True
    for elem in list_in:
        if isinstance(elem,list):
            Base=False
    return Base

def rightInnerMost(curr_list):
    # Base Case Not indented lists
    if anyNotList(curr_list):
        jcl=''.join(curr_list) 
        return [curr_list,jcl]
    Levels=[]
    original=curr_list
    Nested=True
    while Nested:
        Nested=False
        for idx,item in enumerate(curr_list):
            if isinstance(item,list):
                Levels.append(idx)
                curr_list=item
                Nested=True
                break
    for idx,lev in enumerate(Levels):
        if idx == 0:
            Target='original[%s]' % lev
        if idx != 0:
            Target=Target + '[%s]' % lev
    jcl=''.join(curr_list)
    jcl_s = '"(%s)"' % jcl         
    Target=Target + '=' + jcl_s
    #print(Target)
    exec(Target)
    return [curr_list,original]
  
def catUnionBase(internal):
    anchors=[]
    auto=[]
    if len(internal) == 3:
        if internal[1] == '.':
            auto.append("0,{}->1".format(internal[0]))
            auto.append("1,/->2")
            auto.append("2,{}->3".format(internal[2]))
            anchors.append(3)
            lastOne=3
            root=0
            arms=1
            return {'arms':arms, 'anchors':anchors,
                    'lastOne':lastOne, 'root':root, 'auto':auto}
        elif internal[1] == '|':
            auto.append("0,/->1")
            auto.append("1,{}->2".format(internal[0]))
            auto.append("0,/->3")            
            auto.append("3,{}->4".format(internal[2]))
            anchors.append(2)
            anchors.append(4)
            lastOne=4
            root=0
            arms=2
            return {'arms':arms,'anchors':anchors,
                    'lastOne':lastOne, 'root':root, 'auto':auto}
        else:
            print("Error: Bad Operator")
            sys.exit()
    else:
        print('Wrong length')
        
def catUnionUpper(internal,lastOne,arms,anchors,root):
    auto=[]
    if len(internal) == 3:
        if internal[1] == '.':
            for i in range(0,arms):
                auto.append("{},/->{}".format(anchors[i],lastOne + 1))
                auto.append("{},{}->{}".format(lastOne + 1,internal[2], lastOne + 2))
                lastOne += 2
                anchors[i]=lastOne                
            return {'arms':arms, 'anchors':anchors, 'lastOne':lastOne, 'root':root, 'auto':auto}
        elif internal[1] == '|':
            auto.append("{},/->{}".format(lastOne + 1,root)) # To root
            auto.append("{},/->{}".format(lastOne + 1,lastOne + 2)) # To the new arm
            auto.append("{},{}->{}".format(lastOne + 2, internal[2], lastOne + 3))
            root=lastOne + 1
            lastOne += 3
            arms += 1
            anchors.append(lastOne)
            return {'arms':arms, 'anchors':anchors, 'lastOne':lastOne, 'root':root, 'auto':auto}
        else:
            print("Error: Bad Operator")
            sys.exit()
    else:
        print('Wrong length')
  
def starUpper(internal,lastOne,arms,anchors,root):
    auto=[]
    if internal[-1] == '*' and len(internal) == 2:
        for i in range(0,arms):
            auto.append("{},/->{}".format(anchors[i],root))                
        return {'arms':arms, 'lastOne':lastOne, 'anchors':anchors, 'root':root, 'auto':auto}
    else:
        print("Error: Bad Operator")
        sys.exit()
        
def nonIdentedBase(internal):
    auto=[]
    if len(internal) == 1: # Single character
        auto.append("0,{}->1".format(internal[0]))
        return {'arms':1, 'lastOne':1, 'anchors':[1], 'root':0, 'auto':auto}
    elif len(internal) == 2 and internal[-1] == '*':
        auto.append("0,{}->1".format(internal[0]))
        auto.append("1,/->0".format(internal[0]))
        return {'arms':1, 'lastOne':1, 'anchors':[1], 'root':0, 'auto':auto}
    elif len(internal) == 3:
        return catUnionBase(internal)       
    else:
        print("Error: Wrong Length")
        sys.exit()
    
def single(internal,lastOne,arms,anchors,root):
    auto=[]
    if len(internal) == 1:
        auto.append("{},{}->{}".format(lastOne,internal[0],lastOne+1))
        lastOne += 1
        return {'arms':arms, 'lastOne':lastOne, 'anchors':anchors, 'root':root, 'auto':auto}
    else:
        print("Error: Wrong Length")
        sys.exit()
    
################## Main Code ##################

'''
Single Char "a"
Single Concatenation "a.b"
Single Union "a|b"
Single Star "a*"
Single Star "(a)*"

Star always outside parentheses
For more than two operations
use parenthesis for each new operation

Examples:
"(a.b).c"
"(a.c)*"
"((a|b).c)*"
"(((a.c)*)|f)*"
"((a.b).c)|d"
"((a.b).c)|d)*"
"((((a.b).d)*).c).c"
"((((((((a.b).d)*).c).c)|f)|r)*).e)|e"
'''

# Reading User's input

parser = argparse.ArgumentParser()
parser.add_argument("RegEx", help="Input a valid Regular Expression \
                    Example: ((a|b).c)*")
args = parser.parse_args()

input_re = args.RegEx

# First print
print("AFN-/:")

Automaton=[]
Rex=parse(input_re)
cyc_while=0
oneMore=False
startAsFinal=False
while True:
    cyc_while = 1 + cyc_while
    rootAsFinal=False    
    boolean_NonIndented=anyNotList(Rex)
    Ret_rim=rightInnerMost(Rex)
    internal=Ret_rim[0] # current analyzed string
    if cyc_while == 1: # Base cases
        if boolean_NonIndented: #Resolve for a simple regex
            Result=nonIdentedBase(internal)
            arms=Result['arms']
            anchors=Result['anchors']
            lastOne=Result['lastOne']
            root=Result['root']
            auto=Result['auto']
            Automaton += auto
            if len(internal) == 2 and internal[-1] == '*':
                startAsFinal=True
            break
        else: # Has indented regexs
            if len(internal) == 1: # Single item, probably a star
                Result=single(internal,0,1,[1],0)
                arms=Result['arms']
                anchors=Result['anchors']
                lastOne=Result['lastOne']
                root=Result['root']
                auto=Result['auto']
                Automaton += auto
            else: # The base case for Union or Cat
                Result=catUnionBase(internal)
                arms=Result['arms']
                anchors=Result['anchors']
                lastOne=Result['lastOne']
                root=Result['root']
                auto=Result['auto']
                Automaton += auto
    else: # Not a base case
        if len(internal) == 2: # Len 2 is a kleene Star
            Result=starUpper(internal,lastOne,arms,anchors,root)
            arms=Result['arms']
            anchors=Result['anchors']
            lastOne=Result['lastOne']
            root=Result['root']
            rootAsFinal=True
            auto=Result['auto']
            Automaton += auto
        else:
            Result=catUnionUpper(internal,lastOne,arms,anchors,root)
            arms=Result['arms']
            anchors=Result['anchors']
            lastOne=Result['lastOne']
            root=Result['root']
            auto=Result['auto']
            Automaton += auto
    # Rex=Ret_rim[1] # Prepare for next iteration
    if oneMore:        
        break
    if anyNotList(Rex):
        oneMore=True
        
# Print Initial and Final States
# Start
print('S={%s}' % root)

# Finals
finals = []
if rootAsFinal:
    finals.append(root)
    finals += anchors
elif startAsFinal:
    finals.append(root)
    finals += anchors
else:
    finals = anchors

print('F={', end='')
cycs = 0
for char in finals:
    cycs += 1
    if cycs == len(finals): # Final print with out comma
        print('{}'.format(char), end='')
    else:
        print('{},'.format(char), end='') 
print('}\n', end='')

# Printing all the transitions    
for transition in Automaton:
    print(transition)    
    