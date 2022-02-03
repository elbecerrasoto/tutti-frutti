#!/usr/bin/R

# Libraries ---------------------------------------------------------------------

library(tidyverse)
library(cowplot)
library(forcats)

# Color Palettes ----------------------------------------------------------------

library(nord)
moose_pond <- nord(palette='moose_pond')
red_mountain <- nord(palette='red_mountain')
algoma_forest <- nord(palette='algoma_forest')
afternoon_prarie <- nord(palette='afternoon_prarie')
mix_nord <- c(moose_pond, red_mountain, algoma_forest, afternoon_prarie)
length(mix_nord)

library(palettetown)
tangela <- pokepal('tangela')
polygon <- pokepal('porygon')
mix_palettetown <- c(tangela, polygon)
length(mix_palettetown)

library(rcartocolor)
sunset <- carto_pal(n=7, name='Sunset')
peach <- carto_pal(n=7, name='Peach')
mix_rcarto <- c(sunset, peach)
length(mix_rcarto)

# Defaults ----------------------------------------------------------------------

# Color Palette
PALETTE <- mix_nord

# Golden Ratio
golden <- (1 + sqrt(5))/2

# Select a system font
FONT <- 'TeX Gyre Bonum'
# Font Size
SIZE <- 14

# Theme for plots
theme_set(theme_minimal_grid(SIZE, font_family=FONT))

# Loading -----------------------------------------------------------------------

analco_personas <- read_tsv('personas.tsv')
analco_opiniones <- read_tsv('preguntas_abiertas.tsv')

head(analco_personas)
head(analco_opiniones)

# Separating Opinions -----------------------------------------------------------

# Adding persona
analco_opiniones <- analco_opiniones %>% 
  mutate(persona = 1:nrow(analco_opiniones)) %>% 
  select(persona, everything())

# Converting persona to chr
analco_personas <- mutate(analco_personas, persona=as.character(persona))
analco_opiniones <- mutate(analco_opiniones, persona=as.character(persona))

# Separating opinions, one per row
analco_opiniones <- analco_opiniones %>% 
  separate_rows(sentir, sep=',') %>% 
  separate_rows(problematica, sep=',') %>%
  separate_rows(propuesta, sep=',') %>%
  separate_rows(opcional, sep=',')

# Factor Ordering for Plotting -----------------------------------------------------------

analco_personas <- analco_personas %>% 
  mutate(edad = fct_rev(fct_infreq(edad)),
         frecuencia = fct_rev(fct_infreq(frecuencia)),
         horario = fct_rev(fct_infreq(horario)),
         motivo = fct_rev(fct_infreq(motivo)),
         gustan = fct_rev(fct_infreq(gustan)))

analco_opiniones <- analco_opiniones %>% 
  mutate(sentir = fct_rev(fct_infreq(sentir)),
         problematica = fct_rev(fct_infreq(problematica)),
         propuesta = fct_rev(fct_infreq(propuesta)),
         opcional = fct_rev(fct_infreq(opcional)))

# Filter No Visitado ------------------------------------------------------------

visit_analco_personas <- analco_personas %>% 
  filter(visitado)

visit_analco_opiniones <- analco_opiniones %>% 
  filter(!( is.na(sentir) & is.na(problematica) & is.na(propuesta) & is.na(opcional) ))

# Plotting ----------------------------------------------------------------------

plot_bars <- function(x, var1, var2, position='stack', palette=PALETTE, height=12){
  p <- ggplot(x)+
    geom_bar(aes_string(x=var1, fill=var2), position=position)+
    coord_flip()+
    ggtitle(paste0(var1, '-', var2))+
    scale_fill_manual(values = palette)
  filename <- paste0(var1, '_', var2, '_', position, '.svg')
  ggsave(filename, p, units='cm', width=golden*height, height=height)
  print(paste0('Saving ', filename))
  print(p)
}

# Single Bars -------------------------------------------------------------------

names(visit_analco_opiniones)

# Sentir ------------------------------------------------------------------------

visit_analco_opiniones %>% 
  plot_bars('sentir', 'sentir')

# Problematica ------------------------------------------------------------------

visit_analco_opiniones %>% 
  plot_bars('problematica', 'problematica')

# Propuesta ---------------------------------------------------------------------

visit_analco_opiniones %>% 
  plot_bars('propuesta', 'propuesta')

# Opcional ----------------------------------------------------------------------

visit_analco_opiniones %>% 
  plot_bars('opcional', 'opcional')

# Multiple Bars -----------------------------------------------------------------

# Edad-Visitado -----------------------------------------------------------------

analco_personas %>% 
  plot_bars('edad', 'visitado', 'stack')

analco_personas %>% 
plot_bars('edad', 'visitado', 'dodge')

# Frecuencia-Gustan -------------------------------------------------------------

visit_analco_personas %>% 
  plot_bars('frecuencia', 'gustan', 'stack')

visit_analco_personas %>% 
  plot_bars('frecuencia', 'gustan', 'dodge')

# Horario-Motivo ----------------------------------------------------------------

visit_analco_personas %>% 
  plot_bars('horario', 'motivo', 'stack')

visit_analco_personas %>% 
  plot_bars('horario', 'motivo', 'dodge')

# Problematica-Propuesta --------------------------------------------------------

visit_analco_opiniones %>% 
  plot_bars('problematica', 'propuesta', 'stack')

visit_analco_opiniones %>% 
  plot_bars('problematica', 'propuesta', 'dodge')
