lumping_equal <- function(A, B) {
  setequal(lapply(A, sort), lapply(B, sort))
}

#' Transforms the edge list representation of a graph into an adjacency matrix
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

