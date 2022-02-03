#!/usr/bin/env Rscript

library(tidyverse)
library(ggthemes)
library(wesanderson)

file <- 'hector_model.csv'
errors <- read_csv(file)
errors2 <- gather(errors, e_in, e_out, key = 'error_type', value = 'MSE' )
errors2$error_type <- factor(errors2$error_type, levels = c('e_out','e_in'))

ggplot( data = errors2, aes(x = epoch, y = MSE, color = error_type) )+
  geom_point()+
  geom_line( stat="smooth", method = "lm", formula = y ~ x,
             size = 0.7,
             alpha = 0.5)+
  ggtitle('Epochs vs Errors')+
  xlab('Epochs') + ylab('MSE')+
  scale_color_manual( values=c (wes_palette("Royal1")[2], wes_palette("Royal1")[1]),
                      name=NULL,
                      labels=c("E out", "E in" ) )+
  theme_fivethirtyeight()

