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