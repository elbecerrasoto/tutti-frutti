#!/usr/bin/env Rscript

library(tidyr)
library(ggplot2)
library(ggthemes)
library(RColorBrewer)
library(plotly)

file <- '/home/ebecerra/MCC/Mate/Tarea3.2/U28.v2.csv'
out_dir <- '/home/ebecerra/MCC/Mate/Tarea3.2/'
u28 <- read.csv(file,header = F)

u28_w <-  spread(u28, key = V1, value = V3)[,-1]
u28_m <- as.matrix(u28_w)

plot_ly(
  z = u28_m,
  type = "heatmap",
  colorscale = rainbow(2)
)

plot_ly(
  x= as.character(u28_m[,1]),
  y= as.character(u28_m[1,]),
  z = u28_m,
  type = "heatmap"
)

#write.csv(u28_m,paste(out_dir,'u29.csv',sep=''))

u28$V1 <- as.factor(u28$V1)
u28$V2 <- as.factor(u28$V2)
ggplot(data = u28, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = V3)) +
  scale_fill_gradientn(colours = rainbow(12)) +
  xlab('X title')+ylab('Y title')+ggtitle('Title')+
  theme(
    # Plot title
    plot.title = element_text(size = 22),
    # Outside X,Y text
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )

ggplot(data = u28, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = V3)) +
  xlab('X title')+ylab('Y title')+ggtitle('Title')+
  theme(
    # Plot title
    plot.title = element_text(size = 22),
    # Outside X,Y text
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )

ggplot(data = u28, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = V3)) +
  scale_fill_gradientn(colours = brewer.pal(n = 12, name = 'YlGnBu')) +
  xlab('X title')+ylab('Y title')+ggtitle('Title')+
  theme(
    # Plot title
    plot.title = element_text(size = 22),
    # Outside X,Y text
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )


ggplot(data = u28, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = V3)) +
  scale_fill_gradientn(colours = c("#d53e4f","#f46d43","#fdae61","#fee08b","#e6f598","#abdda4","#ddf1da")) +
  xlab('X title')+ylab('Y title')+ggtitle('Title')+
  theme(
    # Plot title
    plot.title = element_text(size = 22),
    # Outside X,Y text
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )


u28_2 <- u28
u28_2$V3 <- as.factor(u28_2$V3)


internet <-  c("#d53e4f","#f46d43","#fdae61","#fee08b","#e6f598","#abdda4","#ddf1da")
Comb12<- c(brewer.pal(n = 9, name = 'Set1'),brewer.pal(n = 3, name = 'Dark2'))

ggplot(data = u28_2, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = V3)) +
  scale_fill_manual(values = Comb12) +
  xlab('X title')+ylab('Y title')+ggtitle('Title') +
  theme(
    # Plot title
    plot.title = element_text(size = 22),
    # Outside X,Y text
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )


Cust <- c(brewer.pal(n =11, name = 'Spectral'),brewer.pal(n = 11, name = 'PuOr')[11])
ggplot(data = u28_2, aes(x = V1, y = V2)) +
  geom_tile(aes(fill = V3)) +
  scale_fill_manual(values = Cust) +
  xlab('Left Element')+ylab('Right Element')+ggtitle('Group U 28') +
  theme(
    # Plot title
    plot.title = element_text(size = 22),
    # Outside X,Y text
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    # Inside X,Y text
    axis.text.x = element_text(size = 18),
    axis.text.y = element_text(size = 18),
    # Configure lines and axes
    axis.ticks.x = element_line(colour = "black"), 
    axis.ticks.y = element_line(colour = "black"), 
    # Plot background
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "grey70",size = 0.8), 
    panel.grid.minor = element_line(colour = "grey70",size = 0.8)
  )

# Display palettes
display.brewer.all()
display.brewer.pal(n = 8, name = 'Dark2')
# brewer.pal(n = 4, name = 'Set1')
