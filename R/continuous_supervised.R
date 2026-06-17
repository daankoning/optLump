ross_cluster_counts <- function(y_class, y_full, k = 3L) {
  dmat_class <- abs(outer(y_class, y_class, "-"))
  d_vals <- vapply(seq_along(y_class), function(i)
    sort.int(dmat_class[i, ], partial = k + 1)[k + 1], numeric(1))

  vapply(seq_along(y_class), function(i)
    sum(abs(y_full - y_class[i]) <= d_vals[i]), integer(1))
}

ross_mutual_information <- function(x_idx, y, k = 3L) {
  if (length(x_idx) != length(y)) {
    stop("Inputs 'x_idx' and 'y' must have the same length.")
  }

  n <- length(y)
  if (n <= k) {
    stop("Sample size must be greater than 'k' for the Ross estimator.")
  }

  counts <- integer(n)
  c_vals <- integer(n)

  for (lev in sort(unique(x_idx))) {
    idx <- which(x_idx == lev)
    counts[idx] <- length(idx)
    c_vals[idx] <- ross_cluster_counts(y[idx], y, k = k)
  }

  digamma(n) + digamma(k) - (sum(digamma(counts)) + sum(digamma(c_vals))) / n
}

#' Maximum information preservable by supervised continuous ordinal lumping
#'
#' Calculates the lumping of an ordinal covariate that preserves the maximum
#' Ross-estimated mutual information with a numeric outcome.
#'
#' @param x Ordinal covariate. A factor is interpreted in factor level order.
#'   Otherwise the sorted unique values are used as the ordinal levels.
#' @param y Numeric outcome vector.
#' @param threshold Minimum number of samples each lumped level must contain.
#' @param k Number of nearest neighbours used by the Ross estimator. Default: 3.
#'
#' @returns A list containing information about the optimal lumping:
#' \describe{
#'   \item{mutual_information}{Double representing the Ross-estimated mutual
#'     information between the lumped covariate and the outcome.}
#'   \item{loss}{Double representing the amount of information lost by lumping.}
#'   \item{lumping}{Integer vector containing the cut points of the optimal
#'     lumping, in the same convention as the ordinal discrete implementation.}
#' }
#'
#' @export
maximum_mutual_information_ordinal_supervised_continuous <- function(x, y, threshold, k = 3L) {
  if (length(x) != length(y)) {
    stop("Inputs 'x' and 'y' must have the same length.")
  }
  if (!is.numeric(y) || any(is.na(y))) {
    stop("Input 'y' must be a numeric vector with no missing values.")
  }
  if (length(threshold) != 1 || !is.numeric(threshold) || threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }
  if (!is.numeric(k) || length(k) != 1 || k < 1) {
    stop("Input 'k' must be a single positive integer.")
  }
  k <- as.integer(k)

  x_levels <- if (is.factor(x)) levels(x) else sort(unique(x))
  x_fac <- factor(x, levels = x_levels, ordered = TRUE)
  if (any(is.na(x_fac))) {
    stop("Input 'x' contains values that cannot be matched to the ordinal levels.")
  }

  n <- length(x_fac)
  m <- length(x_levels)
  if (n < threshold) {
    stop("Total sample size must be greater than threshold for lumping to be possible.")
  }

  x_idx <- as.integer(x_fac)
  level_counts <- tabulate(x_idx, nbins = m)

  if (any(level_counts <= k)) {
    stop("Every original ordinal level must contain more than 'k' samples for the Ross estimator.")
  }

  c_original <- integer(n)
  for (lev in seq_len(m)) {
    idx <- which(x_idx == lev)
    c_original[idx] <- ross_cluster_counts(y[idx], y, k = k)
  }

  mi_unlumped <- ross_mutual_information(x_idx, y, k = k)

  segment_loss <- function(i, j) {
    segment_idx <- which(x_idx >= i & x_idx <= j)
    segment_count <- length(segment_idx)

    if (sum(level_counts[i:j]) < threshold) {
      return(Inf)
    }

    y_segment <- y[segment_idx]
    c_segment <- ross_cluster_counts(y_segment, y, k = k)

    post_term <- segment_count * digamma(segment_count) + sum(digamma(c_segment))
    pre_term <- sum(level_counts[i:j] * digamma(level_counts[i:j])) + sum(digamma(c_original[segment_idx]))

    (post_term - pre_term) / n
  }

  f <- rep(Inf, m + 1L)
  f[1L] <- 0
  cut_points <- rep(NA_integer_, m)

  for (j in seq_len(m)) {
    for (i in seq_len(j)) {
      if (sum(level_counts[i:j]) < threshold) {
        next
      }
      current_value <- f[i] + segment_loss(i, j)
      if (current_value < f[j + 1L]) {
        f[j + 1L] <- current_value
        cut_points[j] <- i
      }
    }
  }

  if (!is.finite(f[m + 1L])) {
    stop("No lumping exists that satisfies the constraints.")
  }

  lumping <- integer()
  curr <- m
  while (curr > 0) {
    start_i <- cut_points[curr]
    if (is.na(start_i)) {
      stop("Failed to backtrack the optimal lumping.")
    }
    lumping <- c(start_i, lumping)
    curr <- start_i - 1
  }
  lumping <- c(lumping, m + 1L)

  list(
    mutual_information = mi_unlumped - f[m + 1L],
    loss = f[m + 1L],
    lumping = lumping
  )
}

