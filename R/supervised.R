#' Maximum information preservable by supervised ordinal lumping
#'
#' Calculates the lumping of an ordinal categorical covariate that preserves
#' the maximum mutual information between the lumped covariate and a discrete
#' outcome variable.
#'
#' The runtime complexity is cubic in the number of levels.
#'
#' @param joint_counts Matrix with one row per level (in order) and one column
#'   per outcome category. Entry (k, y) is the number of observations with
#'   covariate level k and outcome y.
#' @param threshold Minimum number of samples each lumped level must contain.
#'
#' @returns A list containing information about the optimal lumping:
#' \describe{
#'      \item{mutual_information}{Double representing the mutual information between the lumped and unlumped variable.}
#'      \item{loss}{Double representing the amount of entropy lost in the lumping process.}
#'      \item{lumping}{Integer vector containing, sequentially, the points at which the lumped levels are separated.
#'                      Lower bound inclusive and upper bound exclusive, so that if a_1,...,a_k is returned, the lumped
#'                      levels correspond to the levels [a_1, a_2), ..., [a_(k-1), a_k).}
#'  }
#'
#' @seealso [maximum_mutual_information_ordinal()] for the unsupervised version.
#'
#' @examples
#' joint_counts <- matrix(c(10, 2, 5, 8, 1, 9, 3, 7, 4, 6), nrow = 5)
#' maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 10)
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_ordinal_supervised <- function(joint_counts, threshold) {
  if (!is.matrix(joint_counts) || !is.numeric(joint_counts)) {
    stop("Input 'joint_counts' must be a numeric matrix.")
  }
  if (any(is.na(joint_counts)) || any(joint_counts < 0)) {
    stop("Input 'joint_counts' must have no missing or negative values.")
  }
  if (length(threshold) != 1 ||
    !is.numeric(threshold) ||
    threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }

  marginal_counts <- rowSums(joint_counts)
  n <- sum(joint_counts)
  m <- nrow(joint_counts)

  if (n < threshold) stop("Total sample size must be greater than threshold for lumping to be possible.")

  C <- \(i, j) sum(marginal_counts[i:j])

  K <- \(i, j) {
    sub <- joint_counts[i:j, , drop = FALSE]
    csums <- colSums(sub)

    j_marginal <- safe_xlogx(C(i, j) / n) - sum(safe_xlogx(marginal_counts[i:j] / n))
    j_joint <- sum(safe_xlogx(csums / n)) - sum(safe_xlogx(sub / n))

    j_marginal - j_joint
  }

  f <- rep(Inf, m + 1)
  f[1] <- 0
  cut_points <- rep(NA_integer_, m)

  for (j in 1:m) {
    for (i in 1:j) {
      if (C(i, j) < threshold) next
      current_value <- f[i] + K(i, j)
      if (current_value < f[j + 1]) {
        f[j + 1] <- current_value
        cut_points[j] <- i
      }
    }
  }

  lumping <- c()
  curr <- m
  while (curr > 0) {
    start_i <- cut_points[curr]
    lumping <- c(start_i, lumping)
    curr <- start_i - 1
  }
  lumping <- c(lumping, m + 1)

  # I(X;Y) =  H(X) + H(Y) - H(X, Y)
  mi_unlumped <- empirical_entropy(marginal_counts) +
    empirical_entropy(colSums(joint_counts)) -
    empirical_entropy(as.vector(joint_counts))

  list(
    mutual_information = mi_unlumped - f[m + 1],
    loss = f[m + 1],
    lumping = lumping
  )
}

