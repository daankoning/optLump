test_that("Default happy path works", {
  levels <- c("A", "B", "C", "D")
  edges <- list(c("A", "B"), c("C", "D"))

  expect_equal(
    adjacency_from_edge_list(levels, allow=edges),
    matrix(c(
      0, 1, 0, 0,
      1, 0, 0, 0,
      0, 0, 0, 1,
      0, 0, 1, 0
    ), byrow = TRUE, nrow = length(levels), dimnames = list(levels, levels)))

  expect_equal(
    adjacency_from_edge_list(levels, disallow=edges),
    matrix(c(
      1, 0, 1, 1,
      0, 1, 1, 1,
      1, 1, 1, 0,
      1, 1, 0, 1
    ), byrow = TRUE, nrow = length(levels), dimnames = list(levels, levels)))
})