#' Maximum information preservable by supervised continuous nominal lumping
#'
#' Calculates the maximum Ross-estimated mutual information between a lumped
#' nominal covariate and a numeric outcome.
#'
#' @param x Nominal covariate. A factor is used in factor level order; otherwise
#'   the sorted unique values define the level order.
#' @param y Numeric outcome vector.
#' @param threshold Minimum number of samples each lumped level must contain.
#' @param adj_matrix Adjacency matrix of the preference graph. Default: complete
#'   graph, allowing all admissible cliques.
#' @param verbose Whether to print diagnostic messages. Default: `FALSE`.
#' @param k Number of nearest neighbours used by the Ross estimator. Default: 3.
#'
#' @returns A list containing information about the optimal lumping:
#' \describe{
#'   \item{mutual_information}{Ross-estimated mutual information between the
#'     lumped covariate and the outcome, in nats.}
#'   \item{loss}{Mutual information lost by the lumping.}
#'   \item{lumping}{A list of character vectors, where each vector contains the
#'     names of the original levels that have been lumped together.}
#' }
#'
#' @export
maximum_mutual_information_nominal_supervised_continuous <- function(x, y, threshold, adj_matrix = NULL, verbose = FALSE, k = 3L) {
  if (length(x) != length(y)) {
    stop("Inputs 'x' and 'y' must have the same length.")
  }
  if (!is.numeric(y) || any(is.na(y))) {
    stop("Input 'y' must be a numeric vector with no missing values.")
  }
  if (length(threshold) != 1 ||
      !is.numeric(threshold) ||
      threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }
  if (!is.numeric(k) || length(k) != 1 || k < 1) {
    stop("Input 'k' must be a single positive integer.")
  }
  k <- as.integer(k)

  L <- if (is.factor(x)) levels(x) else sort(unique(x))
  x_fac <- factor(x, levels = L)
  if (any(is.na(x_fac))) {
    stop("Input 'x' contains values that cannot be matched to the nominal levels.")
  }

  n <- length(x_fac)
  m <- length(L)
  x_idx <- as.integer(x_fac)
  level_counts <- tabulate(x_idx, nbins = m)

  if (n < threshold) {
    stop("Total sample size must be greater than threshold for lumping to be possible.")
  }
  if (any(level_counts <= k)) {
    stop("Every original nominal level must contain more than 'k' samples for the Ross estimator.")
  }

  if (is.null(adj_matrix)) {
    adj_matrix <- matrix(1, nrow = m, ncol = m, dimnames = list(L, L))
  }
  if (!all(L %in% rownames(adj_matrix)) || !all(L %in% colnames(adj_matrix))) {
    stop("Adjacency matrix must contain row and column names matching all levels in 'x'.")
  }
  adj_matrix <- adj_matrix[L, L, drop = FALSE]

  weight_function <- function(clique_indices) {
    idx <- unlist(lapply(clique_indices, function(z) which(x_idx == z)), use.names = FALSE)
    clique_n <- length(idx)
    if (clique_n <= k) {
      return(NA_real_)
    }
    c_vals <- ross_cluster_counts(y[idx], y, k = k)
    -(clique_n * digamma(clique_n) + sum(digamma(c_vals))) / n
  }

  if (verbose) message("Starting clique finding...")
  pref_graph <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected")
  all_cliques <- igraph::cliques(pref_graph)

  if (verbose) message("Filtering out cliques with insufficient sample count...")
  valid_cliques <- lapply(all_cliques, function(clique) {
    indices <- as.numeric(clique)
    D_i <- sum(level_counts[indices])

    if (D_i < threshold || D_i <= k) {
      return(NULL)
    }

    list(
      clique = clique,
      weight = weight_function(indices)
    )
  })
  valid_cliques <- valid_cliques[!sapply(valid_cliques, is.null)]
  K <- length(valid_cliques)

  if (K == 0) {
    stop("No lumping exists that satisfies the threshold and Ross constraints.")
  }

  if (verbose) message("Setting up ILP...")
  constraint_matrix <- matrix(0, nrow = m, ncol = K)
  weights <- rep(NA_real_, K)
  for (i in seq_len(K)) {
    indices_in_clique <- as.numeric(valid_cliques[[i]]$clique)
    constraint_matrix[indices_in_clique, i] <- 1
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

  if (res$status != 0) {
    stop("No lumping exists that is able to satisfy all constraints.")
  }

  if (verbose) message("Decoding ILP result...")
  used_cliques <- valid_cliques[res$solution == 1]
  lumping <- lapply(used_cliques, function(clique) L[as.numeric(clique$clique)])

  original_mi <- ross_mutual_information(x_idx, y, k = k)
  lumped_mi <- digamma(n) + digamma(k) + sum(weights[res$solution == 1])

  list(
    mutual_information = lumped_mi,
    loss = original_mi - lumped_mi,
    lumping = lumping
  )
}
