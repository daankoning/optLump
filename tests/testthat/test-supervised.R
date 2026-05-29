tolerance <- 1e-6

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
    c( 0,  0,
      15,  0,
       5,  0,
       0, 20),
    nrow = 4, byrow = TRUE
  )
  res <- maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 15)
  expect_equal(res$mutual_information, log(2), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 5))

  # trailing zero:
  joint_counts <- matrix(
    c(15,  0,
       0,  0,
       5,  0,
       0, 20,
       0,  0),
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