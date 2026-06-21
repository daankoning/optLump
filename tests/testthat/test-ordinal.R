tolerance <- 10^-6

test_that("Default happy path", {
  res <- maximum_mutual_information_ordinal(c(10, 5, 2, 8, 15), 15)

  expect_equal(res$mutual_information, 0.6818546, tolerance = tolerance)
  expect_equal(res$loss, 0.7641343, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 6))
})

test_that("Do not lump at all when all levels already meet treshold", {
  amount <- 500
  res <- maximum_mutual_information_ordinal(rep(2, amount), 1)

  expect_equal(res$mutual_information, -log(1/amount), tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, 1:(amount+1))
})

test_that("Lump all levels together when threshold is high", {
  amount <- 500
  res <- maximum_mutual_information_ordinal(rep(1, amount), amount)

  expect_equal(res$mutual_information, 0, tolerance = tolerance)
  expect_equal(res$loss, -log(1/amount), tolerance = tolerance)
  expect_equal(res$lumping, c(1, amount+1))
})

test_that("Zero counts are handled properly", {
  #middle:
  res <- maximum_mutual_information_ordinal(c(15, 0, 5, 20), 15)
  expect_equal(res$mutual_information, -log(1 / 2), tolerance = tolerance)
  expect_equal(res$loss, 0.2811676, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 5))

  # leading:
  res <- maximum_mutual_information_ordinal(c(0, 15, 5, 20), 15)
  expect_equal(res$mutual_information, -log(1 / 2), tolerance = tolerance)
  expect_equal(res$loss, 0.2811676, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 5))

  # trailing:
  res <- maximum_mutual_information_ordinal(c(15, 0, 5, 20, 0), 15)
  expect_equal(res$mutual_information, -log(1 / 2), tolerance = tolerance)
  expect_equal(res$loss, 0.2811676, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 4, 6))
})

test_that("Algorithm succeeds when m = 1", {
  res <- maximum_mutual_information_ordinal(c(2), 1)

  expect_equal(res$mutual_information, 0, tolerance = tolerance)
  expect_equal(res$loss, 0, tolerance = tolerance)
  expect_equal(res$lumping, c(1, 2))
})

test_that("Impossible case is handled", {
  expect_error(
    maximum_mutual_information_ordinal(c(1, 1),  3),
    "Total sample size"
  )
})

test_that("Input validation catches bad data", {
  expect_error(
    maximum_mutual_information_ordinal(c(10, -5, 10), 5),
    "Input 'counts' must"
  )

  expect_error(
    maximum_mutual_information_ordinal(c(10, NA, 10), 5),
    "Input 'counts' must"
  )

  expect_error(
    maximum_mutual_information_ordinal(c("A", "B", "C"), 5),
    "Input 'counts' must"
  )

  expect_error(
    maximum_mutual_information_ordinal(c(0, 0, 0), 5),
    "Total number of samples"
  )

  expect_error(
    maximum_mutual_information_ordinal(c(0, 0, 0), c(1, 1)),
    "Input 'threshold' must"
  )

  expect_error(
    maximum_mutual_information_ordinal(c(0, 0, 0), -1),
    "Input 'threshold' must"
  )
})


test_that("Bin count metric returns a valid lumping that can differ from the MI optimum", {
  counts <- c(10, 5, 2, 8, 15)

  mi_res <- maximum_mutual_information_ordinal(counts, 15)
  res <- maximum_mutual_information_ordinal(counts, 15, alternative_metric = "bin count")

  expect_equal(res$lumping, c(1, 3, 6))
  expect_false(isTRUE(all.equal(res$lumping, mi_res$lumping)))

  expect_equal(res$mutual_information, 0.6615632, tolerance = tolerance)
  expect_equal(res$loss, 0.7844257, tolerance = tolerance)
  expect_equal(res$mutual_information + res$loss, empirical_entropy(counts), tolerance = tolerance)
})

test_that("Surplus metric returns a valid lumping that can differ from the MI optimum", {
  counts <- c(10, 5, 2, 8, 15)

  res <- maximum_mutual_information_ordinal(counts, 15, alternative_metric = "surplus")

  expect_equal(res$lumping, c(1, 3, 6))
  expect_equal(res$mutual_information, 0.6615632, tolerance = tolerance)
  expect_equal(res$loss, 0.7844257, tolerance = tolerance)
})
