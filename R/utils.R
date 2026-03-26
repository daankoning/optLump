lumping_equal <- function(A, B) {
  setequal(lapply(A, sort), lapply(B, sort))
}

