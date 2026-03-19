lowest_cost_merge <- function(counts, adj_matrix) {
  #TODO: this should just take the graph and use the edge list
  L <- names(counts)
  m <- length(counts)
  n <- sum(counts)
  min_cost <- Inf
  best_pair <- NULL

  for (i in 1:(m - 1)) {
    for (j in (i + 1):m) {
      if (adj_matrix[i, j] == 0) next

      merged_count <- counts[i] + counts[j]
      cost <- safe_xlogx(merged_count / n) - safe_xlogx(counts[i] / n) - safe_xlogx(counts[j] / n)

      if (cost < min_cost) {
        min_cost <- cost
        best_pair <- c(L[i], L[j])
      }
    }
  }

  best_pair
}

#TODO: document
#' Approximate maximum information preservable by nominal lumping
#'
#' Since the proper optimisation function, [maximum_mutual_information_nominal()], has superpolynomial time complexity,
#' this function provides a heuristic to find a good lumping in polynomial time.
#' The lumping found is guaranteed to satisfy the constraints, but the mutual information conserved is not guaranteed to be maximal.
#'
#' @inheritParams maximum_mutual_information_nominal
#'
#' @inherit maximum_mutual_information_nominal return
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_nominal_heuristic <- function(counts, threshold, adj_matrix, verbose = FALSE) {
  if (!is.numeric(counts) || any(is.na(counts)) || any(counts < 0) || is.null(names(counts))) {
    stop("Input 'counts' must be a named numeric vector with no missing or negative values.")
  }
  if (length(threshold) != 1 || !is.numeric(threshold) || threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }
  L <- names(counts)
  n <- sum(counts)

  if (n == 0) {
    stop("Total number of samples is 0. Cannot perform lumping.")
  }
  if (n < threshold) {
    stop("Total sample size must be greater than threshold for lumping to be possible.")
  }
  if (!all(L %in% rownames(adj_matrix)) || !all(L %in% colnames(adj_matrix))) {
    stop("Adjacency matrix must contain row and column names matching all levels in 'counts'.")
  }

  original_entropy <- empirical_entropy(counts)
  lumping <- as.list(L)
  names(lumping) <- L

  adj_matrix <- adj_matrix[L, L, drop = FALSE]
  pref_graph <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected", diag = FALSE)

  while (any(counts < threshold)) {
    best_pair <- lowest_cost_merge(counts, igraph::as_adjacency_matrix(pref_graph, sparse = FALSE))
    if (is.null(best_pair)) {
      stop("No lumping exists that is able to satisfy all constraints.")
    }
    a <- best_pair[1]
    b <- best_pair[2]
    new_name <- paste(a, b, sep = "+")

    # collapse counts
    counts[new_name] <- counts[a] + counts[b]
    counts <- counts[names(counts) != a & names(counts) != b]

    # update the preference graph:
    pref_graph <- igraph::add_vertices(pref_graph, nv = 1, name = new_name)
    neighbours <- intersect(names(igraph::neighbors(pref_graph, a)), names(igraph::neighbors(pref_graph, b)))
    if (length(neighbours) > 0) {
      pref_graph <- igraph::add_edges(pref_graph, c(rbind(new_name, neighbours)))
    }
    pref_graph <- igraph::delete_vertices(pref_graph, c(a, b))

    # track change in lumping
    lumping[[new_name]] <- c(lumping[[a]], lumping[[b]])
    lumping[[a]] <- NULL
    lumping[[b]] <- NULL
  }

  list(
    mutual_information = empirical_entropy(counts),
    loss = original_entropy - empirical_entropy(counts),
    lumping = unname(lumping)
  )
}
# TODO: test