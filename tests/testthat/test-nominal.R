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

test_that("Preference merging (larger graph) works", {
  # complete:
  m <- 14
  threshold <- 5
  counts <- c(setNames(1:m, LETTERS[1:m]))

  res <- maximum_mutual_information_nominal(counts, threshold)
  expect_equal(res$mutual_information, 2.421229, tolerance = tolerance)
  expect_equal(res$loss, 0.05587686, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(
    c("A", "D"),
    c("B", "C"),
    c("E"),
    c("F"),
    c("G"),
    c("H"),
    c("I"),
    c("J"),
    c("K"),
    c("L"),
    c("M"),
    c("N")
  )))

  # non-complete:
  adj <- matrix(1, nrow = m, ncol = m, dimnames = list(names(counts), names(counts)))
  adj["A", LETTERS[9:m]] <- 0
  adj[LETTERS[9:m], "A"] <- 0
  adj["B", "H"] <- 0
  adj["H", "B"] <- 0

  res <- maximum_mutual_information_nominal(counts, 10, adj)

  # we are checking if it correctly merges A and B's constraings (since for A the lumping A+B+H is optimal, but B bans it)
  expect_true(lumping_equal(res$lumping, list(
    c("A", "C", "G"),
    c("E", "F"),
    c("D", "H"),
    c("B", "I"),
    c("N"),
    c("M"),
    c("L"),
    c("K"),
    c("J")
  )))
})

test_that("Default to complete graph works", {
  counts <- c(A = 1, B = 2, C = 5, D = 2, F = 2, G = 10)
  adj <- matrix(1, nrow = 6, ncol = 6, dimnames = list(names(counts), names(counts)))

  res1 <- maximum_mutual_information_nominal(counts, 4, adj)
  res2 <- maximum_mutual_information_nominal(counts, 4)

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

test_that("Input validation catches bad data", {
  # standard data for reference:
  counts <- c(A = 1, B = 1, C = 2)
  adj <- matrix(c(
    1, 1, 0,
    1, 1, 0,
    0, 0, 1
  ), nrow = 3, byrow = TRUE, dimnames = list(names(counts), names(counts)))

  expect_error(
    maximum_mutual_information_nominal(c(A = 1, B = -1, C = 2), 2, adj),
    "Input 'counts' must"
  )
  expect_error(
    maximum_mutual_information_nominal(c(A = 1, B = NA, C = 2), 2, adj),
    "Input 'counts' must"
  )
  expect_error(
    maximum_mutual_information_nominal(counts, -1, adj),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_nominal(c(A = 0, B = 0, C = 0), 2, adj),
    "Total number of"
  )
  expect_error(
    maximum_mutual_information_nominal(c(A = 1, B = 1, C = 2, D = 2), 2, adj),
    "Adjacency matrix must"
  )
  expect_error(
    maximum_mutual_information_nominal(c(A = 1, B = 1, D = 2), 2, adj),
    "Adjacency matrix must"
  )
})

test_that("Verbose generates messages", {
  counts <- c(A = 1, B = 1, C = 2)
  adj <- matrix(c(
    1, 1, 0,
    1, 1, 0,
    0, 0, 1
  ), nrow = 3, byrow = TRUE, dimnames = list(names(counts), names(counts)))

  suppressMessages(expect_message(maximum_mutual_information_nominal(counts, 2, adj, verbose = TRUE)))
})