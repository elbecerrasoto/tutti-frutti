#! /usr/bin/env Rscript

library(tidyverse)

stations_l <- jsonlite::fromJSON('stations.json', flatten=TRUE)

class(stations_l)
str(stations_l)

stations_df <- as_tibble(stations_l[[1]])
stations_df

names(stations_df)

vars_to_keep <- c('id','name','districtName',
                  'nearbyStations','stationType',
                  'location.lat','location.lon')

stations <- stations_df[vars_to_keep]
stations <- rename(stations, latitude = location.lat,
       longitude = location.lon)

stations

library(ggmap)

