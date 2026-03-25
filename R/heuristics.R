lowest_cost_merge <- function(counts, pref_graph, threshold) {
  L <- names(counts)
  n <- sum(counts)
  min_cost <- Inf
  best_pair <- NULL

  edges <- igraph::as_edgelist(pref_graph, names = TRUE)

  for (i in seq_len(nrow(edges))) {
    a <- edges[i, 1]
    b <- edges[i, 2]

    if (counts[a] >= threshold && counts[b] >= threshold) next

    merged_count <- counts[a] + counts[b]
    cost <- safe_xlogx(merged_count / n) - safe_xlogx(counts[a] / n) - safe_xlogx(counts[b] / n)

    if (cost < min_cost) {
      min_cost <- cost
      best_pair <- c(a, b)
    }
  }

  best_pair
}

heuristic_largest <- function(counts, pref_graph, threshold) {
  smallest <- names(counts)[which.min(counts)]

  neighbours <- names(igraph::neighbors(pref_graph, smallest))
  if (length(neighbours) == 0) return(NULL)

  largest_neighbour <- names(counts[neighbours])[which.max(counts[neighbours])]

  c(smallest, largest_neighbour)
}

heuristic_other <- function(counts, pref_graph, threshold) {
  smallest <- names(counts)[which.min(counts)]

  neighbours <- names(igraph::neighbors(pref_graph, smallest))
  if (length(neighbours) == 0) return(NULL)

  smallest_neighbour <- names(counts[neighbours])[which.min(counts[neighbours])]

  c(smallest, smallest_neighbour)
}

#TODO: document
#' Approximate maximum information preservable by nominal lumping
#'
#' Since the proper optimisation function, [maximum_mutual_information_nominal()], has superpolynomial time complexity,
#' this function provides a heuristic to find a good lumping in polynomial time.
#'
#' The lumping returned is guaranteed to satisfy the constraints, but the mutual information conserved is not guaranteed to be maximal.
#' Additionally, since the the clique cover problem is itself NP-complete, it is not guaranteed that a lumping is found at all,
#' even when it exists.
#'
#' ## Heuristics
#' The different heuristics all operate differently.
#' The options are:
#' - `"smart"` TODO: document when done
#' - `"largest"` iteratively lumps the smallest level with the largest other level it can be lumped with.
#'      In practice, the algorithm results in one large hard to interpret group and probably ought be avoided.
#' - `"other"` can be seen as a re-implementation of `forcats::fct_lump_min`, in that
#'      it tries to lump the smallest levels together, with the
#'      added flexibility provided by support for non-complete preference graphs.
#'
#' @inheritParams maximum_mutual_information_nominal
#' @param heuristic Character string specifying the algorithm to use. See Details for their behaviour. Default: `"smart"`.
#'
#' @inherit maximum_mutual_information_nominal return
#'
#' @seealso
#'  [maximum_mutual_information_nominal()] for the non-approximate version of this function.
#'
#'  [lump_nominal_heuristic()] for a more user-friendly wrapper around this function that actually carries out the lumping.
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_nominal_heuristic <- function(counts, threshold, adj_matrix = NULL, verbose = FALSE, heuristic = c("smart", "largest", "other")) {
  if (!is.numeric(counts) || any(is.na(counts)) || any(counts < 0) || is.null(names(counts))) {
    stop("Input 'counts' must be a named numeric vector with no missing or negative values.")
  }
  if (length(threshold) != 1 || !is.numeric(threshold) || threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }
  L <- names(counts)
  n <- sum(counts)
  m <- length(counts)

  # default to complete preference graph:
  if (is.null(adj_matrix)) {
    adj_matrix <- matrix(1, nrow = m, ncol = m, dimnames = list(L, L))
  }

  if (n == 0) {
    stop("Total number of samples is 0. Cannot perform lumping.")
  }
  if (n < threshold) {
    stop("Total sample size must be greater than threshold for lumping to be possible.")
  }
  if (!all(L %in% rownames(adj_matrix)) || !all(L %in% colnames(adj_matrix))) {
    stop("Adjacency matrix must contain row and column names matching all levels in 'counts'.")
  }

  heuristic <- match.arg(heuristic)
  if (heuristic == "smart") {
    choice_function <- lowest_cost_merge
  }
  if (heuristic == "largest") {
    choice_function <- heuristic_largest
  } else if (heuristic == "other") {
    choice_function <- heuristic_other
  }

  original_entropy <- empirical_entropy(counts)
  lumping <- as.list(L)
  names(lumping) <- L

  adj_matrix <- adj_matrix[L, L, drop = FALSE]
  pref_graph <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected", diag = FALSE)

  while (any(counts < threshold)) {
    best_pair <- choice_function(counts, pref_graph, threshold)
    if (is.null(best_pair)) {
      stop("No lumping exists that is able to satisfy all constraints.")
    }
    a <- best_pair[1]
    b <- best_pair[2]
    new_name <- paste(a, b, sep = "+")

    if (verbose) message(paste("Merging levels", a, "and", b))

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