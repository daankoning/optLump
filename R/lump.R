#TODO: document

#' Perform lumping on a hierarchical nominal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param clusters List of character vectors representing the levels that are allowed to be lumped together.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' country <- c("Germany", "Netherlands", "France", "France", "China", "China",
#'              "China", "China", "Vietnam", "Vietnam", "Japan", "Japan")
#' lump_hierarchical(
#'      country,
#'      4,
#'      list(c("Germany", "Netherlands", "France"), c("China", "Vietnam", "Japan"))
#' )
#'
#' @seealso
#'  [maximum_mutual_information_hierarchical()] for the underlying algorithm that this function wraps.
#'
#'  [lump_nominal()] for a more general version of this function that does not need the hierarchical structure in the data, but may be slower.
#'
#' @author Daan Koning
#' @export
lump_hierarchical <- function(data, threshold, clusters, verbose = FALSE) {
  #TODO: validate inputs
  data <- factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_hierarchical(counts, threshold, clusters, verbose = verbose)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, \(x) paste(x, collapse = "+"))

  levels(data) <- lumping

  data
}

#TODO: this should have an example of a non-complete pref graph
#' Perform lumping on a nominal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param adj_matrix Adjancency matrix of the preference graph. Default: a complete graph, allowing all lumpings.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' m <- 5
#' n <- 50
#' q <- 10
#' data <- sample(LETTERS[1:m], n, replace = TRUE)
#' # Data before lumping:
#' data
#' lump_nominal(data, q)
#'
#' @seealso
#'  [maximum_mutual_information_nominal()] for the underlying algorithm that this function wraps.
#'
#'  [lump_hierarchical()] for a version of this function that can take advantage of hierarchical structure in the data to speed up the execution time.
#'
#' [lump_nominal_heuristic()] to approximate this function when the runtime becomes infeasible.
#'
#' @author Daan Koning
#' @export
lump_nominal <- function(data, threshold, adj_matrix = NULL, verbose = FALSE) {
  #TODO: validate inputs
  data <- factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_nominal(counts, threshold, adj_matrix, verbose = verbose)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, \(x) paste(x, collapse = "+"))

  levels(data) <- lumping

  data
}

#' Approximate the lumping on a nominal variable
#'
#' @inheritParams lump_nominal
#' @param heuristic Character string specifying the heuristic to use. For explanation see [maximum_mutual_information_nominal_heuristic()].
#'
#' @inherit lump_nominal return
#'
#' @seealso
#'  [maximum_mutual_information_nominal_heuristic()] for the underlying algorithm that this function wraps.
#'
#'  [lump_nominal()] for a non-approximate version of this function.
#'
#' @author Daan Koning
#' @export
lump_nominal_heuristic <- function(data, threshold, adj_matrix = NULL, verbose = FALSE, heuristic = c("smart", "largest", "other")) {
  #TODO: validate inputs
  data <- factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_nominal_heuristic(counts, threshold, adj_matrix, verbose = verbose, heuristic = heuristic)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, \(x) paste(x, collapse = "+"))

  levels(data) <- lumping

  data
}

# Transform a lumping from the format returned by the ordinal solver
# to that of the nominal solver
transform_lumping <- function(lumping, orig_levels) {
  new_lumping <- list()

  for (i in seq_len(length(lumping) - 1)) {
    start_idx <- lumping[i]
    end_idx <- lumping[i + 1] - 1

    group_levels <- orig_levels[start_idx:end_idx]
    new_name <- paste(group_levels, collapse = "+")

    new_lumping[[new_name]] <- group_levels
  }

  new_lumping
}

#' Perform lumping on an ordinal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param levels Character vector specifying the strict ordinal hierarchy of the levels (from lowest to highest). Required if `data` is not already an ordered factor.
#'
#' @returns An ordered factor vector with the lumped levels.
#'
#' @examples
#' risk_group <- c("low", "medium", "very low", "high", "medium", "low",
#'                  "high", "medium", "low", "very high", "very low", "medium")
#'
#' # Provide the order of the levels:
#' strict_order <- c("very low", "low", "medium", "high", "very high")
#' lump_ordinal(risk_group, 3, levels = strict_order)
#'
#' # Alternatively, pass a pre-ordered factor:
#' risk_ordered <- ordered(risk_group, levels = strict_order)
#' lump_ordinal(risk_ordered, 3)
#'
#' @seealso
#'  [maximum_mutual_information_ordinal()] for the underlying algorithm that this function wraps.
#'
#' @author Daan Koning
#' @export
lump_ordinal <- function(data, threshold, levels = NULL) {
  #TODO: more input validation
  if (is.ordered(data)) {
    levels <- levels(data)
  } else {
    if (is.null(levels)) {
      stop("For ordinal data, 'data' must be an ordered factor, or 'levels' must be provided to define the hierarchy.")
    }
  }

  data <- ordered(data, levels = levels)
  counts <- table(data)

  res <- maximum_mutual_information_ordinal(counts, threshold)

  lumping <- transform_lumping(res$lumping, levels)
  levels(data) <- lumping

  data
}

# TODO: test