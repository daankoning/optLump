# Maximum information preservable by ordinal lumping

Calculates the way of lumping levels of an ordinal categorical covariate
that preserves the maximum mutual information between the lumped and
unlumped levels.

## Usage

``` r
maximum_mutual_information_ordinal(
  counts,
  threshold,
  alternative_metric = c("mutual information", "bin count", "surplus")
)
```

## Arguments

- counts:

  Ordered numeric vector containing the number of times each level is
  observed.

- threshold:

  Minimum number of samples each level must contain.

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

  Integer vector containing, sequentially, the points at which the
  lumped levels are separated. Lower bound inclusive and upper bound
  exclusive, so that if a_1,...,a_k is returned, the lumped levels
  correspond to the levels \[a_1, a_2), ..., \[a\_(k-1), a_k).

## Details

Since these two pursuits are equivalent, the actual quantity optimized
for is the maximal empirical entropy of the lumped levels.

The runtime complexity is cubic in the number of levels.

## See also

[`lump_ordinal()`](https://daankoning.github.io/optLump/reference/lump_ordinal.md)
for a more user-friendly wrapper around this function that actually
carries out the lumping.

## Author

Daan Koning

## Examples

``` r
maximum_mutual_information_ordinal(c(10, 5, 2, 8, 15), 15)
#> $mutual_information
#> [1] 0.6818546
#> 
#> $loss
#> [1] 0.7641343
#> 
#> $lumping
#> [1] 1 4 6
#> 
```
