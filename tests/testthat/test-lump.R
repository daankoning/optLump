result_equal <- function(actual, expected) {
  for (level in names(expected)) {
    if (sum(actual == level) != expected[level]) return(FALSE)
  }
  TRUE
}

test_that("Ordinal happy path", {
  set.seed(0)
  n <- 100
  q <- 15
  levels <- c("A", "B", "C", "D", "E")
  data <- ordered(sample(levels, n, replace = TRUE, prob = c(0.1, 0.4, 0.3, 0.15, 0.05)), levels = levels)

  res <- lump_ordinal(data, q)

  expect_true(result_equal(res, c("A+B" = 50, C = 29, "D+E" = 21)))
})

test_that("Method of specifying order does not affect ordinal", {
  set.seed(0)
  n <- 100
  q <- 15
  levels <- c("A", "B", "C", "D", "E")
  data <- factor(sample(levels, n, replace = TRUE, prob = c(0.1, 0.4, 0.3, 0.15, 0.05)))
  ordered_data <- ordered(data, levels = levels)

  res1 <- lump_ordinal(data, q, levels = levels)
  res2 <- lump_ordinal(ordered_data, q)

  expect_true(result_equal(res1, res2))
})

test_that("Hierarchical happy path", {
  set.seed(0)
  n <- 100
  q <- 15
  data <- factor(sample(
    c("A", "B", "C", "D", "E", "F", "G", "H", "I"),
    n, replace = TRUE
  ))
  clusters <- list(
    c("A", "B", "C"),
    c("D", "E"),
    c("F", "G", "H", "I")
)

  res <- lump_hierarchical(data, q, clusters)

  expect_true(result_equal(res, c("A+B+C" = 30, "D+E" = 17, "H+I" = 21, "G" = 15, "F" = 17)))
})

test_that("Nominal (complete) happy path", {
  set.seed(0)
  m <- 14
  n <- 100
  q <- 10
  data <- sample(LETTERS[1:m], n, replace = TRUE)

  res <- lump_nominal(data, q)

  expect_true(
    result_equal(res, c("A+J" = 14, "B+N" = 13, "C+L" = 13, "D+M" = 13, "E+H" = 13, F = 11, G = 10, "I+K" = 13)) ||
      result_equal(res, c("A+N" = 14, "B+J" = 13, "C+L" = 13, "D+M" = 13, "E+H" = 13, F = 11, G = 10, "I+K" = 13))
  )
})

test_that("Hierarchical (complete) happy path", {
  set.seed(0)
  m <- 14
  n <- 100
  q <- 10
  data <- sample(LETTERS[1:m], n, replace = TRUE)

  res1 <- lump_nominal(data, q)
  res2 <- lump_nominal_heuristic(data, q)

  expect_true(result_equal(res1, res2))
})

test_that("Ordinal supervised happy path", {
  data <- ordered(
    c(rep("Low", 20), rep("Medium", 5), rep("High", 20)),
    levels = c("Low", "Medium", "High")
  )
  outcome <- factor(c(rep(0, 20), rep(0, 5), rep(1, 20)))

  res <- lump_ordinal_supervised(data, outcome, threshold = 10)

  expect_true(result_equal(res, c("Low+Medium" = 25, "High" = 20)))
})

test_that("Nominal supervised happy path", {
  data    <- c(rep("A", 10), rep("B", 10), rep("C", 15))
  outcome <- factor(c(rep(0, 10), rep(0, 10), rep(1, 15)))

  res <- lump_nominal_supervised(data, outcome, threshold = 15)

  expect_true(result_equal(res, c("A+B" = 20, "C" = 15)))
})

test_that("Hierarchical supervised happy path", {
  data <- c(rep("A", 8), rep("B", 8), rep("C", 15),
            rep("D", 8), rep("E", 8), rep("F", 15))
  outcome <- factor(c(rep(0, 8), rep(0, 8), rep(1, 15),
                      rep(0, 8), rep(0, 8), rep(1, 15)))
  clusters <- list(c("A", "B", "C"), c("D", "E", "F"))

  res <- lump_hierarchical_supervised(data, outcome, threshold = 15, clusters = clusters)

  expect_true(result_equal(res, c("A+B" = 16, "C" = 15, "D+E" = 16, "F" = 15)))
})