tolerance <- 1e-6

# ordinal:

test_that("Happy path: levels with matching conditional Y distributions incur zero MI loss", {
  joint_counts <- matrix(
    c(10, 0,
      5, 0,
      5, 0,
      0, 10,
      0, 10),
    nrow = 5, byrow = TRUE
  )
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 15)

  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 6))
})

test_that("Do not lump at all when all levels already meet threshold", {
  amount <- 500
  joint_counts <- matrix(rep(c(2, 0, 0, 2), amount / 2), nrow = amount, byrow = TRUE)
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 2)

  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, 1:(amount + 1))
})

test_that("Lump all levels together when threshold is high", {
  joint_counts <- matrix(
    c(1, 0,
      0, 1,
      1, 0,
      0, 1),
    nrow = 4, byrow = TRUE
  )
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 4)

  expect_equal(res$mutual_information, 0, tolerance = tolerance)
  expect_equal(res$loss, log(2), tolerance = tolerance)
  expect_equal(res$lumping, c(1, 5))
})

test_that("Zero counts are handled properly", {
  # middle zero:
  joint_counts <- matrix(
    c(15, 0,
      0, 0,
      5, 0,
      0, 20),
    nrow = 4, byrow = TRUE
  )
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 15)
  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 5))

  # leading zero:
  joint_counts <- matrix(
    c(0, 0,
      15, 0,
      5, 0,
      0, 20),
    nrow = 4, byrow = TRUE
  )
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 15)
  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 5))

  # trailing zero:
  joint_counts <- matrix(
    c(15, 0,
      0, 0,
      5, 0,
      0, 20,
      0, 0),
    nrow = 5, byrow = TRUE
  )
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 15)
  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 6))
})

test_that("Algorithm succeeds when m = 1", {
  res <- maximum_mutual_information_ordinal_supervised(
    matrix(c(5, 5), nrow = 1), threshold = 5
  )

  expect_equal(res$mutual_information, 0, tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 2))
})

test_that("Impossible case is handled", {
  expect_error(
    maximum_mutual_information_ordinal_supervised(
      matrix(c(1, 0, 0, 1), nrow = 2, byrow = TRUE), threshold = 3
    ),
    "Total sample size"
  )
})

test_that("Input validation catches bad data", {
  expect_error(
    maximum_mutual_information_ordinal_supervised(c(10, 5, 10), threshold = 5),
    "Input 'joint_counts' must be a numeric matrix"
  )

  expect_error(
    maximum_mutual_information_ordinal_supervised(
      matrix(c(10, NA, 5, 3), nrow = 2), threshold = 5
    ),
    "Input 'joint_counts' must"
  )

  expect_error(
    maximum_mutual_information_ordinal_supervised(
      matrix(c(10, -5, 5, 3), nrow = 2), threshold = 5
    ),
    "Input 'joint_counts' must"
  )

  expect_error(
    maximum_mutual_information_ordinal_supervised(
      matrix(c(0, 0, 0, 0), nrow = 2), threshold = 5
    ),
    "Total sample size must be greater"
  )

  expect_error(
    maximum_mutual_information_ordinal_supervised(
      matrix(c(5, 5, 5, 5), nrow = 2), threshold = c(1, 1)
    ),
    "Input 'threshold' must"
  )

  expect_error(
    maximum_mutual_information_ordinal_supervised(
      matrix(c(5, 5, 5, 5), nrow = 2), threshold = -1
    ),
    "Input 'threshold' must"
  )
})

# nominal:

test_that("Happy path: merging levels with identical Y costs zero MI", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2),
                   nrow = 3, byrow = TRUE,
                   dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(c(1, 1, 0,
                  1, 1, 0,
                  0, 0, 1),
                nrow = 3, byrow = TRUE,
                dimnames = list(c("A", "B", "C"), c("A", "B", "C")))
  res <- maximum_mutual_information_nominal_supervised(counts, 2, adj)

  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(c("A", "B"), "C")))
})

test_that("Do not lump when all levels already meet threshold", {
  joint_counts <- matrix(c(2, 0, 0,
                           0, 2, 0,
                           0, 0, 2),
                         nrow = 3, byrow = TRUE,
                         dimnames = list(c("A", "B", "C"), c("y0", "y1", "y2")))
  adj <- matrix(1, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  res <- maximum_mutual_information_nominal_supervised(joint_counts, 2, adj)

  expect_equal(res$mutual_information, log(3), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list("A", "B", "C")))
})

