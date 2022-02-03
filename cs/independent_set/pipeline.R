#!/usr/bin/env Rscript

source('functions.R')
library('tidyverse')
library('ggthemes')
library('parallel')
library('ggpubr')

# symmetrical <- function(Matrix, side = 'lower')
# graph_random <- function(nodes, prob)
# plot_adjacency <- function(graph)
# is_independent <- function(solution, graph)

# old_independent_set_greedy <- function(graph)
# name_graph <- function(graph)
# remove_friends <- function(str_node, graph_named)
# independent_set_greedy <- function(graph)

# graph_constrains <- function(graph, max_clique = 3)
# independent_set_linear_programming <- function(graph, max_clique = 3)

# random_solution <- function(graph)
# walk_solution <- function(solution)
# calculate_energy <- function (solution, graph)
# local_search_metropolis <- function(graph, cycles = 100, init_pos = random_solution(graph), t = 30, k = 0.01)
# simulated_annealing <- function(cooling_schedule, graph)

cooling_matrix <- matrix(c(200, 70,
                           300, 30,
                           400, 20,
                           500, 1), nrow = 4, byrow = TRUE)

cooling_matrix02 <- matrix(c(400, 70,
                           600, 30,
                           800, 20,
                           900, 10,
                           2000, 1), nrow = 5, byrow = TRUE)

# g <- graph_random(20, 0.2)
# greedy_ind_set <- independent_set_greedy(g)
# length(greedy_ind_set)
# greedy_ind_set
# lp_ind_set <- independent_set_linear_programming(g)
# length(lp_ind_set)
# lp_ind_set
# metro_ind_set <- simulated_annealing(cooling_matrix02, g)
# length(metro_ind_set)
# metro_ind_set
#greedy_solution <- rep( 0, nrow(g) )
# for (node in greedy_ind_set) {
#   greedy_solution[node] <- 1
# }
# metro_init_gr_ind_set <- simulated_annealing(cooling_matrix02, g, init_pos = greedy_solution)
# length(metro_init_gr_ind_set)
# greedy_ind_set
# metro_init_gr_ind_set

project <- function(dummy = 42, node_seq = seq(10, 10, 10), prob_seq = seq(0.1,0.2,0.3), experiments = 3) {
  i <- 0
  greedy_data <- data.frame(algorithm = vector(), nodes = vector(),
                            prob = vector(), size = vector(),
                            solution = vector(), user = vector(),
                            sys = vector(), elapsed = vector()) 
  lp_data <- greedy_data
  metro_data <- greedy_data
  for (n in node_seq) {
    for ( p in prob_seq) {
      for (experiment in 1:experiments) {
        i <- i + 1
        g <- graph_random(n, p)
        cat(paste ('.', i, '.', sep=''))
        time_greedy <- system.time(res_greedy <- independent_set_greedy(g) )
        cat('gr.')
        time_lp <- system.time(res_lp <- independent_set_linear_programming(g) )
        cat('lp.')
        time_metro <- system.time(res_metro <- simulated_annealing(cooling_matrix, g) )
        cat('metro.')
        current_greedy <- data.frame(algorithm = 'greedy', nodes = n,
                                        prob = p, size = length(res_greedy),
                                        solution = paste( as.character(res_greedy), collapse = '-'), user = time_greedy[1],
                                        sys = time_greedy[2], elapsed = time_greedy[3])
        greedy_data <-rbind(greedy_data, current_greedy)
        current_lp <- data.frame(algorithm = 'lp', nodes = n,
                                        prob = p, size = length(res_lp),
                                        solution = paste( as.character(res_lp), collapse = '-'), user = time_lp[1],
                                        sys = time_lp[2], elapsed = time_lp[3])
        lp_data <-rbind(lp_data, current_lp)
        current_metro <- data.frame(algorithm = 'metro', nodes = n,
                                        prob = p, size = length(res_metro),
                                        solution = paste( as.character(res_metro), collapse = '-'), user = time_metro[1],
                                        sys = time_metro[2], elapsed = time_metro[3])
        metro_data <-rbind(metro_data, current_metro)
      }
    }
  }
  print('')
  project_data <- rbind(greedy_data, lp_data, metro_data)
  rownames(project_data) <- 1:nrow(project_data)
  return(project_data)
}

project()

