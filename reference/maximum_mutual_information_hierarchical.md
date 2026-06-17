# Maximum information preservable by hierarchical lumping

Calculates the maximum amount of mutual information that can be
preserved by lumping a nominal variable inherited from a hierarchy.

## Usage

``` r
maximum_mutual_information_hierarchical(
  counts,
  threshold,
  clusters,
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

- clusters:

  List of character vectors, each vector is the names of the levels that
  can be grouped together.

- verbose:

  Whether to print diagnostic messages or not. Default: `FALSE`

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

This acts as a wrapper around
[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md).
By passing the hierarchical structure via the `clusters` argument, the
algorithm divides the problem into independent sub-problems, speeding up
the execution time for large datasets.

## See also

[`lump_hierarchical()`](https://daankoning.github.io/optLump/reference/lump_hierarchical.md)
for a more user-friendly wrapper around this function that actually
carries out the lumping.

[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md)
for the fully general version of this function, which this one wraps.

[`maximum_mutual_information_hierarchical_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical_supervised.md)
for a supervised version of this function.

## Author

Daan Koning

## Examples

``` r
maximum_mutual_information_hierarchical(
     c(A = 1, B = 1, C = 2, D = 4, E = 2, F = 2),
     4,
     list(c("A", "B", "C"), c("D", "E", "F"))
)
#> $mutual_information
#> [1] 1.098612
#> 
#> $loss
#> [1] 0.5776227
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "A" "B" "C"
#> 
#> $lumping[[2]]
#> [1] "E" "F"
#> 
#> $lumping[[3]]
#> [1] "D"
#> 
#> 
```
