default_level_namer <- function(x) {
  paste(x, collapse = "+")
}

lumping_printer <- function(lumping) {
  col_1_width <- max(nchar(c("name", names(lumping))))
  col_1_padding <- col_1_width - nchar("name")

  entries <- sapply(lumping, \(x) paste(x, collapse = ","))
  col_2_width <- max(nchar(c("original levels", entries)))

  message(paste0("name", strrep(" ", col_1_padding), " | original levels"))
  message(strrep("-", col_1_width + col_2_width + 3))

  for (name in names(lumping)) {
    entry <- entries[name]
    message(paste0(name, strrep(" ", col_1_width - nchar(name)), " | ", entry, strrep(" ", col_2_width - nchar(entry))))
  }
}

#' Perform lumping on a hierarchical nominal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param clusters List of character vectors representing the levels that are allowed to be lumped together.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#' @param alternative_metric The metric that should be optimised for, if it is different from the default,
#'  the mutual information. For an explanation of the metrics see `vignette("metrics")`.
#' @param level_namer Function that takes a character vector of the original levels in a lump and returns the name of
#'  the new lumped level. Default: concatenating the original levels with a "+" in between.
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
lump_hierarchical <- function(data, threshold, clusters, verbose = FALSE, alternative_metric = c("mutual information", "bin count", "surplus"), level_namer = default_level_namer) {
  data <- as.factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_hierarchical(counts, threshold, clusters, verbose = verbose, alternative_metric = alternative_metric)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, level_namer)

  # Hack to preserve level order by sorting the lumping
  first_indices <- sapply(lumping, function(lvls) min(match(lvls, levels(data))))
  lumping <- lumping[order(first_indices)]

  levels(data) <- lumping

  if (verbose) {
    message(paste("Optimal lumping found with mutual information ", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}

#' Perform lumping on a nominal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param adj_matrix Adjancency matrix of the preference graph. Default: a complete graph, allowing all lumpings.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#' @param alternative_metric The metric that should be optimised for, if it is different from the default,
#'  the mutual information. For an explanation of the metrics see `vignette("metrics")`.
#' @param level_namer Function that takes a character vector of the original levels in a lump and returns the name of
#'  the new lumped level. Default: concatenating the original levels with a "+" in between.
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' m <- 5
#' n <- 50
#' q <- 10
#' data <- sample(LETTERS[1:m], n, replace = TRUE)
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
lump_nominal <- function(data, threshold, adj_matrix = NULL, verbose = FALSE, alternative_metric = c("mutual information", "bin count", "surplus"), level_namer = default_level_namer) {
  data <- as.factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_nominal(counts, threshold, adj_matrix, verbose = verbose, alternative_metric = alternative_metric)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, level_namer)

  # Hack to preserve level order by sorting the lumping
  first_indices <- sapply(lumping, function(lvls) min(match(lvls, levels(data))))
  lumping <- lumping[order(first_indices)]

  levels(data) <- lumping

  if (verbose) {
    message(paste("Optimal lumping found with mutual information", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}

#' Approximate the lumping on a nominal variable
#'
#' @inheritParams lump_nominal
#' @param heuristic Character string specifying the heuristic to use. For explanation, see [maximum_mutual_information_nominal_heuristic()].
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
lump_nominal_heuristic <- function(data, threshold, adj_matrix = NULL, verbose = FALSE, heuristic = c("smart", "largest", "other"), level_namer = default_level_namer) {
  data <- as.factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_nominal_heuristic(counts, threshold, adj_matrix, verbose = verbose, heuristic = heuristic)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, level_namer)

  # Hack to preserve level order by sorting the lumping
  first_indices <- sapply(lumping, function(lvls) min(match(lvls, levels(data))))
  lumping <- lumping[order(first_indices)]

  levels(data) <- lumping

  if (verbose) {
    message(paste("Lumping found with mutual information", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}

# Transform a lumping from the format returned by the ordinal solver
# to that of the nominal solver
transform_lumping <- function(lumping, orig_levels, level_namer) {
  new_lumping <- list()

  for (i in seq_len(length(lumping) - 1)) {
    start_idx <- lumping[i]
    end_idx <- lumping[i + 1] - 1

    group_levels <- orig_levels[start_idx:end_idx]
    new_name <- level_namer(group_levels)

    new_lumping[[new_name]] <- group_levels
  }

  new_lumping
}

#' Perform lumping on an ordinal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param levels Character vector specifying the strict ordinal hierarchy of the levels (from lowest to highest). Required if `data` is not already an ordered factor.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#' @param alternative_metric The metric that should be optimised for, if it is different from the default,
#'  the mutual information. For an explanation of the metrics see `vignette("metrics")`.
#' @param level_namer Function that takes a character vector of the original levels in a lump and returns the name of
#'  the new lumped level. Default: concatenating the original levels with a "+" in between.
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
lump_ordinal <- function(data, threshold, levels = NULL, verbose = FALSE, alternative_metric = c("mutual information", "bin count", "surplus"), level_namer = default_level_namer) {
  if (is.ordered(data)) {
    levels <- levels(data)
  } else {
    if (is.null(levels)) {
      stop("For ordinal data, 'data' must be an ordered factor, or 'levels' must be provided to define the hierarchy.")
    }
  }

  data <- ordered(data, levels = levels)
  counts <- table(data)

  res <- maximum_mutual_information_ordinal(counts, threshold, alternative_metric = alternative_metric)

  lumping <- transform_lumping(res$lumping, levels, level_namer)
  levels(data) <- lumping

  if (verbose) {
    message(paste("Optimal lumping found with mutual information", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}

# Supervised methods

#TODO: implement continuous variables
#TODO: reorder reference index
#' Perform supvervised lumping on a nominal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param outcome Factor or character vector. Variable to be used as a source of information about `data`.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param adj_matrix Adjancency matrix of the preference graph. Default: a complete graph, allowing all lumpings.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#' @param level_namer Function that takes a character vector of the original levels in a lump and returns the name of
#'  the new lumped level. Default: concatenating the original levels with a "+" in between.
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' data    <- c("NL", "NL", "DE", "DE", "FR", "FR", "FR", "BE")
#' outcome <- c(  1,    0,    1,    1,    0,    0,    1,    1)
#' lump_nominal_supervised(data, outcome, threshold = 3)
#'
#' @seealso
#'  [maximum_mutual_information_nominal_supervised()] for the underlying algorithm that this function wraps.
#'
#'  [lump_hierarchical_supervised()] for a version of this function that can take advantage of hierarchical structure in the data to speed up the execution time.
#'
#' @author Daan Koning
#' @export
lump_nominal_supervised <- function(data, outcome, threshold, adj_matrix = NULL, verbose = FALSE, level_namer = default_level_namer) {
  data <- as.factor(data)
  outcome <- as.factor(outcome)
  counts <- table(data, outcome)

  res <- maximum_mutual_information_nominal_supervised(counts, threshold, adj_matrix, verbose = verbose)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, level_namer)

  # Hack to preserve level order by sorting the lumping
  first_indices <- sapply(lumping, function(lvls) min(match(lvls, levels(data))))
  lumping <- lumping[order(first_indices)]

  levels(data) <- lumping

  if (verbose) {
    message(paste("Optimal lumping found with mutual information", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}

#' Perform lumping on a hierarchical nominal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param outcome Factor or character vector. Variable to be used as a source of information about `data`.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param clusters List of character vectors representing the levels that are allowed to be lumped together.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#' @param level_namer Function that takes a character vector of the original levels in a lump and returns the name of
#'  the new lumped level. Default: concatenating the original levels with a "+" in between.
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' data <- c("Utrecht", "Utrecht", "Friesland",
#'           "Friesland", "Friesland", "Bayern",
#'           "Bayern", "Bayern", "Sachsen")
#' outcome <- c(1, 0, 1, 1, 0, 0, 0, 1, 1)
#' clusters <- list(
#'   c("Utrecht", "Friesland"),
#'   c("Bayern", "Sachsen")
#' )
#' lump_hierarchical_supervised(data, outcome, threshold = 3, clusters = clusters)
#'
#' @seealso
#'  [maximum_mutual_information_hierarchical_supervised()] for the underlying algorithm that this function wraps.
#'
#'  [lump_nominal_supervised()] for a more general version of this function that does not need the hierarchical structure in the data, but may be slower.
#'
#' @author Daan Koning
#' @export
lump_hierarchical_supervised <- function(data, outcome, threshold, clusters, verbose = FALSE, level_namer = default_level_namer) {
  data <- as.factor(data)
  outcome <- as.factor(outcome)
  counts <- table(data, outcome)

  res <- maximum_mutual_information_hierarchical_supervised(counts, threshold, clusters, verbose = verbose)

  lumping <- res$lumping
  names(lumping) <- sapply(lumping, level_namer)

  # Hack to preserve level order by sorting the lumping
  first_indices <- sapply(lumping, function(lvls) min(match(lvls, levels(data))))
  lumping <- lumping[order(first_indices)]

  levels(data) <- lumping

  if (verbose) {
    message(paste("Optimal lumping found with mutual information ", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}

#' Perform lumping on an ordinal variable
#'
#' @param data Factor or character vector of the categorical data.
#' @param outcome Factor or character vector. Variable to be used as a source of information about `data`.
#' @param threshold The minimum number of samples each lumped level should contain.
#' @param levels Character vector specifying the strict ordinal hierarchy of the levels (from lowest to highest). Required if `data` is not already an ordered factor.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`.
#' @param level_namer Function that takes a character vector of the original levels in a lump and returns the name of
#'  the new lumped level. Default: concatenating the original levels with a "+" in between.
#'
#' @returns An ordered factor vector with the lumped levels.
#'
#' @examples
#' data    <- c("Low", "Medium", "Low", "High", "Medium",
#'              "Medium", "High", "High", "Low", "High")
#' outcome <- c(  0,      1,       0,     1,      1,
#'                0,      1,       1,     0,      1)
#' lump_ordinal_supervised(data, outcome, threshold = 3,
#'                         levels = c("Low", "Medium", "High"))
#'
#' @seealso
#'  [maximum_mutual_information_ordinal_supervised()] for the underlying algorithm that this function wraps.
#'
#' @author Daan Koning
#' @export
lump_ordinal_supervised <- function(data, outcome, threshold, levels = NULL, verbose = FALSE, level_namer = default_level_namer) {
  if (is.ordered(data)) {
    levels <- levels(data)
  } else {
    if (is.null(levels)) {
      stop("For ordinal data, 'data' must be an ordered factor, or 'levels' must be provided to define the hierarchy.")
    }
  }

  data <- ordered(data, levels = levels)
  outcome <- as.factor(outcome)
  counts <- table(data, outcome)

  res <- maximum_mutual_information_ordinal_supervised(counts, threshold)

  lumping <- transform_lumping(res$lumping, levels, level_namer)
  levels(data) <- lumping

  if (verbose) {
    message(paste("Optimal lumping found with mutual information", round(res$mutual_information, 4), "and loss", round(res$loss, 4)))
    lumping_printer(lumping)
  }

  data
}