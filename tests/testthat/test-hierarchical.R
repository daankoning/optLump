tolerance <- 10^-6

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

test_that("Hierarchical handles non-identical clusters and counts", {
  counts <- c(A = 1, B = 1, C = 2, D = 4, E = 2, F = 2)
  threshold <- 4
  clusters <- list(c("A", "X", "C"), c("D", "E", "F"))

  expect_error(
    maximum_mutual_information_hierarchical(counts, threshold, clusters),
    "All levels in 'counts' must"
  )
})

test_that("Input validation catches bad data", {
    expect_error(
        maximum_mutual_information_hierarchical(c(A = 1, B = -1, C = 2), 5, list(c("A", "B", "C"))),
        "Input 'counts' must"
    )
    expect_error(
        maximum_mutual_information_hierarchical(c(A = 1, B = NA, C = 2), 5, list(c("A", "B", "C"))),
        "Input 'counts' must"
    )
    expect_error(
        maximum_mutual_information_hierarchical(c(A = 1, B = 1, C = 2), -1, list(c("A", "B", "C"))),
        "Input 'threshold' must"
    )
})

test_that("Alternative metric is passed through to each cluster", {
  counts <- c(A = 10, B = 5, C = 2, D = 8, E = 15, F = 20, G = 20)
  clusters <- list(c("A", "B", "C", "D", "E"), c("F", "G"))

  mi_res <- maximum_mutual_information_hierarchical(counts, 15, clusters)
  bin_res <- maximum_mutual_information_hierarchical(counts, 15, clusters, alternative_metric = "bin count")
  surplus_res <- maximum_mutual_information_hierarchical(counts, 15, clusters, alternative_metric = "surplus")

  expected <- list("E", c("A", "B", "C", "D"), "F", "G")
  expect_true(lumping_equal(bin_res$lumping, expected))
  expect_true(lumping_equal(surplus_res$lumping, expected))
  expect_false(lumping_equal(bin_res$lumping, mi_res$lumping))

  expect_equal(bin_res$mutual_information, 1.370502, tolerance = tolerance)
  expect_equal(bin_res$loss, 0.3922129, tolerance = tolerance)
  expect_equal(bin_res$mutual_information, surplus_res$mutual_information, tolerance = tolerance)
})
