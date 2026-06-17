# Maximum information preservable by nominal lumping

Calculates the maximum amount of mutual information that can be
preserved by lumping a nominal variable.

## Usage

``` r
maximum_mutual_information_nominal(
  counts,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE,
  alternative_metric = c("mutual information", "bin count", "surplus")
)
```

## Arguments

- counts:

  Named numeric vector containing the number of times each level is
  observed.

- threshold:

  Minimum number of samples each level must contain.

- adj_matrix:

  Adjancency matrix of the preference graph. Default: a complete graph,
  allowing all lumpings.

- verbose:

  Whether to print diagnostic messages or not. Default: `FALSE`.

- alternative_metric:

  The metric that should be optimised for, if it is different from the
  default, the mutual information. For an explanation of the metrics see
  [`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md).

## Value

A list containing information about the optimal lumping:

- mutual_information:

  Double representing the mutual information between the lumped and
  unlumped variable.

- loss:

  Double representing the amount of entropy lost in the lumping process.

- lumping:

  A list of character vectors, where each vector contains the names of
  the original levels that have been lumped together.

## Details

Since these two pursuits are equivalent, the actual quantity optimized
for is not the mutual information, but the empirical entropy of the
lumped levels.

Be advised that, since the problem is NP-hard, the implementation here
has time complexity \\O\left(2^{2^m}\right)\\, where \\m\\ is the number
of levels in the nominal variable.

## See also

[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
for a more user-friendly wrapper around this function that actually
carries out the lumping.

[`maximum_mutual_information_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_heuristic.md)
to approximate this function when the number of levels is too large.

[`maximum_mutual_information_hierarchical()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical.md)
for a version of this function that takes advantage of hierarchical
structure to speed up the execution time.

[`maximum_mutual_information_nominal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised.md)
for a supervised version of this function.

## Author

Daan Koning

## Examples

``` r
counts = c(A = 3, B = 1, C = 3, D = 2, E = 2)
threshold <- 3
maximum_mutual_information_nominal(counts, threshold)
#> $mutual_information
#> [1] 1.09006
#> 
#> $loss
#> [1] 0.456539
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "D" "E"
#> 
#> $lumping[[2]]
#> [1] "B" "C"
#> 
#> $lumping[[3]]
#> [1] "A"
#> 
#> 

# Or ban certain pairings:
preference_graph <- adjacency_from_edge_list(
 names(counts),
 disallow = list(c("B", "E"), c("D", "E"))
)
maximum_mutual_information_nominal(counts, threshold, preference_graph)
#> $mutual_information
#> [1] 1.06709
#> 
#> $loss
#> [1] 0.4795092
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "A"
#> 
#> $lumping[[2]]
#> [1] "C" "E"
#> 
#> $lumping[[3]]
#> [1] "B" "D"
#> 
#> 

# Or only allow certain pairings
preference_graph <- adjacency_from_edge_list(
 names(counts),
 allow = list(c("B", "E"), c("C", "D"), c("D", "E"))
)
maximum_mutual_information_nominal(counts, threshold, preference_graph)
#> $mutual_information
#> [1] 1.06709
#> 
#> $loss
#> [1] 0.4795092
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "A"
#> 
#> $lumping[[2]]
#> [1] "C" "D"
#> 
#> $lumping[[3]]
#> [1] "B" "E"
#> 
#> 
```
