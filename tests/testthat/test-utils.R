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

test_that("apply_nominal_lumping applies a lumping", {
  data <- c("NL", "DE", "FR", "NL", "BE")
  lumping <- list(benelux = c("NL", "BE"), other = c("DE", "FR"))

  lumped <- apply_nominal_lumping(data, lumping)

  expect_equal(as.character(lumped), c("benelux", "other", "other", "benelux", "benelux"))
  expect_equal(levels(lumped), c("benelux", "other"))
  expect_false(is.ordered(lumped))
})

test_that("apply_ordinal_lumping applies a lumping in the given order", {
  data <- c("low", "high", "medium", "low", "very high")
  lumping <- list("low" = "low", "medium+" = c("medium", "high", "very high"))

  lumped <- apply_ordinal_lumping(data, lumping)

  expect_true(is.ordered(lumped))
  expect_equal(levels(lumped), c("low", "medium+"))
  expect_equal(as.character(lumped), c("low", "medium+", "medium+", "low", "medium+"))
})

test_that("the appliers name unnamed lumpings with the level namer", {
  data <- c("A", "B", "C")
  lumping <- list(c("A", "B"), "C")

  expect_equal(levels(apply_nominal_lumping(data, lumping)), c("A+B", "C"))
  expect_equal(
    levels(apply_ordinal_lumping(data, lumping, level_namer = \(x) paste(x, collapse = "-"))),
    c("A-B", "C")
  )
})

test_that("the appliers handle levels missing from the lumping or the data", {
  lumping <- list(ab = c("A", "B"), cd = c("C", "D"))

  # Levels in the lumping but not in the data are kept as empty levels
  lumped <- apply_nominal_lumping(c("A", "B", "C"), lumping)
  expect_equal(levels(lumped), c("ab", "cd"))
  expect_equal(as.character(lumped), c("ab", "ab", "cd"))

  # Levels in the data but not in the lumping become NA, with a warning
  expect_warning(lumped <- apply_nominal_lumping(c("A", "X", "C"), lumping), "not in the lumping")
  expect_equal(as.character(lumped), c("ab", NA, "cd"))

  expect_warning(lumped <- apply_ordinal_lumping(c("A", "X"), lumping), "not in the lumping")
  expect_equal(as.character(lumped), c("ab", NA))
})

test_that("the appliers validate the lumping", {
  data <- c("A", "B")

  expect_error(apply_nominal_lumping(data, "A"), "list of character vectors")
  expect_error(apply_nominal_lumping(data, list()), "list of character vectors")
  expect_error(apply_nominal_lumping(data, list(a = "A", "B")), "must be named")
  expect_error(apply_ordinal_lumping(data, list(a = "A", a = "B")), "must be unique")
  expect_error(apply_nominal_lumping(data, list(a = c("A", "B"), b = "A")), "exactly once")
})

test_that("apply_ordinal_lumping respects the level order of ordered data", {
  data <- ordered(c("low", "medium", "high"), levels = c("low", "medium", "high"))

  expect_error(
    apply_ordinal_lumping(data, list(a = c("low", "high"), b = "medium")),
    "level order"
  )

  lumped <- apply_ordinal_lumping(data, list(bottom = c("low", "medium"), top = "high"))
  expect_equal(levels(lumped), c("bottom", "top"))
})

test_that("applying an optimizer's lumping matches the lump_ functions", {
  set.seed(5)
  data <- sample(LETTERS[1:5], 60, replace = TRUE)

  res <- maximum_mutual_information_nominal(table(data), 15)
  expect_equal(
    as.character(apply_nominal_lumping(data, res$lumping)),
    as.character(lump_nominal(data, 15))
  )
})