tolerance <- 10^-6

lumping_equal <- function(A, B) {
  setequal(lapply(A, sort), lapply(B, sort))
}

test_that("Default happy path", {
  counts <- c(A = 1, B = 1, C = 2)
  adj <- matrix(c(
    1, 1, 0,
    1, 1, 0,
    0, 0, 1
  ), nrow = 3, byrow = TRUE, dimnames = list(names(counts), names(counts)))

  res <- maximum_mutual_information_nominal(counts, 2, adj)

  expect_equal(res$mutual_information, -log(1/2), tolerance = tolerance)
  expect_equal(res$loss, -1/2 * log(1/2), tolerance = tolerance)
  expect_true(lumping_equal(res$lumping,  list(c("A", "B"), "C")))
})

test_that("Do not lump at all when all levels already meet threshold", {
  counts <- c(A = 2, B = 2, C = 2)
  adj <- matrix(1, nrow = 3, ncol = 3, dimnames = list(names(counts), names(counts)))

  res <- maximum_mutual_information_nominal(counts, 1, adj)

  expect_equal(res$mutual_information, -log(1/3), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list("A", "B", "C")))
})

test_that("Lump all levels together when threshold is high", {
  counts <- c(A = 2, B = 2, C = 2)
  adj <- matrix(1, nrow = 3, ncol = 3, dimnames = list(names(counts), names(counts)))

  res <- maximum_mutual_information_nominal(counts, 6, adj)

  expect_equal(res$mutual_information, 0, tolerance = tolerance)
  expect_equal(res$loss, -log(1/3), tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(c("A", "B", "C"))))
})

test_that("Order of columns in adjacency matrix does not matter", {
  counts <- c(A = 1, B = 1, C = 2)
  adj1 <- matrix(c(
    1, 1, 0,
    1, 1, 0,
    0, 0, 1
  ), nrow = 3, byrow = TRUE, dimnames = list(names(counts), names(counts)))
  adj2 <- matrix(c(
    1, 0, 1,
    1, 0, 1,
    0, 1, 0
  ), nrow = 3, byrow = TRUE, dimnames = list(names(counts), c("A", "C", "B")))

  res1 <- maximum_mutual_information_nominal(counts, 2, adj1)
  res2 <- maximum_mutual_information_nominal(counts, 2, adj2)

  expect_equal(res1$mutual_information, res2$mutual_information, tolerance = tolerance)
  expect_equal(res1$loss, res2$loss, tolerance = tolerance)
  expect_true(lumping_equal(res1$lumping,  res2$lumping))
})

test_that("Zero counts are handled properly", {
  counts <- c(A = 1, B = 0, C = 1)
  adj <- matrix(1, nrow = 3, ncol = 3, dimnames = list(names(counts), names(counts)))

  res <- maximum_mutual_information_nominal(counts, 1, adj)

  expect_equal(res$mutual_information, -log(1 / 2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  # need to have or since ILP is non-deterministc and both have equal entropy
  expect_true(lumping_equal(res$lumping,  list(c("A", "B"), "C"))
                || lumping_equal(res$lumping,  list("A", c("B", "C"))))
})

test_that("Impossible case (n too small) is handled", {
  counts <- c(A = 1, B = 1)
  adj <- matrix(1, nrow = 2, ncol = 2, dimnames = list(names(counts), names(counts)))

  expect_error(
    maximum_mutual_information_nominal(counts, 3, adj),
    "Total sample size must"
  )
})

test_that("Error when no cliques meet threshold", {
  counts <- c(A = 1, B = 1)
  adj <- matrix(0, nrow = 2, ncol = 2, dimnames = list(names(counts), names(counts)))
  diag(adj) <- 1

  expect_error(
    maximum_mutual_information_nominal(counts, 2, adj),
    "No lumping exists that satisfies the threshold"
  )
})

test_that("Generic impossible case throws error", {
  counts <- c(A = 1, B = 1, C = 1)
  adj <- matrix(c(
    1, 1, 0,
    1, 1, 0,
    0, 0, 1
  ), nrow = 3, byrow = TRUE, dimnames = list(names(counts), names(counts)))

  expect_error(
    maximum_mutual_information_nominal(counts, 2, adj),
    "No lumping exists that is able to satisfy all constraints"
  )
})

#TODO: test input validation