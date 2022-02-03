#!/usr/bin/env Rscript

###### Libraries and Settings ######

library(tidyverse)
# How many significant digits to show
options(pillar.sigfig = 5)
library(ggmap)
# API key for google maps
register_google(key='a_key_here')
library(ggthemes)

###### Loading the data ######

# Geotagging  of ecobici stations
stations <- read_csv('DATA/eco_bici_stations.csv')

# All the trips made during October 2018
october <- read_csv()
october <- read_csv('DATA/2018-10.csv')

head(stations)
head(october) 

# Removing the trips that started and ended at the same station
october <- filter(october, Ciclo_Estacion_Retiro != Ciclo_Estacion_Arribo)

# Matrix of start, end stations
matrix_trips <- as.matrix(october[c('Ciclo_Estacion_Retiro', 'Ciclo_Estacion_Arribo')])

# Partition the matrix by:

# The already ordered
in_order <- matrix_trips[ matrix_trips[,1] < matrix_trips[,2] , ]

# The unordored
not_in_order <- matrix_trips[ matrix_trips[,1] > matrix_trips[,2] , ]     

# Just switch columns and voila
now_in_order <- not_in_order[,c(2,1)]

# Combine both ordered
single_direction <- rbind(in_order, now_in_order)

# Use the matrix to name all made routes
collapsed_directions <- apply(single_direction, 1, paste, collapse = '_')
routes_oct <- unique(collapsed_directions)
routes_oct <- sort(routes_oct)

# Number of uniques routes on October
length(routes_oct)

routes_oct[1:10]

###### Obtaining directions for all pairs ######

# Building a lookup table for the coordinates of the stations
lookup_coords <- split( stations[c('longitude','latitude')], stations['id'])

# Comparing stations names

# Coming from coordinates tables
st_names_stations <- names(lookup_coords) %>%
  as.numeric() %>%
  sort()

# Coming from october trips
st_names_oct <- routes_oct %>% 
  str_split(pattern = '_', simplify = TRUE) %>%
  as.vector() %>%
  as.numeric() %>%
  unique() %>%
  sort()

# Symetric difference between sets
sym_diff <- function(a,b) setdiff(union(a,b), intersect(a,b))

# Stations that don't match
sym_diff(st_names_oct, st_names_stations)

# Stations that are not in the lookup of coordinates
not_in_lookup <- setdiff(st_names_oct, st_names_stations)

pattern_remove_left <- sapply(not_in_lookup, paste, '_', sep = '')
pattern_remove_rigth <- sapply(not_in_lookup, function(x) paste('_',x,sep=''))

patt_remove <- c(pattern_remove_left, pattern_remove_rigth)

# find the position to remove
bool_remove <- rep(F,length(routes_oct))
for(patt in patt_remove){
  match_to_remove <- str_detect(routes_oct, patt)
  bool_remove <- bool_remove | match_to_remove
}

# Remove the matches
routes_oct <- routes_oct[!bool_remove]

# Vector with stations to download
routes_oct[1:10]
length(routes_oct)

# Find the stations that are not yet downloaded
already_downloaded <- list.files('./DIRECTIONS') %>%
  str_replace( pattern = '\\.csv', replacement = '')

not_yet_downloaded <- setdiff(routes_oct, already_downloaded)
length(not_yet_downloaded)
not_yet_downloaded[1:10]

# Calculates path from start to end
# by bike
get_direction <- function(start, end){
  route(start, end, mode = 'bicycling', structure = 'route')
}

# Wrapper function for the apply
in_bulk_get_directions <- function(start_end){
  result <- tryCatch({
    print(start_end)
    l_start_end <- strsplit(start_end, split = '_' , perl = T)
    start <- as.numeric(lookup_coords[[ l_start_end[[1]][1] ]])
    end <- as.numeric(lookup_coords[[ l_start_end[[1]][2] ]])
    dir_df <- get_direction(start, end)
    write_csv(dir_df, paste('DIRECTIONS/', start_end, '.csv', sep = ''))
    return(dir_df)
    },
    error = function(e){
      message <- paste('ERROR in', 'stations:', start_end, sep = ' ')
      print(message)
      return(message)
    }
  )
  return(result)
}

Directions <- lapply(not_yet_downloaded, in_bulk_get_directions)
# names(Directions) <- routes_oct

Directions


# saveRDS(Directions, 'Directions.rds')
# Directions <- readRDS('Directions.rds')

###### Plotting the directions ######
eco_bici_map <- get_map(location = c(lon = -99.17, lat = 19.405),
                         source = 'stamen',
                         zoom = 13,
                         maptype = 'terrain')

#saveRDS(eco_bici_map, 'eco_map.Rds')
ggmap(eco_bici_map)

# Testing maps and directions function
#get_direction(c(lon = -99.1723, lat = 19.4035), c(lon = -99.1730, lat = 19.4037))

directions_paths <- list.files('./DIRECTIONS')

###### Wrong way to plot ######

# Not very efficient
# Summing over plots
# Better alternative is to have a big data frame and the groups
# To plot different routes

# l_dir_tables <- list()
# for (x in directions_paths[1:1000]){
#   path <- str_replace_all(x, pattern = '^', replacement = './DIRECTIONS/')
#   name <- str_replace_all(x, pattern = '\\.csv$', replacement = '')
#   l_dir_tables[[name]] <- read_csv(path)
#   cat('.')
# }
# 
# p <- ggmap(eco_bici_map)
# for(df_dir in l_dir_tables){
#   p <- p + geom_path(data = df_dir, aes(x = lon, y = lat), color = "red",
#             size = 1, alpha = 1/4, lineend = "round")
# }
# 
# p <- ggmap(eco_bici_map)
# p <- ggplot()
# for(df_dir in l_dir_tables){
#   p <- p + geom_path(data = df_dir, aes(x = lon, y = lat), color = "red",
#                      size = 1, alpha = 1/4, lineend = "round")
# }
# 
# p
# 
# table(iris$Species)
# summary(iris)
# summary()
# summary(stations)
# sort(table(stations$districtName), decreasing = T)





