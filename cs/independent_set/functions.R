#!/usr/bin/env Rscript

############# Libraries #############

library('lpSolve')
library('igraph')

############# Utility Functions #############


# Forces a matrix into a symetrical form
symmetrical <- function(Matrix, side = 'lower') {
  if (side == 'upper') { # Overrides the upper side with the lower side
    Matrix[upper.tri(Matrix)] <- t(Matrix)[upper.tri(Matrix)]
    return(Matrix)
  } else if (side == 'lower') { # Overrides the lower side with the upper side
    Matrix[lower.tri(Matrix)] <- t(Matrix)[lower.tri(Matrix)]
    return(Matrix)
  } else {
    stop('Error: Bad side. Choose between: upper or lower.')
  }
}

graph_random <- function(nodes, prob) {
  p <- prob
  q <- 1 - p
  p_q <- c(p, q)
  G_directed <- matrix( 
    sample(1:0 , nodes*nodes, replace = TRUE, prob = p_q),
    nrow = nodes,
    ncol = nodes,
    byrow = TRUE
  )
  diag(G_directed) <- rep(0,nodes)
  graph <- symmetrical(G_directed)
  return(graph)
}

plot_adjacency <- function(graph) {
  plot( graph_from_adjacency_matrix(graph, mode = 'undirected') ) 
}

is_independent <- function(solution, graph) {
  for (node in solution) {
    column <- 0
    for (connection in graph[node,]) {
      column <- column + 1
      if (column %in% solution) {
        if (connection == 1) {
          return(FALSE)
        }
      }
    }
  }
  return(TRUE)
}

############# Greedy Independent Set #############

old_independent_set_greedy <- function(graph) {
  rs_graph <- rowSums(graph)
  names( rs_graph ) <- 1:nrow(graph)
  rs_graph_sorted <- sort( rs_graph )
  lower_degree <- as.numeric( names( rs_graph_sorted ) )
  rows <- 1:nrow(graph)
  remaining_rows <- rows
  for (row in lower_degree) {
    if (row %in% remaining_rows) {
      rows_to_remove <- rows [ graph[ row , ] == 1 ]
      remaining_rows <- setdiff(remaining_rows,rows_to_remove)
      } else {
      next
    }
  }
  remaining_rows
}

name_graph <- function(graph) {
  rownames(graph) <- 1:nrow(graph)
  colnames(graph) <- 1:ncol(graph)
  return(graph)
}

remove_friends <- function(str_node, graph_named) {
  new_graph <- graph_named
  # Get neighbors
  neighbors_ <- new_graph[str_node,] * as.numeric(rownames(new_graph))
  neighbors_[str_node] <- as.numeric(str_node)
  neighbors_ <- neighbors_[neighbors_ != 0]
  neighbors_ <- as.character(neighbors_)
  # Remove neighbors and itself
  remove <- !(rownames(new_graph) %in% neighbors_)
  new_graph <- new_graph[remove, remove, drop = FALSE]
  return(new_graph) 
}

independent_set_greedy <- function(graph) {
  nam_g <- name_graph(graph)
  independent_set <- character()
  while ( nrow(nam_g) != 0 ) {
    # Sorting by degree and selecting lowesr degree node
    lowest_degree_node <- names(sort(rowSums(nam_g)))[1]
    independent_set <- c( independent_set, lowest_degree_node )
    # Actualizing graph
    nam_g <- remove_friends(lowest_degree_node, nam_g)
  }
  independent_set <- as.numeric(independent_set)
  return(sort(independent_set))
}


############# LP Independent Set #############

graph_constrains <- function(graph, max_clique = 3) {
  constrains <- numeric()
  n_constrains <- 0
  # Converting the adjacency matrix to igraph object
  i_graph <- graph_from_adjacency_matrix(graph, mode = 'undirected')
  # Calculating cliques in G and storing the result in a list
  cliq_graph <- cliques(i_graph, min = 1, max = max_clique)
  for (clique in cliq_graph) {
    n_constrains <- n_constrains + 1
    curr_cons <- rep(0, ncol(graph))
    for ( idx in 1:length(clique) ) {
      curr_cons[clique[idx]] <- 1
    }
    constrains <- c(constrains, curr_cons)
  }
  # Returning the constrains matrix
  matrix(constrains, nrow = n_constrains, byrow = TRUE)
}

independent_set_linear_programming <- function(graph, max_clique = 3) {
  m_constrains <- graph_constrains(graph, max_clique = max_clique)
  n_limits <- nrow(m_constrains) 
  f.obj <- rep(1, nrow(graph)) # Objective Function
  f.con <- m_constrains # Constrain Matrix
  f.dir <- rep('<=', n_limits) # Constrains directions
  f.rhs <- rep(1, n_limits) # Constrains limits
  # Run LP
  lp_result <- lp ("max", f.obj, f.con, f.dir, f.rhs)
  # Return the coefficients
  lp_coeff <- lp_result$solution
  names(lp_coeff) <- 1:length(lp_coeff)
  o_lp_coeff <- sort(lp_coeff, decreasing = TRUE)
  banned <- numeric()
  independent_set <- numeric()
  for ( char_vertex in names(o_lp_coeff) ) {
    vertex <- as.numeric(char_vertex)
    if ( vertex %in% banned ) {
      next
    }
    independent_set <- c( independent_set, vertex )
    current_vertex_connections <- graph[vertex, ] * 1:nrow(graph)
    to_ban <- current_vertex_connections[current_vertex_connections != 0]
    banned <- c(banned, to_ban)
  }
  return(sort(independent_set))
}

