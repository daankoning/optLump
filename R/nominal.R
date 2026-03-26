#TODO: example
#' Maximum information preservable by nominal lumping
#'
#' Calculates the maximum amount of mutual information that can be preserved by lumping a nominal variable.
#'
#' Since these two pursuits are equivalent, the actual quantity optimized for is the maximal empirical entropy
#' of the lumped levels.
#'
#' Be advised that, since the problem is NP-hard, the implementation here has time complexity
#' \eqn{O\left(2^{2^m}\right)}{O(2^2^m)}, where \eqn{m}{m} is the number of levels in the nominal variable.
#'
#' @param counts     Named numeric vector containing the number of times each level is observed.
#' @param threshold  Minimum number of samples each level must contain.
#' @param adj_matrix Adjancency matrix of the preference graph. Default: a complete graph, allowing all lumpings.
#' @param verbose    Whether to print diagnostic messages or not. Default: `FALSE`.
#'
#' @returns A list containing information about the optimal lumping:
#' \describe{
#'      \item{mutual_information}{Double representing the mutual information between the lumped and unlumped variable.}
#'      \item{loss}{Double representing the amount of entropy lost in the lumping process.}
#'      \item{lumping}{A list of character vectors, where each vector contains the names
#'                     of the original levels that have been lumped together.}
#'  }
#'
#' @seealso
#'  [lump_nominal()] for a more user-friendly wrapper around this function that actually carries out the lumping.
#'
#'  [maximum_mutual_information_nominal_heuristic()] to approximate this function when the number of levels is too large.
#'
#'  [maximum_mutual_information_hierarchical()] for a version of this function that takes advantage of hierarchical structure to speed up the execution time.
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_nominal <- function(counts, threshold, adj_matrix = NULL, verbose = FALSE) {
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
  # Reorder the adjacency matrix to match the order of levels in counts
  adj_matrix <- adj_matrix[L, L, drop = FALSE]

  # TODO: change input + consider allowing directed first and then provessing to undirected
  # find cliques
  if (verbose) message("Starting clique finding...")
  pref_graph <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected")
  all_cliques <- igraph::cliques(pref_graph)

  # Filter out those cliques that do not meet the treshold
  if (verbose) message("Filtering out cliques with insufficient sample count...")
  valid_cliques <- lapply(all_cliques, function (clique) {
    D_i <- sum(counts[as.numeric(clique)])
    if (D_i < threshold) return(NULL)

    w_i <- -D_i / n * log(D_i / n)
    list(
      clique = clique,
      weight = w_i
    )
  })
  valid_cliques <- valid_cliques[!sapply(valid_cliques, is.null)]
  K <- length(valid_cliques)

  if (K == 0) {
    stop("No lumping exists that satisfies the threshold.")
  }

  if (verbose) message("Setting up ILP...")
  constraint_matrix <- matrix(0, nrow = m, ncol = K)
  weights <- rep(0, K)
  for (i in 1:K) {
    # Set up the requirement that the cliques form an exact cover
    indices_in_clique <- as.numeric(valid_cliques[[i]]$clique)
    constraint_matrix[indices_in_clique, i] <- 1

    # transfer weights
    weights[i] <- valid_cliques[[i]]$weight
  }

  if (verbose) message("Executing ILP...")
  res <- lpSolve::lp(
    direction = "max",
    objective.in = weights,
    const.mat = constraint_matrix,
    const.dir = rep("==", m),
    const.rhs = rep(1, m),
    all.bin = TRUE
  )

  if (verbose) message("Decoding ILP result...")

  if (res$status != 0) {
    stop("No lumping exists that is able to satisfy all constraints.")
  }

  used_cliques <- valid_cliques[res$solution == 1]
  lumping <- lapply(used_cliques, function(clique) {
    L[as.numeric(clique$clique)]
  })

  list(
    mutual_information = res$objval,
    loss = empirical_entropy(counts) - res$objval,
    lumping = lumping
  )
}

#' Maximum information preservable by hierarchical lumping
#'
#' Calculates the maximum amount of mutual information that can be preserved by
#' lumping a nominal variable inherited from a hierarchy.
#'
#' This acts as a wrapper around [maximum_mutual_information_nominal()].
#' By  passing the hierarchical structure via the `clusters` argument,
#' the algorithm divides the problem into independent sub-problems, speeding
#' up the execution time for large datasets.
#'
#' @param counts     Named numeric vector containing the number of times each level is observed.
#' @param threshold  Minimum number of samples each level must contain.
#' @param clusters   List of character vectors, each vector is the names of the levels that can be grouped together.
#' @param verbose    Whether to print diagnostic messages or not. Default: `FALSE`
#'
#' @inherit maximum_mutual_information_nominal return
#'
#' @seealso
#'  [lump_hierarchical()] for a more user-friendly wrapper around this function that actually carries out the lumping.
#'
#'  [maximum_mutual_information_nominal()] for the fully general version of this function, which this one wraps.
#'
#' @examples
#' maximum_mutual_information_hierarchical(
#'      c(A = 1, B = 1, C = 2, D = 4, E = 2, F = 2),
#'      4,
#'      list(c("A", "B", "C"), c("D", "E", "F"))
#' )
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_hierarchical <- function(counts, threshold, clusters, verbose = FALSE) {
  if (!is.numeric(counts) || any(is.na(counts)) || any(counts < 0) || is.null(names(counts))) {
    stop("Input 'counts' must be a named numeric vector with no missing or negative values.")
  }
  if (length(threshold) != 1 || !is.numeric(threshold) || threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }

  L <- names(counts)
  if (!all(L %in% unlist(clusters)) || !all(unlist(clusters) %in% L)) {
    stop("All levels in 'counts' must be present in 'clusters' and vice versa.")
  }

  lumping <- list()
  for (cluster in clusters) {
    if (verbose) message(paste("Examining cluster", paste(cluster, collapse = ", ")))
    current_counts <- counts[cluster]
    res <- maximum_mutual_information_nominal(current_counts, threshold, verbose = verbose)
    lumping <- append(lumping, res$lumping)
  }

  lumped_counts <- sapply(lumping, \(lump) sum(counts[lump]))
  mutual_information <- empirical_entropy(lumped_counts)

  list(
    mutual_information = mutual_information,
    loss = empirical_entropy(counts) - mutual_information,
    lumping = lumping
  )
}