safe_xlogx <- function(x) {
  res <- x * log(x)
  res[x == 0] <- 0
  res
}

empirical_entropy <- function(counts) {
  n <- sum(counts)
  -sum(safe_xlogx(counts/n))
}

#' Maximum information preservable by ordinal lumping
#'
#' Calculates the way of lumping levels of an ordinal categorical covariate that preserves the maximum mutual
#' information between the lumped and unlumped levels.
#'
#' Since these two pursuits are equivalent, the actual quantity optimized for is not the mutual information,
#' but the empirical entropy of the lumped levels.
#'
#' The runtime complexity is cubic in the number of levels.
#'
#' @param counts     Ordered numeric vector containing the number of times each level is observed.
#' @param threshold  Minimum number of samples each level must contain.
#' @param alternative_metric The metric that should be optimised for, if it is different from the default,
#'  the mutual information. For an explanation of the metrics see `vignette("metrics")`.
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
#' @seealso
#'  [lump_ordinal()] for a more user-friendly wrapper around this function that actually carries out the lumping.
#'
#' @examples
#' maximum_mutual_information_ordinal(c(10, 5, 2, 8, 15), 15)
#'
#' @author Daan Koning
#' @export
maximum_mutual_information_ordinal <- function(counts, threshold, alternative_metric = c("mutual information", "bin count", "surplus")) {
  if (!is.numeric(counts) || any(is.na(counts)) || any(counts < 0)) {
    stop("Input 'counts' must be a numeric vector with no missing or negative values.")
  }
  if (length(threshold) != 1 || !is.numeric(threshold) || threshold <= 0) {
    stop("Input 'threshold' must be a single positive numeric value.")
  }

  n <- sum(counts)
  m <- length(counts)

  if (n == 0) {
    stop("Total number of samples is 0. Cannot perform lumping.")
  }
  if (n < threshold) {
    stop("Total sample size must be greater than threshold for lumping to be possible.")
  }

  C <- \(i, j) sum(counts[i:j])

  alternative_metric <- match.arg(alternative_metric)
  if (alternative_metric == "mutual information") {
    J <- \(i, j) safe_xlogx(C(i, j) / n) - sum(safe_xlogx(counts[i:j] / n))
  } else if (alternative_metric == "bin count") {
    J <- \(i, j) -1
  } else if (alternative_metric == "surplus") {
    J <- \(i, j) C(i, j) - threshold
  }

  # Holds the minimum entropy loss found for lumping the prefixes of the levels
  f <- rep(Inf, m + 1)
  f[1] <- 0

  # Holds the points at which we seperate the different lumped levels
  cut_points <- rep(NA_integer_, m)

  for (j in 1:m) {
    for (i in 1:j) {
      if (C(i, j) < threshold) next

      current_value <- f[i] + J(i, j)
      if (current_value < f[j + 1]) {
        f[j + 1] <- current_value
        cut_points[j] <- i
      }
    }
  }

  # Construct the actual lumping from the cut points
  lumping <- c()
  curr <- m
  while (curr > 0) {
    start_i <- cut_points[curr]
    lumping <- c(start_i, lumping)
    curr <- start_i - 1
  }
  lumping <- c(lumping, m + 1)

  # Calculate the information loss
  if (alternative_metric == "mutual information") {
    loss <- f[m + 1]
  } else {
    # walk through lumping and sum each loss
    loss <- 0
    for (k in 1:(length(lumping) - 1)) {
      i <- lumping[k]
      j <- lumping[k+1] - 1
      loss <- loss + safe_xlogx(C(i, j) / n) - sum(safe_xlogx(counts[i:j] / n))
    }
  }

  list(
    mutual_information = empirical_entropy(counts) - loss,
    loss = loss,
    lumping = lumping
  )
}