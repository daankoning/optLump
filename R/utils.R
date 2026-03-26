lumping_equal <- function(A, B) {
  setequal(lapply(A, sort), lapply(B, sort))
}

#TODO: document
adjacancy_from_edge_list <- function(levels, allow = NULL, disallow = NULL) {
  # TODO: validate inputs
  if (!xor(is.null(allow), is.null(disallow))) {
    stop("Exactly one of `allow` or `disallow` must be specified")
  }
  m <- length(levels)

  default_symb <- if (!is.null(allow)) 0 else 1
  positive_symb <- 1 - default_symb
  edge_list <- if (!is.null(allow)) allow else disallow

  adj <- matrix(default_symb, nrow = m, ncol = m, dimnames = list(levels, levels))

  for (edge in edge_list) {
    adj[edge[1], edge[2]] <- positive_symb
    adj[edge[2], edge[1]] <- positive_symb
  }

  adj
}

#TODO: test