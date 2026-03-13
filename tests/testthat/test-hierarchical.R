tolerance <- 10^-6

# FIXME: this should not be duplicated
lumping_equal <- function(A, B) {
  setequal(lapply(A, sort), lapply(B, sort))
}

test_that("Hierachical matches normal for only one cluster", {
  m <- 14
  threshold <- 5
  counts <- c(setNames(1:m, LETTERS[1:m]))
  adj <- matrix(1, nrow = m, ncol = m, dimnames = list(LETTERS[1:m], LETTERS[1:m]))

  hierarchical_res <- maximum_mutual_information_hierarchical(counts, threshold, list(LETTERS[1:m]))
  normal_res <- maximum_mutual_information_nominal(counts, threshold, adj)

  expect_equal(hierarchical_res$mutual_information, normal_res$mutual_information, tolerance = tolerance)
  expect_equal(hierarchical_res$loss, normal_res$loss, tolerance = tolerance)
  expect_true(lumping_equal(hierarchical_res$lumping, normal_res$lumping))
})

test_that("Hierarchical matches normal for multiple clusters", {
  counts <- c(A = 1, B = 1, C = 2, D = 4, E = 2, F = 2)
  threshold <- 4
  clusters <- list(c("A", "B", "C"), c("D", "E", "F"))
  adj <- matrix(c(
    1, 1, 1, 0, 0, 0,
    1, 1, 1, 0, 0, 0,
    1, 1, 1, 0, 0, 0,
    0, 0, 0, 1, 1, 1,
    0, 0, 0, 1, 1, 1,
    0, 0, 0, 1, 1, 1
  ), nrow = length(counts), byrow = TRUE, dimnames = list(names(counts), names(counts)))

  hierarchical_res <- maximum_mutual_information_hierarchical(counts, threshold, clusters)
  normal_res <- maximum_mutual_information_nominal(counts, threshold, adj)

  expect_equal(hierarchical_res$mutual_information, normal_res$mutual_information, tolerance = tolerance)
  expect_equal(hierarchical_res$loss, normal_res$loss, tolerance = tolerance)
  expect_true(lumping_equal(hierarchical_res$lumping, normal_res$lumping))
})