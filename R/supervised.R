#' Maximum information preservable by supervised ordinal lumping
#'
#' Calculates the lumping of an ordinal categorical covariate that preserves
#' the maximum mutual information between the lumped covariate and a discrete
#' outcome variable.
#'
#' The runtime complexity is cubic in the number of levels.
#'
#' @param joint_counts  Matrix with one row per level (in order) and one column
#'   per outcome category. Entry (k, y) is the number of observations with
#'   covariate level k and outcome y.
#' @param threshold  Minimum number of samples each lumped level must contain.
#'
#' @returns A list containing:
#' \describe{
#'   \item{mutual_information}{Mutual information between the lumped covariate
#'     and the outcome, in nats.}
#'   \item{loss}{Mutual information lost by the lumping.}
#'   \item{lumping}{Integer vector of cut points; lumped levels correspond to
#'     [a_1, a_2), ..., [a_{k-1}, a_k).}
#' }
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
  if (length(threshold) != 1 || !is.numeric(threshold) || threshold <= 0) {
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