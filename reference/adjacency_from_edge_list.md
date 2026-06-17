# Transform the edge list representation of a graph into an adjacency matrix

This helper is useful for generating the inputs for functions that
expect preference graphs.

## Usage

``` r
adjacency_from_edge_list(levels, allow = NULL, disallow = NULL)
```

## Arguments

- levels:

  The levels (and hence nodes) of the graph. This is needed since not
  all nodes neccesarily have an edge.

- allow, disallow:

  List of vectors of length 2 representing the edges that should be
  included or excluded from the graph. Exactly one of `allow` or
  `disallow` must be passed.

## Value

The adjacency matrix.

## See also

[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md)
and
[`maximum_mutual_information_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_heuristic.md)
for functions that accept an `adj_matrix`.

[`maximum_mutual_information_nominal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised.md)
for the supervised analogue that also accepts an `adj_matrix`.

## Author

Daan Koning

## Examples

``` r
levels <- c("A", "B", "C", "D")
edges <- list(c("A", "C"), c("D", "B"))
# Include the pairings from `edges`:
adjacency_from_edge_list(levels, allow = edges)
#>   A B C D
#> A 0 0 1 0
#> B 0 0 0 1
#> C 1 0 0 0
#> D 0 1 0 0
# Or exclude them:
adjacency_from_edge_list(levels, disallow = edges)
#>   A B C D
#> A 1 1 0 1
#> B 1 1 1 0
#> C 0 1 1 1
#> D 1 0 1 1
```