#' Maximum information preservable by supervised nominal lumping
#'
#' Calculates the maximum amount of mutual information between a lumped nominal
#' covariate and a discrete outcome that can be preserved by lumping.
#'
#' Be advised that, since the problem is NP-hard, the implementation here has
#' time complexity \eqn{O\left(2^{2^m}\right)}{O(2^2^m)}, where \eqn{m}{m} is
#' the number of levels in the nominal variable.
#'
#' @param joint_counts Named numeric matrix with one row per level and one
#'   column per outcome category. Row names must identify the levels.
#'   Entry (k, y) is the number of observations with covariate level k and
#'   outcome y.
#' @param threshold Minimum number of samples each lumped level must contain.
#' @param adj_matrix Adjacency matrix of the preference graph. Default: a
#'   complete graph, allowing all lumpings.
#' @param verbose Whether to print diagnostic messages. Default: `FALSE`.
#'
#' @returns A list containing information about the optimal lumping:
#' \describe{
#'   \item{mutual_information}{Mutual information between the lumped covariate
#'     and the outcome, in nats.}
#'   \item{loss}{Mutual information lost by the lumping.}
#'   \item{lumping}{A list of character vectors, where each vector contains the
#'     names of the original levels that have been lumped together.}
#' }
#'
#' @seealso
#'   [maximum_mutual_information_nominal()] for the unsupervised version.
#'
#'   [maximum_mutual_information_hierarchical_supervised()] for a version that
#'   exploits hierarchical structure to speed up execution.
#'
#' @examples
#' joint_counts <- matrix(
#'   c(8, 2, 1, 4, 1, 2),
#'   nrow = 3,
#'   dimnames = list(c("A", "B", "C"), c("y0", "y1"))
#' )
#' maximum_mutual_information_nominal_supervised(joint_counts, threshold = 3)
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_nominal_supervised <- function(joint_counts, threshold, adj_matrix = NULL, verbose = FALSE) {
  if (!is.matrix(joint_counts) || !is.numeric(joint_counts)) {
    stop("Input 'joint_counts' must be a numeric matrix.")
  }
  if (any(is.na(joint_counts)) || any(joint_counts < 0)) {
    stop("Input 'joint_counts' must have no missing or negative values.")
  }
  if (is.null(rownames(joint_counts))) {
    stop("Input 'joint_counts' must have row names identifying the levels.")
  }
  if (length(threshold) != 1 ||
    !is.numeric(threshold) ||
    threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }

  L <- rownames(joint_counts)
  marginal_counts <- rowSums(joint_counts)
  n <- sum(joint_counts)
  m <- nrow(joint_counts)

  if (n < threshold) {
    stop("Total sample size must be greater than threshold for lumping to be possible.")
  }

  # default to complete preference graph
  if (is.null(adj_matrix)) {
    adj_matrix <- matrix(1, nrow = m, ncol = m, dimnames = list(L, L))
  }
  if (!all(L %in% rownames(adj_matrix)) || !all(L %in% colnames(adj_matrix))) {
    stop("Adjacency matrix must contain row and column names matching all levels in 'joint_counts'.")
  }
  adj_matrix <- adj_matrix[L, L, drop = FALSE]

  # v_i = w_i + sum_y N_y(C_i)/n * log(N_y(C_i)/n)
  weight_function <- function(clique_indices) {
    sub <- joint_counts[clique_indices, , drop = FALSE]
    D_i <- sum(sub)
    N_y <- colSums(sub)
    w_i <- -D_i / n * log(D_i / n)
    w_i + sum(safe_xlogx(N_y / n))
  }

  if (verbose) message("Starting clique finding...")
  pref_graph <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected")
  all_cliques <- igraph::cliques(pref_graph)

  if (verbose) message("Filtering out cliques with insufficient sample count...")
  valid_cliques <- lapply(all_cliques, function(clique) {
    indices <- as.numeric(clique)
    D_i <- sum(marginal_counts[indices])

    if (D_i < threshold) return(NULL)

    list(
      clique = clique,
      weight = weight_function(indices)
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

  lumped_mi <- empirical_entropy(colSums(joint_counts)) + sum(weights[res$solution == 1])
  mi_unlumped <- empirical_entropy(marginal_counts) +
    empirical_entropy(colSums(joint_counts)) -
    empirical_entropy(as.vector(joint_counts))

  list(
    mutual_information = lumped_mi,
    loss = mi_unlumped - lumped_mi,
    lumping = lumping
  )
}

#' Maximum information preservable by supervised hierarchical lumping
#'
#' Supervised analogue of [maximum_mutual_information_hierarchical()], exploiting
#' hierarchical structure to divide the problem into independent sub-problems.
#'
#' @param joint_counts Named numeric matrix as described in
#'   [maximum_mutual_information_nominal_supervised()].
#' @param threshold Minimum number of samples each lumped level must contain.
#' @param clusters List of character vectors; each vector names the levels
#'   that may be grouped together.
#' @param verbose Whether to print diagnostic messages. Default: `FALSE`.
#'
#' @inherit maximum_mutual_information_nominal_supervised return
#'
#' @seealso
#'   [maximum_mutual_information_hierarchical()] for the unsupervised version.
#'
#'   [maximum_mutual_information_nominal_supervised()] for the general version.
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_hierarchical_supervised <- function(joint_counts, threshold, clusters, verbose = FALSE) {
  if (!is.matrix(joint_counts) || !is.numeric(joint_counts)) {
    stop("Input 'joint_counts' must be a numeric matrix.")
  }
  if (is.null(rownames(joint_counts))) {
    stop("Input 'joint_counts' must have row names identifying the levels.")
  }
  if (length(threshold) != 1 ||
    !is.numeric(threshold) ||
    threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }

  L <- rownames(joint_counts)
  if (!all(L %in% unlist(clusters)) || !all(unlist(clusters) %in% L)) {
    stop("All levels in 'joint_counts' must be present in 'clusters' and vice versa.")
  }

  marginal_counts <- rowSums(joint_counts)

  lumping <- list()
  for (cluster in clusters) {
    if (verbose) message(paste("Examining cluster", paste(cluster, collapse = ", ")))
    res <- maximum_mutual_information_nominal_supervised(joint_counts[cluster, , drop = FALSE], threshold, verbose = verbose)
    lumping <- append(lumping, res$lumping)
  }

  lumped_marginals <- sapply(lumping, \(lump) sum(marginal_counts[lump]))
  lumped_joint <- do.call(rbind, lapply(lumping, \(lump) colSums(joint_counts[lump, , drop = FALSE])))
  mutual_information <- empirical_entropy(lumped_marginals) +
    empirical_entropy(colSums(joint_counts)) -
    empirical_entropy(as.vector(lumped_joint))
  mi_unlumped <- empirical_entropy(marginal_counts) +
    empirical_entropy(colSums(joint_counts)) -
    empirical_entropy(as.vector(joint_counts))

  list(
    mutual_information = mutual_information,
    loss = mi_unlumped - mutual_information,
    lumping = lumping
  )
}