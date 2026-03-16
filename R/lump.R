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

# TODO: test