# # 1 hour
# project_df <- project(node_seq = seq(20, 50, 10), prob_seq = seq(0.1,0.7,0.1), experiments = 60)
# write.csv(project_df, 'ind_set_data.csv')
# 
# # 1 hour
# time_02 <- system.time ( project_df_02 <- project(node_seq = seq(20, 50, 10), prob_seq = seq(0.8,0.9,0.1), experiments = 30) )
# write.csv(project_df_02, 'ind_set_data_02.csv')

# data01 <- read.csv('ind_set_data.csv', header = TRUE, stringsAsFactors = FALSE)
# data02 <- read.csv('ind_set_data_02.csv', header = TRUE, stringsAsFactors = FALSE)
# data_03 <- rbind(data01, data02)
# 
# write.csv(data_03,'project_data_5760.csv')

file <- 'project_data_5760.csv'

ind_set_df <- read.csv(file, header = TRUE, stringsAsFactors = FALSE)

ind_set_df$algorithm <- as.factor(ind_set_df$algorithm)
ind_set_df$nodes <- as.factor(ind_set_df$nodes)
ind_set_df$prob <- as.factor(ind_set_df$prob)

l_df <- split(ind_set_df, ind_set_df$nodes)
df_20 <- l_df[[1]]
df_30 <- l_df[[2]]
df_40 <- l_df[[3]]
df_50 <- l_df[[4]]

# confidence interval at 95 for the mean
# mean +- qnorm(0.975) * (s / sqrt(n)) 
ci_95 <- function(x) {
  ci <- qnorm(0.975) * (sd(x) / sqrt(length(x)))
  return(ci)
}
# ci_95( subset(df_20, algorithm == 'greedy' & prob == 0.1)$size )

# tapply(vector, factor or list of factors, function)

calc_ci2plot <- function(df){
  df_20 <- df
  mean_df_20 <- tapply(df_20$size, list(df_20$prob ,df_20$algorithm), mean)
  mean_df_20 <- as.data.frame(mean_df_20)
  
  ci_df_20 <- tapply(df_20$size, list(df_20$prob ,df_20$algorithm), ci_95)
  ci_df_20 <- as.data.frame(ci_df_20)
  
  names(mean_df_20) <- c('mean_gr','mean_lp','mean_met')
  names(ci_df_20) <- c('ci_gr','ci_lp','ci_met')
  
  up_df_20 <- mean_df_20 + ci_df_20
  lo_df_20 <- mean_df_20 - ci_df_20
  
  names(up_df_20) <- c('up_gr','up_lp','up_met')
  names(lo_df_20) <- c('lo_gr','lo_lp','lo_met')
  
  alg_comp_20 <- cbind(mean_df_20, up_df_20, lo_df_20)
  alg_comp_20$prob <- rownames(alg_comp_20)
  alg_comp_20 <- alg_comp_20[ c( ncol(alg_comp_20), 1:ncol(alg_comp_20)-1 ) ]
  
  alg_comp_20_a <- alg_comp_20 %>%
    gather(`mean_gr`, `mean_lp`, `mean_met`, key = 'algorithm01', value = 'mean')
  
  alg_comp_20_b <- alg_comp_20 %>%
    gather(`up_gr`, `up_lp`, `up_met`, key = 'algorithm02', value = 'upper_ci')
  
  alg_comp_20_c <- alg_comp_20 %>%
    gather(`lo_gr`, `lo_lp`, `lo_met`, key = 'algorithm03', value = 'lower_ci')
  
  alg_comp_20 <- cbind(alg_comp_20_a, alg_comp_20_b, alg_comp_20_c)
  
  alg_comp_20 <- alg_comp_20[c('prob', 'algorithm01', 'mean', 'upper_ci', 'lower_ci')]
  
  alg <- alg_comp_20$algorithm01
  alg <- sub('mean_gr', 'greedy', alg, perl=TRUE)
  alg <- sub('mean_lp', 'lp', alg, perl=TRUE)
  alg <- sub('mean_met', 'metro', alg, perl=TRUE)
  
  alg_comp_20$algorithm <- alg
  alg_comp_20 <- alg_comp_20[c('prob', 'algorithm', 'mean', 'upper_ci', 'lower_ci')]
  
  alg_comp_20$prob <- as.factor(alg_comp_20$prob)
  alg_comp_20$algorithm <- as.factor(alg_comp_20$algorithm)
  re_df <- alg_comp_20
  return(re_df)
}