############# Metropolis Independent Set #############

random_solution <- function(graph) {
  sample(0:1, nrow(graph), replace = TRUE)
}

walk_solution <- function(solution) {
  disturbance_idx <- sample(1:length(solution), 1)
  if (solution[disturbance_idx] == 1) {
    # If 1 change it to 0
    solution[disturbance_idx] <- 0
  } else {
    # If 0 change it to 1
    solution[disturbance_idx] <- 1
  }
  solution
}

calculate_energy <- function (solution, graph) {
  inverse_energy <- sum(solution)
  solution <- solution
  row <- 0
  invalid <- FALSE
  for ( element in solution ) {
    row <- row + 1
    if (element == 1) {
      # Rearranging the row to not count conections twice 
      relevant_entries <- upper.tri( graph )[row,]
      # Turn to 0 all the not relevant entries
      current_connections <- c( rep(0, row), graph[row,][relevant_entries] ) # Turn to 0 all the not relevant entries
      # If the sum of any entry in the matrix is two it is a connection solution
      # And it is not a valid solution
      cyc_invalid <- 2 %in% (current_connections + solution)
      if (cyc_invalid) {
        location_inv_con <- (current_connections + solution) %in% 2
        invalid_connections <- sum( rep(1, nrow(graph) )[location_inv_con] )
        inverse_energy <- inverse_energy - invalid_connections
        invalid <- TRUE
      }
    } else {
      next
    }
  }
  if(inverse_energy <= 0) {
    inverse_energy <- 0.5
    ind_s_size <- 0
  } else {
    ind_s_size <- inverse_energy
  }
  energy <- 1 / inverse_energy
  calc_energy_results <- list(energy, ind_s_size, !invalid)
  calc_energy_results <- setNames(calc_energy_results, c( 'energy', 'ind_s_size', 'is_valid'))
  return(calc_energy_results)
}

local_search_metropolis <- function(graph, cycles = 100, init_pos = random_solution(graph), t = 30, k = 0.01) {
  old_solution <- init_pos
  # A trivial solution is any node
  best_solution <- list( sample(1:nrow(graph), size = 1), 1 )
  best_solution <- setNames(best_solution, c('independent_set', 'energy'))
  old_calculations <- calculate_energy(solution = old_solution, graph = graph)
  # Compare trivial solution vs initial one
  if (old_calculations$is_valid && old_calculations$energy < best_solution$energy) {
    independent_set <- old_solution * 1:length(old_solution)
    independent_set <- independent_set[independent_set != 0]
    best_solution$independent_set <- independent_set
    best_solution$energy <- old_calculations$energy
  }
  for (cycle in 1:cycles) {
    new_solution <- walk_solution(solution = old_solution)
    new_calculations <- calculate_energy(solution = new_solution, graph = graph)
    old_calculations <- calculate_energy(solution = old_solution, graph = graph)
    # Compare the best solution so far to all the new ones
    if (new_calculations$is_valid && new_calculations$energy < best_solution$energy) {
      independent_set <- new_solution * 1:length(new_solution)
      independent_set <- independent_set[independent_set != 0]
      best_solution$independent_set <- independent_set
      best_solution$energy <- new_calculations$energy
    }
    if (new_calculations$energy <= old_calculations$energy) {
      old_solution <- new_solution
    } else {
      delta_energy <- new_calculations$energy - old_calculations$energy
      exp_args <- -( delta_energy / (k * t) ) 
      p <- exp(exp_args)
      q <- 1 - p
      toss <- sample(1:0, size = 1, prob = c(p, q))
      # print(p) # Print p to tune the T and K parameters
      if (toss == 1) {
        old_solution <- new_solution
      }
    }
  }
  return(best_solution)
}

simulated_annealing <- function(cooling_schedule, graph, init_pos = random_solution(graph)) {
  just_one <- TRUE
  for ( row in 1:nrow(cooling_schedule) ) {
    if (just_one) {
      just_one <- FALSE
      best_so_far <- local_search_metropolis(graph,
                                             cycles = cooling_schedule[row, 1],
                                             init_pos = init_pos,
                                             t = cooling_schedule[row, 1])$independent_set
      init_pos_best_so_far <- rep(0, nrow(graph))
      for (idx in best_so_far) {
        init_pos_best_so_far[idx] <- 1
      }
    } else {
      best_so_far <- local_search_metropolis(graph,
                                             cycles = cooling_schedule[row, 1],
                                             init_pos = init_pos_best_so_far,
                                             t = cooling_schedule[row, 1])$independent_set
      init_pos_best_so_far <- rep(0, nrow(graph))
      for (idx in best_so_far) {
        init_pos_best_so_far[idx] <- 1
      }
    }
  }
  return(sort(best_so_far))
}