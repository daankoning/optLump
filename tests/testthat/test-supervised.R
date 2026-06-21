tolerance <- 1e-6

# discrete ordinal:

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

# discrete nominal:

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

# continuous ordinal:

test_that("Do not lump at all when all ordinal levels already meet threshold", {
  x <- ordered(rep(c("A", "B", "C", "D"), each = 4), levels = c("A", "B", "C", "D"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8,
    5.5, 6.5, 7.5, 8.5
  )

  res <- maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = 4, k = 3)

  expect_equal(res$mutual_information, 0.2689144, tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, 1:5)
})

test_that("Lump all ordinal levels together when threshold is high", {
  x <- ordered(rep(c("A", "B", "C", "D"), each = 4), levels = c("A", "B", "C", "D"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8,
    5.5, 6.5, 7.5, 8.5
  )

  res <- maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = 16, k = 3)

  expect_equal(res$mutual_information, -0.5208333, tolerance = tolerance)
  expect_equal(res$loss, 0.7897478, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 5))
})

test_that("Intermediate threshold lumps some ordinal levels but not all", {
  x <- ordered(rep(c("A", "B", "C", "D"), each = 4), levels = c("A", "B", "C", "D"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8,
    5.5, 6.5, 7.5, 8.5
  )

  # Each level has 4 samples, so a threshold of 8 forces adjacent levels to be
  # merged in pairs without collapsing everything into a single level.
  res <- maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = 8, k = 3)

  expect_equal(res$mutual_information, 0.1587052, tolerance = tolerance)
  expect_equal(res$loss, 0.1102092, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 3, 5))
})

test_that("Continuous ordinal implementation rejects invalid inputs", {
  x <- factor(rep(c("A", "B", "C"), each = 3), levels = c("A", "B", "C"), ordered = TRUE)
  y <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)

  expect_error(
    maximum_mutual_information_ordinal_supervised_continuous(x[1:8], y, threshold = 3, k = 3),
    "must have the same length"
  )
  expect_error(
    maximum_mutual_information_ordinal_supervised_continuous(x, as.character(y), threshold = 3, k = 3),
    "Input 'y' must be a numeric vector"
  )
  expect_error(
    maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = c(1, 2), k = 3),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = -1, k = 3),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = 3, k = 0),
    "Input 'k' must"
  )
})

test_that("Continuous ordinal implementation rejects levels with too few samples for Ross", {
  x <- factor(rep(c("A", "B", "C"), each = 3), levels = c("A", "B", "C"), ordered = TRUE)
  y <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)

  expect_error(
    maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = 3, k = 3),
    "Every original ordinal level must contain more than 'k' samples"
  )
})

# continuous nominal:

test_that("Nominal continuous keeps singleton levels when the graph forbids merges", {
  x <- factor(rep(c("A", "B", "C"), each = 4), levels = c("A", "B", "C"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8
  )
  adj <- diag(3)
  dimnames(adj) <- list(levels(x), levels(x))

  res <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 4, adj_matrix = adj, k = 3)

  expect_equal(res$mutual_information, 0.1920996, tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list("A", "B", "C")))
})

test_that("Lump all nominal continuous levels together when threshold is high", {
  x <- factor(rep(c("A", "B", "C"), each = 4), levels = c("A", "B", "C"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8
  )
  adj <- matrix(1, 3, 3, dimnames = list(levels(x), levels(x)))

  res <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 12, adj_matrix = adj, k = 3)


  expect_equal(res$mutual_information, -0.4375, tolerance = tolerance)
  expect_equal(res$loss, 0.6295996, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(c("A", "B", "C"))))
})

test_that("Intermediate threshold lumps some nominal continuous levels but not all", {
  x <- factor(rep(c("A", "B", "C", "D"), each = 4), levels = c("A", "B", "C", "D"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8,
    5.5, 6.5, 7.5, 8.5
  )
  adj <- matrix(1, 4, 4, dimnames = list(levels(x), levels(x)))

  res <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 8, adj_matrix = adj, k = 3)

  expect_equal(res$mutual_information, 0.1587052, tolerance = tolerance)
  expect_equal(res$loss, 0.1102092, tolerance = tolerance)
  expect_true(lumping_equal(res$lumping, list(c("A", "B"), c("C", "D"))))
})

test_that("Order of columns in continuous nominal adjacency matrix does not matter", {
  x <- factor(rep(c("A", "B", "C"), each = 4), levels = c("A", "B", "C"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8
  )
  adj1 <- matrix(1, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))
  adj2 <- matrix(1, 3, 3, dimnames = list(c("A", "B", "C"), c("B", "C", "A")))

  res1 <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 12, adj_matrix = adj1, k = 3)
  res2 <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 12, adj_matrix = adj2, k = 3)

  expect_equal(res1$mutual_information, res2$mutual_information, tolerance = tolerance)
  expect_equal(res1$loss, res2$loss, tolerance = tolerance)
  expect_true(lumping_equal(res1$lumping, res2$lumping))
})

test_that("Default to complete graph works for continuous nominal lumping", {
  x <- factor(rep(c("A", "B", "C"), each = 4), levels = c("A", "B", "C"))
  y <- c(
    1, 2, 3, 4,
    1.5, 2.5, 3.5, 4.5,
    5, 6, 7, 8
  )
  adj <- matrix(1, 3, 3, dimnames = list(levels(x), levels(x)))

  res1 <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 12, adj_matrix = adj, k = 3)
  res2 <- maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 12, k = 3)

  expect_equal(res1$mutual_information, res2$mutual_information, tolerance = tolerance)
  expect_equal(res1$loss, res2$loss, tolerance = tolerance)
  expect_true(lumping_equal(res1$lumping, res2$lumping))
})

test_that("Continuous nominal implementation rejects invalid inputs", {
  x <- factor(rep(c("A", "B", "C"), each = 3), levels = c("A", "B", "C"))
  y <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)

  expect_error(
    maximum_mutual_information_nominal_supervised_continuous(x[1:8], y, threshold = 3, k = 3),
    "must have the same length"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised_continuous(x, as.character(y), threshold = 3, k = 3),
    "Input 'y' must be a numeric vector"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = c(1, 2), k = 3),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = -1, k = 3),
    "Input 'threshold' must"
  )
  expect_error(
    maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 3, k = 0),
    "Input 'k' must"
  )
})

test_that("Continuous nominal implementation rejects levels with too few samples for Ross", {
  x <- factor(rep(c("A", "B", "C"), each = 3), levels = c("A", "B", "C"))
  y <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)

  expect_error(
    maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 3, k = 3),
    "Every original nominal level must contain more than 'k' samples"
  )
})
