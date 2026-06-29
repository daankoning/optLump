lumping_equal <- function(A, B) {
  setequal(lapply(A, sort), lapply(B, sort))
}

#' Transform the edge list representation of a graph into an adjacency matrix
#'
#' This helper is useful for generating the inputs for functions
#' that expect preference graphs.
#'
#' @param levels The levels (and hence nodes) of the graph. This is needed since not all nodes neccesarily have an edge.
#' @param allow,disallow List of vectors of length 2 representing the edges that should be included or excluded from the
#'  graph. Exactly one of `allow` or `disallow` must be passed.
#'
#' @returns The adjacency matrix.
#'
#' @seealso
#'  [maximum_mutual_information_nominal()] and [maximum_mutual_information_nominal_heuristic()] for functions that accept an `adj_matrix`.
#'
#'  [maximum_mutual_information_nominal_supervised()] for the supervised analogue that also accepts an `adj_matrix`.
#'
#' @examples
#' levels <- c("A", "B", "C", "D")
#' edges <- list(c("A", "C"), c("D", "B"))
#' # Include the pairings from `edges`:
#' adjacency_from_edge_list(levels, allow = edges)
#' # Or exclude them:
#' adjacency_from_edge_list(levels, disallow = edges)
#'
#' @author Daan Koning
#' @export
adjacency_from_edge_list <- function(levels, allow = NULL, disallow = NULL) {
  if (!xor(is.null(allow), is.null(disallow))) {
    stop("Exactly one of `allow` or `disallow` must be specified")
  }

  if (anyDuplicated(levels)) {
    stop("Every entry of `levels` must be unique")
  }

  m <- length(levels)

  default_symb <- if (!is.null(allow)) 0 else 1
  positive_symb <- 1 - default_symb
  edge_list <- if (!is.null(allow)) allow else disallow

  if (!is.list(edge_list) || any(lengths(edge_list) != 2)) {
    stop("The edge list must be a list of vectors, each of length 2")
  }

  adj <- matrix(default_symb, nrow = m, ncol = m, dimnames = list(levels, levels))

  # TODO: this feels like it could be vectorized, but should be low priority
  # since this function is not a performance bottleneck anyways
  for (edge in edge_list) {
    if (!(edge[1] %in% levels) || !(edge[2] %in% levels)) {
      stop("All nodes in the edge list must be present in `levels`")
    }

    adj[edge[1], edge[2]] <- positive_symb
    adj[edge[2], edge[1]] <- positive_symb
  }

  adj
}