test_that("Lump all levels when threshold is high", {
  joint_counts <- matrix(c(2, 0,
                           0, 2,
                           2, 0),
                         nrow = 3, byrow = TRUE,
                         dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(1, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  res <- maximum_mutual_information_nominal_supervised(joint_counts, 6, adj)

  expect_equal(res$mutual_information, 0, tolerance = tolerance)
  expect_equal(res$loss, -(4 / 6 * log(4 / 6) + 2 / 6 * log(2 / 6)), tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(c("A", "B", "C"))))
})

test_that("Order of columns in adjacency matrix does not matter", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2),
                   nrow = 3, byrow = TRUE,
                   dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj1 <- matrix(c(1, 1, 0,
                   1, 1, 0,
                   0, 0, 1),
                 nrow = 3, byrow = TRUE,
                 dimnames = list(c("A", "B", "C"), c("A", "B", "C")))
  adj2 <- matrix(c(1, 0, 1,
                   1, 0, 1,
                   0, 1, 0),
                 nrow = 3, byrow = TRUE,
                 dimnames = list(c("A", "B", "C"), c("A", "C", "B")))

  res1 <- maximum_mutual_information_nominal_supervised(counts, 2, adj1)
  res2 <- maximum_mutual_information_nominal_supervised(counts, 2, adj2)

  expect_equal(res1$mutual_information, res2$mutual_information, tolerance = tolerance)
  expect_equal(res1$loss, res2$loss, tolerance = tolerance)
  expect_true(lumping_equal(res1$lumping, res2$lumping))
})


test_that("Default to complete graph works", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2),
                   nrow = 3, byrow = TRUE,
                   dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(c(1, 1, 0,
                  1, 1, 0,
                  0, 0, 1),
                nrow = 3, byrow = TRUE,
                dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  res1 <- maximum_mutual_information_nominal_supervised(counts, 2, adj)
  res2 <- maximum_mutual_information_nominal_supervised(counts, 2)

  expect_equal(res1$mutual_information, res2$mutual_information, tolerance = tolerance)
  expect_equal(res1$loss, res2$loss, tolerance = tolerance)
  expect_true(lumping_equal(res1$lumping, res2$lumping))
})

test_that("Zero counts are handled properly", {
  joint_counts <- matrix(c(1, 0,
                           0, 0,
                           0, 1),
                         nrow = 3, byrow = TRUE,
                         dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(1, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  res <- maximum_mutual_information_nominal_supervised(joint_counts, 1, adj)

  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(c("A", "B"), "C")) ||
                lumping_equal(res$lumping, list("A", c("B", "C"))))
})

test_that("Impossible case (n too small) is handled", {
  joint_counts <- matrix(c(1, 0,
                           0, 1),
                         nrow = 2, byrow = TRUE,
                         dimnames = list(c("A", "B"), c("y0", "y1")))
  adj <- matrix(1, 2, 2, dimnames = list(c("A", "B"), c("A", "B")))

  expect_error(
    maximum_mutual_information_nominal_supervised(joint_counts, 3, adj),
    "Total sample size must"
  )
})

test_that("Error when no cliques meet threshold", {
  joint_counts <- matrix(c(1, 0,
                           0, 1),
                         nrow = 2, byrow = TRUE,
                         dimnames = list(c("A", "B"), c("y0", "y1")))
  adj <- diag(2)
  dimnames(adj) <- list(c("A", "B"), c("A", "B"))

  expect_error(
    maximum_mutual_information_nominal_supervised(joint_counts, 2, adj),
    "No lumping exists that satisfies the threshold"
  )
})

test_that("Generic impossible case throws error", {
  joint_counts <- matrix(c(1, 0,
                           0, 1,
                           1, 0),
                         nrow = 3, byrow = TRUE,
                         dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(c(1, 1, 0,
                  1, 1, 0,
                  0, 0, 1),
                nrow = 3, byrow = TRUE,
                dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  expect_error(
    maximum_mutual_information_nominal_supervised(joint_counts, 2, adj),
    "No lumping exists that is able to satisfy all constraints"
  )
})

test_that("Input validation catches bad data", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2),
                   nrow = 3, byrow = TRUE,
                   dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(c(1, 1, 0,
                  1, 1, 0,
                  0, 0, 1),
                nrow = 3, byrow = TRUE,
                dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  expect_error(
    maximum_mutual_information_nominal_supervised(c(A = 1, B = 1, C = 2), 2, adj),
    "Input 'joint_counts' must be a numeric matrix"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(
      matrix(c(1, NA, 1, 0, 0, 2), nrow = 3,
             dimnames = list(c("A", "B", "C"), c("y0", "y1"))), 2, adj),
    "Input 'joint_counts' must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(
      matrix(c(1, -1, 1, 0, 0, 2), nrow = 3,
             dimnames = list(c("A", "B", "C"), c("y0", "y1"))), 2, adj),
    "Input 'joint_counts' must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(
      matrix(c(1, 1, 0, 2), nrow = 2,  # no row names
             ncol = 2), 2),
    "Input 'joint_counts' must have row names"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(counts, -1, adj),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(counts, c(1, 1), adj),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(
      matrix(0, nrow = 3, ncol = 2,
             dimnames = list(c("A", "B", "C"), c("y0", "y1"))), 2, adj),
    "Total sample size must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised(
      matrix(c(1, 0, 1, 0, 0, 2, 1, 0), nrow = 4, byrow = TRUE,
             dimnames = list(c("A", "B", "C", "D"), c("y0", "y1"))), 2, adj),
    "Adjacency matrix must"
  )
})

