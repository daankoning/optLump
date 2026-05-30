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
