#!/usr/bin/env Rscript
library(tidyverse)
library(ggmap)
library(ggthemes)
library(plyr)

# Suggestion:
# Put the north, mark the grid

eco_map <- readRDS('eco_map.Rds')

stations <- read_csv('DATA/eco_bici_stations.csv')
directions <- read_csv('DATA/all_dir.csv')

#directions

ggmap(eco_map)+
  geom_path(data = directions, 
            aes(x = lon, y = lat, group = from_to),
            color = '#ff6666',
            alpha = 1/20)+
  geom_point(data = stations, aes(x = longitude, y = latitude),
             color = '#6666ff',
             size = 1/2)+
  theme_fivethirtyeight()
ggsave(filename = 'all_routes_eco_stations_alp20_v2.1.png', units = 'cm', width = 16, height = 14)


p <- ggmap(eco_map)+
  geom_path(data = directions, 
            aes(x = lon, y = lat, group = from_to),
            color = '#ff6666')+
  geom_point(data = stations, aes(x = longitude, y = latitude),
             color = '#6666ff',
             size = 1/2)+
  theme_fivethirtyeight()

#ggsave(plot = p, filename = 'all_routes_eco_stations.png', units = 'cm', width = 16, height = 14)

