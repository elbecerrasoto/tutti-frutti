#!/usr/bin/env Rscript

# Importing, Function and Global ------------------------------------------

library(tidyverse)
library(ggmap)
library(ggthemes)

register_google(key='key')

# Loading the data --------------------------------------------------------

file <- 'cal_houses.csv'
cal_houses <- read_csv(file)

# Removing 1st col that has no meaning
cal_houses <- cal_houses %>%
  select(-(X1))

cal_houses$Cluster <-
  factor(cal_houses$Cluster, levels = 0:3)

# Getting the maps --------------------------------------------------------


# San Francisco -----------------------------------------------------------

# san_francisco_map <- get_map('San Francisco, CA', source='stamen',
#                          zoom=10, maptype='terrain')
#
# saveRDS(san_francisco_map, 'san_francisco_map.Rds')
san_francisco_map  <- readRDS('san_francisco_map.Rds')

# ggmap(san_francisco_map)+
#   geom_point(data=cal_houses,
#              aes(x=Longitude,
#                  y=Latitude,
#                  color=Cluster),
#              size=4, alpha=0.4, shape=15)+
#   scale_colour_viridis_d()+
#   theme_fivethirtyeight()

p_sf <- ggmap(san_francisco_map)+
  geom_point(data=cal_houses,
             aes(x=Longitude,
                 y=Latitude,
                 color=Cluster),
             size=2, alpha=0.2, shape=15)+
  scale_colour_brewer(palette='Set1')+
  theme_fivethirtyeight()
p_sf

# Los Angeles -------------------------------------------------------------

los_angeles_map <- get_map('Los Angeles, CA', source='stamen',
                         zoom=10, maptype='terrain')

# saveRDS(los_angeles_map, 'los_angeles_map.Rds')
los_angeles_map  <- readRDS('los_angeles_map.Rds')

p_la <- ggmap(los_angeles_map)+
  geom_point(data=cal_houses,
             aes(x=Longitude,
                 y=Latitude,
                 color=Cluster),
             size=2, alpha=0.2, shape=15)+
  scale_colour_brewer(palette='Set1')+
  theme_fivethirtyeight()
p_la


# Plotting California -----------------------------------------------------

# california_map <- get_map('California, USA', source='stamen',
#                           zoom = 6, maptype='terrain')

# saveRDS(california_map, 'california_map.Rds')
california_map  <- readRDS('california_map.Rds')

p_cal <- ggmap(california_map)+
  geom_point(data=cal_houses,
             aes(x=Longitude,
                 y=Latitude,
                 color=Cluster),
             size=2, alpha=0.2, shape=15)+
  scale_colour_brewer(palette='Set1')+
  theme_fivethirtyeight()
p_cal


# Plotting Outliers -------------------------------------------------------

condition <- cal_houses$Cluster == 1 | cal_houses$Cluster == 3
outliers_houses <- cal_houses[condition,]
View(outliers_houses)

p_cal_out <- ggmap(california_map)+
  geom_point(data=outliers_houses,
             aes(x=Longitude,
                 y=Latitude,
                 color=Cluster), size=3, shape=15)+
  scale_colour_brewer(palette='Set1', drop=FALSE)+
  theme_fivethirtyeight()
p_cal_out

exp(1.7)*1e5
exp(5)*1e5

# Seeing the results ------------------------------------------------------

# San Francisco
p_sf

# Los Angeles
p_la

# California
p_cal

# Outliers
p_cal_out


san_jose_map <- get_map('San Jose, CA', source='stamen',
                           zoom = 10, maptype='terrain')

p_la <- ggmap(san_jose_map)+
  geom_point(data=cal_houses,
             aes(x=Longitude,
                 y=Latitude,
                 color=Cluster),
             size=2, alpha=0.2, shape=15)+
  scale_colour_brewer(palette='Set1')+
  theme_fivethirtyeight()
p_la

p_sf

p_cal <- ggmap(california_map)+
  geom_point(data=cal_houses,
             aes(x=Longitude,
                 y=Latitude,
                 color=Cluster),
             size=2)+
  scale_colour_brewer(palette='Set1')+
  theme_fivethirtyeight()
p_cal

