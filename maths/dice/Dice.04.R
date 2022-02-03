#!/usr/bin/env Rscript

library(ggplot2)

#set.seed(9517)

# Max and min integer of set.seed
#set.seed(2147483647)
#set.seed(-2147483647)

args = commandArgs(trailingOnly=TRUE)
ITER <- eval(parse(text=args[1]))
ITER <- sort(ITER)
CARAS <- args[2]

# test if there is at least 2 arguments: if not, return an error
if (length(args) != 2)
{
  print("Two arguments must be supplied")
  stop('Rscript Dice.03.R c(1,2,3,4,5,n_times) Face_Number', call.=FALSE)
}



#ITER <- c(10, 20, 30, 40, 50, 100, 1000, 10000, 100000, 1000000)
#ITER <-  c(10, 20, 30, 40, 50, 100, 1000, 10000)
#ITER <- c(10000, 100000)
#CARAS <- 20

# Some cool colors
# The order inside the vectors: Dark, light
greens <- c('#02731a', '#03ad28')
reds <-c('#8c0720', '#ea0b35')
purples <-c('#6c006c', '#bb00bb')
oranges <-c('#d87600', '#ff8c00')
yellows <- c('#ffea00', '#fff262')
blues <- c('#0086e6', '#33aaff')

Colors6 <- list(greens, reds, purples, oranges, yellows, blues)

Roll_A_Dice_A_Lot <- function(iter,faces)
{
  rolled <-numeric()
  for ( i in 1:iter)
  {
    rolled[i] <- sample(1:faces,1)
  }
  return(rolled)
}

# This functions returns the bar plot of counts
# of the first entry of a data frame
# The first entry should be a Factor and have the name Face
CoolBarPlot_For_Rolled_Dices <- function(Data1,fill_color,silhouette_color,PlotName)
{
  ggplot()+geom_bar(data=Data1, aes(x=Face), fill = fill_color, color = silhouette_color, alpha=0.25, size=1.5)+
    xlab('Faces')+ylab('Counts')+ggtitle(PlotName)+
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
}

# Dark color makes a good fill color with low alpha
# Ligth color looks good as a silhouette

######################## Main Code ########################


# ITER must be sorted
i <- 1
# Main Loop
for (n_iter in ITER)
{
  # Roll a CARAS sided dice 
  rolled.df <- data.frame( Roll_A_Dice_A_Lot(n_iter, CARAS) )
  names(rolled.df) <- 'Face'
  rolled.df$Face <- factor(rolled.df$Face)
  # Check if we still have free colors
  if ( length(Colors6) < i)
  {
    i <- 1
    CoolBarPlot_For_Rolled_Dices(rolled.df, Colors6[[i]][1], Colors6[[i]][2], paste (n_iter, 'Rollings', 'for', CARAS, 'faces', sep=' ') )
    ggsave(  paste( n_iter, 'Rollings', i, '.svg', sep = '_' ), 
             width = 15, height = 10, units = "cm")
  }
  else
  {
    # Check if with to remove the plural in Rolling(s)
    if (n_iter == 1)
    {
      CoolBarPlot_For_Rolled_Dices(rolled.df, Colors6[[i]][1], Colors6[[i]][2], paste (n_iter, 'Rollings', 'for', CARAS, 'faces', sep=' ') )
      ggsave(  paste( n_iter, 'Rolling', i, '.svg', sep = '_' ), 
               width = 15, height = 10, units = "cm")
    }
    else
    {
      CoolBarPlot_For_Rolled_Dices(rolled.df, Colors6[[i]][1], Colors6[[i]][2], paste (n_iter, 'Rollings', 'for', CARAS, 'faces', sep=' ') )
      ggsave(  paste( n_iter, 'Rollings', i, '.svg', sep = '_' ), 
               width = 15, height = 10, units = "cm")
    }
  }
  i <-  i + 1
}


Tope <- 10000
STEPS <- 1000

