#!/usr/bin/python

# -*- coding: utf-8 -*-
"""
Created on Fri Feb 23 18:55:58 2018

@author: ebecerra
"""

# Magic Triangle for the Probability Course

import random
import turtle
import math
import time

#random.seed(352767)

T_START=[0,-200] # x,y coordinates
# Starts at the middle of the base
T_LENGHT=500
T_SPEED=4
PEN_SIZE=5
D_PEN_SIZE=3
ITERATIONS=10000
WAIT=60

turtle.reset()
turtle.pensize(PEN_SIZE)
turtle.speed(T_SPEED)
turtle.shape('turtle')

def Slope(x1,y1,x2,y2):
    m = (y2 - y1) / (x2 - x1)
    return(m)

def TurtleTriangleEquilateral(startPoint,sideLenght):
    turtle.pu() # turtle.penup
    turtle.goto(T_START[0],T_START[1])
    turtle.pd() #turtle.pendown Start drawing
    turtle.fd(sideLenght/2.0) # Turtle forward also it could be turtle.forward
    x1=turtle.pos()[0] # Coordinates of right edge
    y1=turtle.pos()[1] # Coordinates of right edge
    turtle.lt(120) # Turtle turn anti clock-wise also .left
    turtle.fd(sideLenght)
    x2=turtle.pos()[0] 
    y2=turtle.pos()[1]
    turtle.lt(120)
    turtle.fd(sideLenght)
    x3=turtle.pos()[0] 
    y3=turtle.pos()[1]
    turtle.lt(120)
    turtle.fd(sideLenght/2.0)
    #print "Right Slope is \t" + str(round(Slope(x1,y1,x2,y2), 3))
    #print "Left Slope is \t" + str(round(Slope(x2,y2,x3,y3), 3))
    #print "Base Slope is \t" + str(round(Slope(x3,y3,x1,y1), 3))
    Tcoords = [ [x1,y1], [x2,y2], [x3,y3] ]
    return (Tcoords)
    
def ShootInsideTriangle(T_Vertices):
    m_right = Slope(T_Vertices[0][0],T_Vertices[0][1],T_Vertices[1][0],T_Vertices[1][1])
    m_left = Slope(T_Vertices[2][0],T_Vertices[2][1],T_Vertices[1][0],T_Vertices[1][1])
    # Generating random x coor and y coor
    x_point = random.randint( int( T_Vertices[2][0] )+1, int( T_Vertices[0][0] )-1 )
    y_point = random.randint( int( T_Vertices[0][1] )+1, int( T_Vertices[1][1] )-1 )
    # Check if the point is outside the Triangle    
    x_line_r = ((y_point - T_Vertices[0][1]) / m_right) + T_Vertices[0][0]    
    x_line_l = ((y_point - T_Vertices[0][1]) / m_left) + T_Vertices[2][0]
    while (x_point > x_line_r) or (x_point < x_line_l):
        # Generating random x coor and y coor
        x_point = random.randint( int( T_Vertices[2][0] )+1, int( T_Vertices[0][0] )-1 )
        y_point = random.randint( int( T_Vertices[0][1] )+1, int( T_Vertices[1][1] )-1 )
        x_line_r = ((y_point - T_Vertices[0][1]) / m_right) + T_Vertices[0][0]    
        x_line_l = ((y_point - T_Vertices[0][1]) / m_left) + T_Vertices[2][0]
    shoot_coord = [x_point, y_point]
    return shoot_coord

def Distance(x1,y1,x2,y2):
    dist = math.sqrt( (x2 - x1)**2 + (y2 - y1)**2  )  
    return dist
    

################ Main Program ################

# Draw the triangle
T_Vertices = TurtleTriangleEquilateral(T_START,T_LENGHT)

# Start at a Random point inside it
StartCoords = ShootInsideTriangle(T_Vertices)
turtle.pu()
turtle.goto(StartCoords[0],StartCoords[1])
turtle.dot(D_PEN_SIZE)

# Roll a three faced dice and approach to that Vertice
for i in range(ITERATIONS):
    if i > 30:
        turtle.speed(6)
    if i > 60:
        turtle.speed(8)
    if i > 100:
        turtle.speed(10)
    if i > 300:
        turtle.hideturtle()
        turtle.speed(0)
    if i > 400:
        turtle.tracer(0,0)
    turtle.pu()
    rolled = random.randint(1,3)
    if (rolled == 1): # Right vertice
        d = Distance(StartCoords[0], StartCoords[1], T_Vertices[0][0], T_Vertices[0][1])
        turtle.setheading( turtle.towards(T_Vertices[0][0],T_Vertices[0][1]) )
        turtle.fd(d/2)
        turtle.dot(D_PEN_SIZE)
    elif (rolled == 2): # Upper vertice
        d = Distance(StartCoords[0], StartCoords[1], T_Vertices[1][0], T_Vertices[1][1])
        turtle.setheading( turtle.towards(T_Vertices[1][0],T_Vertices[1][1]) )
        turtle.forward(d/2)
        turtle.dot(D_PEN_SIZE)
    elif (rolled == 3): #Left vertice
        d = Distance(StartCoords[0], StartCoords[1], T_Vertices[2][0], T_Vertices[2][1])
        turtle.setheading( turtle.towards(T_Vertices[2][0],T_Vertices[2][1]) )
        turtle.forward(d/2)
        turtle.dot(D_PEN_SIZE)
    else:
        print 'Something went wrong'
    StartCoords = turtle.pos()
    
turtle.update()

time.sleep(WAIT)