#' Visually help decide the correct threshold parameter
#'
#' Plots the information content of the variable to be lumped for
#' various values of the threshold.
#' This is useful for determining the correct value to use, in order
#' to not lose too much information: a good threshold is one that meets
#' the desired minimum level size without discarding much information,
#' typically just before the curve starts to drop off steeply.
#'
#' @param X Factor vector containing the variable to be lumped.
#' @param y Optional. The outcome variable for use with the supervised
#'  lumping functions.
#' @param thresholds The values of the threshold to test. Default:
#'  ranges from 1 to half the sample size.
#' @param lumping_mode Which type of lumping to do. Default: ordinal if `X` is ordered, nominal otherwise.
#' @param preference_graph The adjacency matrix of the preference graph. Error if passed and `lumping_mode`
#'  is not `"nominal"` or `"heuristic"`. Default: a complete graph.
#' @param clusters List of character vectors representing the levels that are allowed to be lumped together.
#'  Error if passed and `lumping_mode` is not `"hierarchical"`.
#' @param levels Character vector specifying the strict ordinal hierarchy of the levels (from lowest to
#'  highest). Only used when `lumping_mode` is `"ordinal"` and `X` is not already an ordered factor.
#' @param heuristic Which heuristic to use if `lumping_mode` is `"heuristic"`. Errors if passed but
#'  `lumping_mode` is not `"heuristic"`. See `vignette("metrics")` for an explanation of the heuristics.
#'  Default: `"smart"`.
#' @param outcome_mode Whether to treat `y` as discrete or continuous. Default: inferred based on the
#'  type of `y`.
#' @param plot Logical value dictating whether the diagnostic plot should be drawn. Set to `FALSE` to
#'  only obtain the returned data. Default: `TRUE` in an interactive session, `FALSE` otherwise.
#' @param ... Passed to [plot()].
#'
#' @returns Invisibly, a `data.frame` with columns `threshold` and `information` (the mutual
#'  information preserved at each tested threshold), for the feasible part of the range.
#'
#' @examples
#' n <- 100
#' m <- 10
#' data <- sample(LETTERS[1:m], n, replace = TRUE)
#' threshold_diagnostic(data, plot = TRUE)
#'
#' @seealso
#'  [lump_ordinal()], [lump_nominal()], and [lump_hierarchical()] for the
#'  unsupervised lumping functions whose `threshold` argument this helps choose.
#'
#'  [lump_ordinal_supervised()], [lump_nominal_supervised()], and
#'  [lump_hierarchical_supervised()] for the supervised counterparts, used when
#'  an outcome `y` is supplied.
#'
#' @author Daan Koning
#' @export
threshold_diagnostic <- function(X, y = NULL, thresholds = NULL, lumping_mode = c("auto", "ordinal", "nominal", "hierarchical", "heuristic"), preference_graph = NULL, clusters = NULL, levels = NULL, heuristic = c("smart", "largest", "other"), outcome_mode = c("auto", "discrete", "continuous"), plot = interactive(), ...) {
  lumping_mode <- match.arg(lumping_mode)
  if (lumping_mode == "auto") {
    lumping_mode <- if (is.ordered(X)) "ordinal" else "nominal"
  }

  if (!is.null(preference_graph) && !(lumping_mode %in% c("nominal", "heuristic"))) {
    stop("'preference_graph' is only valid when 'lumping_mode' is \"nominal\" or \"heuristic\".")
  }
  if (!is.null(clusters) && lumping_mode != "hierarchical") {
    stop("'clusters' is only valid when 'lumping_mode' is \"hierarchical\".")
  }
  if (!missing(heuristic) && lumping_mode != "heuristic") {
    stop("'heuristic' is only valid when 'lumping_mode' is \"heuristic\".")
  }

  supervised <- !is.null(y)
  if (supervised && lumping_mode == "heuristic") {
    stop("Supervised lumping is not supported for 'lumping_mode' \"heuristic\".")
  }

  outcome_mode <- match.arg(outcome_mode)
  if (supervised) {
    if (outcome_mode == "auto") {
      if (is.factor(y)) {
        outcome_mode <- "discrete"
      } else if (is.numeric(y)) {
        outcome_mode <- "continuous"
      } else {
        stop("Could not infer outcome mode based on the type of 'y'. Is it a factor or numeric vector?")
      }
    }
    if (lumping_mode == "hierarchical" && outcome_mode == "continuous") {
      stop("Continuous outcomes are not supported for 'lumping_mode' \"hierarchical\".")
    }
  }

  heuristic <- match.arg(heuristic)

  if (lumping_mode == "ordinal") {
    if (is.ordered(X)) {
      levels <- levels(X)
    } else if (is.null(levels)) {
      stop("For ordinal data, 'X' must be an ordered factor, or 'levels' must be provided to define the hierarchy.")
    }
    X <- ordered(X, levels = levels)
  } else {
    X <- as.factor(X)
  }

  if (supervised && outcome_mode == "discrete") {
    counts <- table(X, as.factor(y))
  } else {
    counts <- table(X)
  }

  mi_at <- switch(lumping_mode,
    ordinal = if (!supervised) {
      function(t) maximum_mutual_information_ordinal(counts, t)$mutual_information
    } else if (outcome_mode == "discrete") {
      function(t) maximum_mutual_information_ordinal_supervised(counts, t)$mutual_information
    } else {
      function(t) maximum_mutual_information_ordinal_supervised_continuous(X, y, t)$mutual_information
    },
    nominal = if (!supervised) {
      function(t) maximum_mutual_information_nominal(counts, t, preference_graph)$mutual_information
    } else if (outcome_mode == "discrete") {
      function(t) maximum_mutual_information_nominal_supervised(counts, t, preference_graph)$mutual_information
    } else {
      function(t) maximum_mutual_information_nominal_supervised_continuous(X, y, t, preference_graph)$mutual_information
    },
    hierarchical = if (!supervised) {
      function(t) maximum_mutual_information_hierarchical(counts, t, clusters)$mutual_information
    } else {
      function(t) maximum_mutual_information_hierarchical_supervised(counts, t, clusters)$mutual_information
    },
    heuristic = function(t) maximum_mutual_information_nominal_heuristic(counts, t, preference_graph, heuristic = heuristic)$mutual_information
  )

  if (is.null(thresholds)) {
    thresholds <- 1:(floor(length(X) / 2))
  }

  tested <- numeric(0)
  information <- numeric(0)
  for (t in thresholds) {
    mi <- tryCatch(mi_at(t), error = function(e) NA_real_)
    if (is.na(mi)) {
      break
    }
    tested <- c(tested, t)
    information <- c(information, mi)
  }

  if (length(tested) == 0) {
    stop("No feasible threshold found in the requested range.")
  }

  result <- data.frame(threshold = tested, information = information)

  if (plot) {
    n <- length(X)
    plot(
      result$threshold,
      y = result$information,
      type = "l",
      main = paste0("Information Content of Lumped Variable (n=", n, ")"),
      xlab = "threshold",
      ylab = "mutual information (nats)",
      ...
    )
  }

  invisible(result)
}