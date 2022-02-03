#!/usr/bin/env Rscript

library(tidyverse)
library(ggthemes)

file <- 'introduccion_redes_neuronales.csv'
b18_intro_neu_net <- read_csv(file)

b18_intro_neu_net$nivel <- ordered( as.factor(b18_intro_neu_net$nivel),
                   levels = c('licenciatura', 'maestría', 'doctorado'))

b18_intro_neu_net <- arrange(b18_intro_neu_net, nivel, nombre)
b18_intro_neu_net <- mutate(b18_intro_neu_net, procedencia = as.factor(procedencia))

summary(b18_intro_neu_net)

View(b18_intro_neu_net)

ggplot(data = b18_intro_neu_net,
       aes(x = nivel, y = procedencia, color = nivel))+
  geom_jitter()+
  theme_fivethirtyeight()

ggplot(data = b18_intro_neu_net, aes(x = nivel, fill = nivel))+
  geom_bar() + geom_bar( aes(x = procedencia , fill = procedencia) )

ggplot(data = b18_intro_neu_net, aes(x = nivel, fill = procedencia))+
  geom_bar(position = 'fill')

ggplot(data = b18_intro_neu_net, aes(x = nivel, fill = procedencia))+
  geom_bar(position = 'dodge')

ggplot(data = b18_intro_neu_net, aes(x = nivel))+
  geom_bar()+facet_wrap(~procedencia)


library(scales)

( b18_table <- as.tibble(prop.table(table(b18_intro_neu_net$nivel, b18_intro_neu_net$procedencia))) )
( b18_table_2 <- as.tibble( table(b18_intro_neu_net$nivel, b18_intro_neu_net$procedencia)) )

  
names(b18_table) <- c("nivel", "procedencia", "Freq")
ggplot(b18_table, aes(x = nivel, y = Freq, fill = procedencia)) +
  scale_y_continuous(labels = percent_format()) + 
  geom_col(position = "dodge")

b18_table_2
names(b18_table_2) <- c("nivel", "procedencia", "Freq")
b18_table_2 <- arrange(b18_table_2, Freq)

ggplot(b18_table_2, aes(x = nivel, y = Freq, fill = procedencia)) +
  geom_bar(position = 'dodge', stat = 'identity')

b18_table_3 <- b18_table_2

# b18_table_3$nivel <- ordered( as.factor(b18_table_2$nivel),
#                               levels = c('licenciatura' ,'maestría', 'doctorado') )
# b18_table_3 <- arrange(b18_table_3, nivel)

b18_table_3$procedencia <- ordered( as.factor(b18_table_2$procedencia),
  levels = c('CIC DCC' ,'CIC MCIC', 'UPIITA', 'CIDETEC', 'CIC MCC') )


ggplot(b18_table_3, aes(x = nivel, y = Freq, fill = procedencia)) +
  geom_bar(position = 'dodge', stat = 'identity')+
  scale_fill_brewer(type = 'qual', palette = 7)+
  scale_x_discrete(labels=c("Doctorado", "Licenciatura", "Maestría"))+
  theme_fivethirtyeight(base_size = 12, base_family = 'TeX Gyre Bonum')+
  guides( fill = guide_legend (title="") )+
  theme( # Inside X,Y text
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12) )+
  ggtitle('Asistentes: Introducción a Redes Neuronales',
          subtitle = 'Dr. Humberto Sossa')

# ggsave('intro_nnet.svg', units = 'cm', width = 20, height = 14)

library(wesanderson)
royal1 <- wes_palette(5, name = "Royal1", type = "continuous")
ggplot(b18_table_3, aes(x = nivel, y = Freq, fill = procedencia)) +
  geom_bar(position = 'dodge', stat = 'identity')+
  scale_fill_manual(values = royal1)+
  scale_x_discrete(labels=c("Doctorado", "Licenciatura", "Maestría"))+
  theme_fivethirtyeight(base_size = 12, base_family = 'TeX Gyre Bonum')+
  guides( fill = guide_legend (title="") )+
  theme( # Inside X,Y text
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12) )+
  ggtitle('Asistentes: Introducción a Redes Neuronales',
          subtitle = 'Dr. Humberto Sossa')
ggsave('intro_nnet.svg_02.svg', units = 'cm', width = 20, height = 14)
ggsave('intro_nnet.svg.png', units = 'cm', width = 20, height = 14)

ggplot(b18_table_3, aes(x = nivel, y = Freq, fill = procedencia)) +
  geom_bar(position = 'dodge', stat = 'identity')+
  scale_fill_manual(values = wes_palette(5, name = "GrandBudapest1", type = "continuous"))+
  scale_x_discrete(labels=c("Doctorado", "Licenciatura", "Maestría"))+
  theme_fivethirtyeight(base_size = 12, base_family = 'TeX Gyre Bonum')+
  guides( fill = guide_legend (title="") )+
  theme( # Inside X,Y text
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12) )+
  ggtitle('Asistentes: Introducción a Redes Neuronales',
          subtitle = 'Dr. Humberto Sossa')
ggsave('intro_nnet.svg_03.svg', units = 'cm', width = 20, height = 14)



ggplot(b18_table_3, aes(x = nivel, y = Freq, fill = procedencia)) +
  geom_bar(position = 'dodge', stat = 'identity')+
  scale_fill_manual(values = rainbow(5, s = 0.5))+
  scale_x_discrete(labels=c("Doctorado", "Licenciatura", "Maestría"))+
  theme_fivethirtyeight(base_size = 12, base_family = 'TeX Gyre Bonum')+
  guides( fill = guide_legend (title="") )+
  theme( # Inside X,Y text
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12) )+
  ggtitle('Asistentes: Introducción a Redes Neuronales',
          subtitle = 'Dr. Humberto Sossa')
ggsave('intro_nnet.svg_04.svg', units = 'cm', width = 20, height = 14)



ggplot(b18_table_3, aes(x = nivel, y = Freq, fill = procedencia)) +
  geom_bar(position = 'dodge', stat = 'identity')+
  scale_fill_manual(values = wes_palette('Moonrise3', n = 5, type = 'continuous'))+
  scale_x_discrete(labels=c("Doctorado", "Licenciatura", "Maestría"))+
  theme_fivethirtyeight(base_size = 12, base_family = 'TeX Gyre Bonum')+
  guides( fill = guide_legend (title="") )+
  theme( # Inside X,Y text
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12) )+
  ggtitle('Asistentes: Introducción a Redes Neuronales',
          subtitle = 'Dr. Humberto Sossa')
ggsave('intro_nnet.svg_05.svg', units = 'cm', width = 20, height = 14)




# n <- 5
# x <- rainbow(n, s = 0.5)
# heat.colors(n)
# terrain.colors(n)
# topo.colors(n)
# cm.colors(n)
# 
# cols <- function(a) image(1:5, 1, as.matrix(1:5), col=a, axes=FALSE , xlab="", ylab="")
# cols(x)


write_csv(b18_intro_neu_net, 'b18_intro_neu_net.csv')