# Hierarchical:

test_that("Hierarchical matches nominal for one cluster", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2),
                   nrow = 3, byrow = TRUE,
                   dimnames = list(c("A", "B", "C"), c("y0", "y1")))
  adj <- matrix(1, 3, 3, dimnames = list(rownames(counts), rownames(counts)))

  normal_res <- maximum_mutual_information_nominal_supervised(counts, 4, adj)
  hierarchical_res <- maximum_mutual_information_hierarchical_supervised(
    counts, 4, list(rownames(counts))
  )

  expect_equal(hierarchical_res$mutual_information, normal_res$mutual_information,
               tolerance = tolerance)
  expect_equal(hierarchical_res$loss, normal_res$loss, tolerance = tolerance)
  expect_true(lumping_equal(hierarchical_res$lumping, normal_res$lumping))
})

test_that("Hierarchical matches nominal for multiple clusters", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2,
                     1, 2,
                     3, 1,
                     0, 2),
                   nrow = 6, byrow = TRUE,
                   dimnames = list(c("A", "B", "C", "D", "E", "F"), c("y0", "y1")))
  adj <- matrix(c(1, 1, 1, 0, 0, 0,
                  1, 1, 1, 0, 0, 0,
                  1, 1, 1, 0, 0, 0,
                  0, 0, 0, 1, 1, 1,
                  0, 0, 0, 1, 1, 1,
                  0, 0, 0, 1, 1, 1
  ), nrow = 6, byrow = TRUE, dimnames = list(rownames(counts), rownames(counts)))
  clusters <- list(c("A", "B", "C"), c("D", "E", "F"))

  normal_res <- maximum_mutual_information_nominal_supervised(counts, 4, adj)
  hierarchical_res <- maximum_mutual_information_hierarchical_supervised(counts, 4, clusters)

  expect_equal(hierarchical_res$mutual_information, normal_res$mutual_information,
               tolerance = tolerance)
  expect_equal(hierarchical_res$loss, normal_res$loss, tolerance = tolerance)
  expect_true(lumping_equal(hierarchical_res$lumping, normal_res$lumping))
})

test_that("Hierarchical handles non-identical clusters and counts", {
  counts <- matrix(c(1, 0,
                     1, 0,
                     0, 2,
                     1, 2,
                     3, 1,
                     0, 2),
                   nrow = 6, byrow = TRUE,
                   dimnames = list(c("A", "B", "C", "D", "E", "F"), c("y0", "y1")))

  expect_error(
    maximum_mutual_information_hierarchical_supervised(
      counts, 4, list(c("A", "X", "C"), c("D", "E", "F"))
    ),
    "All levels in 'joint_counts' must"
  )
})

test_that("Input validation catches bad data", {
  counts <- matrix(c(3, 0, 0,
                     0, 3, 0,
                     0, 0, 3), nrow = 3, byrow = TRUE, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  expect_error(
    maximum_mutual_information_hierarchical_supervised(
      c(A = 1, B = 1, C = 2), 2, list(c("A", "B", "C"))
    ),
    "Input 'joint_counts' must be a numeric matrix"
  )
  expect_error(
    maximum_mutual_information_hierarchical_supervised(
      matrix(counts, nrow = 3), 2, list(c("A", "B", "C"))
    ),
    "Input 'joint_counts' must have row names"
  )
  expect_error(
    maximum_mutual_information_hierarchical_supervised(counts, -1, list(c("A", "B", "C"))),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_hierarchical_supervised(counts, c(1, 1), list(c("A", "B", "C"))),
    "Input 'threshold' must"
  )
})