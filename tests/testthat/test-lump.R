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
  print(res)

  expect_true(result_equal(res, c("A+J" = 14, "B+N" = 13, "C+L" = 13, "D+M" = 13, "E+H" = 13, F = 11, G = 10, "I+K" = 13)))
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