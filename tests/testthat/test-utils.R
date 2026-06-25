test_that("Default happy path works", {
  levels <- c("A", "B", "C", "D")
  edges <- list(c("A", "B"), c("C", "D"))

  expect_equal(
    adjacency_from_edge_list(levels, allow = edges),
    matrix(c(
      0, 1, 0, 0,
      1, 0, 0, 0,
      0, 0, 0, 1,
      0, 0, 1, 0
    ), byrow = TRUE, nrow = length(levels), dimnames = list(levels, levels)))

  expect_equal(
    adjacency_from_edge_list(levels, disallow = edges),
    matrix(c(
      1, 0, 1, 1,
      0, 1, 1, 1,
      1, 1, 1, 0,
      1, 1, 0, 1
    ), byrow = TRUE, nrow = length(levels), dimnames = list(levels, levels)))
})

test_that("input validation catches bad arguments", {
  levels <- c("A", "B", "C")
  edges <- list(c("A", "B"))

  expect_error(adjacency_from_edge_list(levels, allow = edges, disallow = edges), "Exactly one")
  expect_error(adjacency_from_edge_list(levels), "Exactly one")

  expect_error(adjacency_from_edge_list(levels, allow = list(c("A", "X"))), "All nodes in")

  expect_error(adjacency_from_edge_list(levels, allow = list(c("A", "B", "C"))), "The edge list")

  expect_error(adjacency_from_edge_list(c("A", "A", "B"), allow = edges), "Every entry of")
})

test_that("threshold_diagnostic returns a data.frame with decreasing information", {
  set.seed(1)
  x <- sample(LETTERS[1:6], 100, replace = TRUE)

  df <- threshold_diagnostic(x, thresholds = 1:20)

  expect_named(df, c("threshold", "information"))
  expect_true(all(diff(df$information) <= 1e-9))
})

test_that("threshold_diagnostic 'auto' picks the right mode", {
  set.seed(2)
  raw <- sample(c("low", "medium", "high"), 100, replace = TRUE)
  ord <- ordered(raw, levels = c("low", "medium", "high"))

  expect_equal(
    threshold_diagnostic(ord, thresholds = 1:10),
    threshold_diagnostic(ord, lumping_mode = "ordinal", thresholds = 1:10)
  )
  expect_equal(
    threshold_diagnostic(raw, thresholds = 1:10),
    threshold_diagnostic(raw, lumping_mode = "nominal", thresholds = 1:10)
  )
})

test_that("threshold_diagnostic supports supervised outcomes", {
  set.seed(3)
  x <- sample(LETTERS[1:5], 100, replace = TRUE)

  y_disc <- factor(sample(0:1, 100, replace = TRUE))
  df_disc <- threshold_diagnostic(x, y = y_disc, thresholds = 1:15)
  expect_named(df_disc, c("threshold", "information"))

  y_cont <- rnorm(100)
  df_cont <- threshold_diagnostic(x, y = y_cont, thresholds = 1:15)
  expect_named(df_cont, c("threshold", "information"))
})

test_that("threshold_diagnostic validates argument combinations", {
  set.seed(4)
  x <- sample(LETTERS[1:5], 50, replace = TRUE)
  ord <- ordered(sample(c("a", "b", "c"), 50, replace = TRUE), levels = c("a", "b", "c"))

  adj <- adjacency_from_edge_list(levels(ordered(x)), allow = list(c("A", "B")))

  expect_error(
    threshold_diagnostic(ord, lumping_mode = "ordinal", preference_graph = adj),
    "preference_graph"
  )
  expect_error(
    threshold_diagnostic(x, lumping_mode = "nominal", clusters = list(c("A", "B"))),
    "clusters"
  )
  expect_error(
    threshold_diagnostic(x, y = factor(sample(0:1, 50, replace = TRUE)), lumping_mode = "heuristic"),
    "heuristic"
  )
})