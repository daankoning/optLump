#TODO: document

#' Perform lumping on a hierarchical nominal variable
#'
#' @param data Factor or character vector of the categorical data
#' @param threshold The minimum number of samples each lumped level should contain
#' @param clusters List of character vectors representing the levels that are allowed to be lumped together.
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' data <- c("Germany", "Netherlands", "France", "France", "China", "China",
#'              "China", "China", "Vietnam", "Vietnam", "Japan", "Japan")
#' lump_hierarchical(
#'      data,
#'      4,
#'      list(c("Germany", "Netherlands", "France"), c("China", "Vietnam", "Japan"))
#' )
#'
#' @author Daan Koning
#' @export
lump_hierarchical <- function(data, threshold, clusters, verbose = FALSE) {
  #TODO: validate inputs
  data <- factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_hierarchical(counts, threshold, clusters, verbose = verbose)

  lumpings <- res$lumping
  names(lumpings) <- sapply(lumpings, \(x) paste(x, collapse = "+"))

  levels(data) <- lumpings #TODO: replace with forcats

  data
}

# TODO: this example can randomly break, so it should be tweaked
#' Perform lumping on a nominal variable
#'
#' @param data Factor or character vector of the categorical data
#' @param threshold The minimum number of samples each lumped level should contain
#' @param adj_matrix Adjancency matrix of the preference graph
#' @param verbose Logical value dictating if values should be printed. Default: `FALSE`
#'
#' @returns A factor vector with the lumped levels.
#'
#' @examples
#' m <- 10
#' n <- 100
#' data <- sample(LETTERS[1:m], n, replace = TRUE)
#' # Use a complete graph, so all lumpings are possible.
#' adj <- matrix(1, nrow = m, ncol = m, dimnames = list(LETTERS[1:m], LETTERS[1:m]))
#' lump_nominal(data, 15, adj)
#'
#' @author Daan Koning
#' @export
lump_nominal <- function(data, threshold, adj_matrix, verbose = FALSE) {
  #TODO: validate inputs
  data <- factor(data)
  counts <- table(data)

  res <- maximum_mutual_information_nominal(counts, threshold, adj_matrix, verbose = verbose)

  lumpings <- res$lumping
  names(lumpings) <- sapply(lumpings, \(x) paste(x, collapse = "+"))

  levels(data) <- lumpings #TODO: replace with forcats

  data
}

# TODO: test