alg_comp_20 <- calc_ci2plot(df_20)


# # Standard error of the mean
# ggplot(alg_comp_20, aes(x=prob, y=mean, colour=algorithm)) + 
#   geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.1) +
#   geom_point()

# The errorbars overlapped, so use position_dodge to move them horizontally
#pd <- position_dodge(0.1) # move them .05 to the left and right
pd <- position_dodge(0.0)
p1_20 <- ggplot(alg_comp_20, aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_line(position=pd) +
  geom_point(position=pd) +
  ggtitle('20 Nodes') +
  theme_fivethirtyeight()

ggsave('p1_20.svg', p1_20, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.5)
p2_20 <- ggplot(alg_comp_20, aes(x=prob, y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_point(position=pd, size = 1) +
  ggtitle('20 Nodes') +
  theme_fivethirtyeight()

ggsave('p2_20.svg', p2_20, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.0)
p3_20 <- ggplot(alg_comp_20, aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_area(aes(fill=algorithm), position=pd) +
  geom_point(position=pd, size=1, shape=21, fill='black') +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), color='black' ,width=0.0, position=pd) +
  ggtitle('20 Nodes') +
  theme_fivethirtyeight()

ggsave('p3_20.svg', p3_20, units = 'cm', width = 10, height = 10)



####################################################


alg_comp_30 <- calc_ci2plot(df_30)


pd <- position_dodge(0.0)
p1_30 <- ggplot(alg_comp_30, aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_line(position=pd) +
  geom_point(position=pd) +
  ggtitle('30 Nodes') +
  theme_fivethirtyeight()

ggsave('p1_30.svg', p1_30, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.5)
p2_30 <- ggplot(alg_comp_30, aes(x=prob, y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_point(position=pd, size = 1) +
  ggtitle('30 Nodes') +
  theme_fivethirtyeight()

ggsave('p2_30.svg', p2_30, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.0)
p3_30 <- ggplot(alg_comp_30, aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_area(aes(fill=algorithm), position=pd) +
  geom_point(position=pd, size=1, shape=21, fill='black') +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), color='black' ,width=0.0, position=pd) +
  ggtitle('30 Nodes') +
  theme_fivethirtyeight()

ggsave('p3_30.svg', p3_30, units = 'cm', width = 10, height = 10)


####################################################


alg_comp_40 <- calc_ci2plot(df_40)


pd <- position_dodge(0.0)
p1_40 <- ggplot(alg_comp_40, aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_line(position=pd) +
  geom_point(position=pd) +
  ggtitle('40 Nodes') +
  theme_fivethirtyeight()

ggsave('p1_40.svg', p1_40, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.5)
p2_40 <- ggplot(alg_comp_40, aes(x=prob, y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_point(position=pd, size = 1) +
  ggtitle('40 Nodes') +
  theme_fivethirtyeight()

ggsave('p2_40.svg', p2_40, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.0)
p3_40 <- ggplot(alg_comp_40, aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_area(aes(fill=algorithm), position=pd) +
  geom_point(position=pd, size=1, shape=21, fill='black') +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), color='black' ,width=0.0, position=pd) +
  ggtitle('40 Nodes') +
  theme_fivethirtyeight()

ggsave('p3_40.svg', p3_40, units = 'cm', width = 10, height = 10)



####################################################


alg_comp_50 <- calc_ci2plot(df_50)


pd <- position_dodge(0.0)
p1_50 <- ggplot(alg_comp_50 , aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_line(position=pd) +
  geom_point(position=pd) +
  ggtitle('50 Nodes') +
  theme_fivethirtyeight()

ggsave('p1_50.svg', p1_50, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.5)
p2_50 <- ggplot(alg_comp_50 , aes(x=prob, y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_point(position=pd, size = 1) +
  ggtitle('50 Nodes') +
  theme_fivethirtyeight()

ggsave('p2_50.svg', p2_50, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.0)
p3_50 <- ggplot(alg_comp_50 , aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_area(aes(fill=algorithm), position=pd) +
  geom_point(position=pd, size=1, shape=21, fill='black') +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), color='black' ,width=0.0, position=pd) +
  ggtitle('50 Nodes') +
  theme_fivethirtyeight()

ggsave('p3_50.svg', p3_50, units = 'cm', width = 10, height = 10)






pd <- position_dodge(0.0)
p1_50 <- ggplot(alg_comp_50 , aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_line(position=pd) +
  geom_point(position=pd, size = 0.5 ) +
  ggtitle('50 Nodes') +
  theme_fivethirtyeight()

ggsave('p1_50_2.svg', p1_50, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.5)
p2_50 <- ggplot(alg_comp_50 , aes(x=prob, y=mean, colour=algorithm)) +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), width=0.3, position=pd ) +
  geom_point(position=pd, size = 0.5) +
  ggtitle('50 Nodes') +
  theme_fivethirtyeight()

ggsave('p2_50_2.svg', p2_50, units = 'cm', width = 10, height = 10)

pd <- position_dodge(0.0)
p3_50 <- ggplot(alg_comp_50 , aes(x=as.numeric(prob), y=mean, colour=algorithm)) +
  geom_area(aes(fill=algorithm), position=pd) +
  geom_point(position=pd, size=0.5, shape=21, fill='black') +
  geom_errorbar(aes(ymin=upper_ci, ymax=lower_ci), color='black' ,width=0.0, position=pd) +
  ggtitle('50 Nodes') +
  theme_fivethirtyeight()

ggsave('p3_50_2.svg', p3_50, units = 'cm', width = 10, height = 10)



#####################################################################################################


perr1 <- ggerrorplot(df_50, x = "prob", y = "size",
            desc_stat = "mean_ci", color = "algorithm"
            , palette="uchicago", size=.9) +
  labs(y="Size of Independent Set", x = "Probability of Connection",
       title="Comparison Between Algorithms for the Independent Set Problem 50", 
       subtitle=" Error bars depicting mean and confidence interval") +
  theme_minimal() + theme(axis.text.x = element_text(angle=90))

ggsave('perr1.svg', perr1, width = 14, height = 10)


norm_size_user <- df_50$size - ( (df_50$user + 0.001) / 10 )
#summary(norm_size_user)
df_50_2 <- df_50 
df_50_2$norm_size_time <- norm_size_user
df_50_2[1:10,]


perr2 <- ggerrorplot(df_50_2, x = "prob", y = "norm_size_time",
            desc_stat = "mean_ci", color = "algorithm"
            , palette="uchicago", size=.9) +
  labs(y="Size Normalized by Execution Time", x = "Probability of Connection",
       title="Comparison Between Algorithms for the Independent Set Problem 50", 
       subtitle=" Error bars depicting mean and confidence interval") +
  theme_minimal() + theme(axis.text.x = element_text(angle=90))

ggsave('perr2.svg', perr2)

perr3 <- ggerrorplot(df_50_2, x = "prob", y = "user",
            desc_stat = "mean_ci", color = "algorithm"
            , palette="uchicago", size=.9) +
  labs(y="User Execution Time", x = "Probability of Connection",
       title="Comparison Between Algorithms for the Independent Set Problem 50", 
       subtitle=" Error bars depicting mean and confidence interval") +
  theme_minimal() + theme(axis.text.x = element_text(angle=90))

ggsave('perr3.svg', perr3)


perr4 <- ggerrorplot(df_50_2, x = "prob", y = "sys",
            desc_stat = "mean_ci", color = "algorithm"
            , palette="uchicago", size=.9) +
  labs(y="Sys Execution Time", x = "Probability of Connection",
       title="Comparison Between Algorithms for the Independent Set Problem 50", 
       subtitle=" Error bars depicting mean and confidence interval") +
  theme_minimal() + theme(axis.text.x = element_text(angle=90))

ggsave('perr4.svg', perr4)


perr5 <- ggerrorplot(df_50_2, x = "prob", y = "elapsed",
            desc_stat = "mean_ci", color = "algorithm"
            , palette="uchicago", size=.9) +
  labs(y="Elapsed Execution Time", x = "Probability of Connection",
       title="Comparison Between Algorithms for the Independent Set Problem 50", 
       subtitle=" Error bars depicting mean and confidence interval") +
  theme_minimal() + theme(axis.text.x = element_text(angle=90))

ggsave('perr5.svg', perr5, width = 13, height = 9)