step_size <- floor( Tope/STEPS )
cajita <- numeric()
peque <- 0
names_step <- numeric()
Prob <- list()
Counts <- list()
i <- 1
while (peque < Tope)
{
  peque <- peque + step_size
  cajita <- c(cajita, Roll_A_Dice_A_Lot(step_size,6))
  Prob[[i]] <- as.numeric( table(cajita)/length(cajita) )
  Counts[[i]] <- as.numeric( table(cajita) )
  names_step <- c(names_step, peque)
  i <- i + 1
  #print(paste('.',i,sep=''))
}

mt_proba <- do.call("rbind",Prob)
df_proba <- as.data.frame(mt_proba)
names(df_proba) <- c('F1', 'F2', 'F3', 'F4', 'F5', 'F6')
df_proba$Rolls <- names_step
df_proba <- df_proba[,c(7,1:6)]
df_proba[1:5,]
 library(reshape2)
mdf_p <- melt(df_proba, id.vars = "Rolls",
              measure.vars = c('F1', 'F2', 'F3', 'F4', 'F5', 'F6'))
mdf_p[1:10,]


library(reshape2)
library(ggthemes)
library(RColorBrewer)


# geom_line is suitable froor time series
ggplot( mdf_p, aes(x=Rolls, y=value, color=variable) )+
  geom_line()+
  xlab('Rolls')+ylab('Relative Frecuency')+ggtitle('10,000 Dice Rolls Relative Frecuency')+
  scale_color_brewer(palette = 'Set1' ,name='',
                       labels=c("Face 1", "Face 2", "Face 3", "Face 4", "Face 5", "Face 6"))+
  theme_calc()+geom_smooth()
  

# geom_line is suitable froor time series
ggplot( mdf_p, aes(x=Rolls, y=value, color=variable) )+
  geom_smooth()+
  xlab('Rolls')+ylab('Relative Frecuency')+ggtitle('10,000 Dice Rolls Relative Frecuency')+
  scale_color_brewer(palette = 'Set1' ,name='',
                     labels=c("Face 1", "Face 2", "Face 3", "Face 4", "Face 5", "Face 6"))+
  theme_calc()

ggsave( 'DiceRolls.10000.Cal_Smoothed02.svg', 
        width = 15, height = 10, units = "cm")




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




df_proba[1:10,]

ggplot()

?geom_line()


ggplot(data = mdf_p, aes(x = variable, y = Rolls)) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradient(low = "yellow", high = "red") +
  scale_x_discrete(expand = c(0, 0)) + scale_y_continuous(expand = c(0,0))

ggplot(data = mdf_p, aes(x = variable, y = Rolls)) +
  geom_tile(aes(fill = value)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_gradient2(low = "red", high = "green", mid = "black")


ggplot(data = mdf_p, aes(x = variable, y = Rolls)) +
  geom_tile(aes(fill = value)) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_gradientn(colours = rainbow(7)) +
  xlab('Faces')+ggtitle('Relative Frecuency of Dice Rolls ')+
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
  

ggsave( 'RainbowMap_DiceRolls.10000.16.15.svg', 
         width = 16, height = 15, units = "cm")


?ggsave

step_size
df_proba[45:50,]
dim(df_proba)

ggplot(df.heatmap, aes(x = Var1, y = Var2, fill = score)) + geom_tile() +
  scale_fill_gradient2(low = "red", high = "green", mid = "black")



# mt_counts <- do.call("rbind",Counts)
# df_counts <- as.data.frame(mt_counts)
# names(df_counts) <- c('Face1', 'Face2', 'Face3', 'Face4', 'Face5', 'Face6')
# df_counts$Rolls <- names_step
# df_counts <- df_counts[,c(7,1:6)]
# df_counts[1:5,]

# mdf_counts <- melt(df_counts, id.vars = "Rolls",
#               measure.vars = c('Face1', 'Face2', 'Face3', 'Face4', 'Face5', 'Face6'))
# mdf_counts[1:10,]
# 
# 
# ggplot(data = mdf_counts, aes(x = variable, y = Rolls)) +
#   geom_tile(aes(fill = value)) +
#   scale_fill_gradient(low = "yellow", high = "red") +
#   scale_x_discrete(expand = c(0, 0)) + scale_y_continuous(expand = c(0,0))







