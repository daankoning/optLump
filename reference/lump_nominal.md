# Perform lumping on a nominal variable

Perform lumping on a nominal variable

## Usage

``` r
lump_nominal(
  data,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE,
  alternative_metric = c("mutual information", "bin count", "surplus"),
  level_namer = default_level_namer
)
```

## Arguments

- data:

  Factor or character vector of the categorical data.

- threshold:

  The minimum number of samples each lumped level should contain.

- adj_matrix:

  Adjancency matrix of the preference graph. Default: a complete graph,
  allowing all lumpings.

- verbose:

  Logical value dictating if values should be printed. Default: `FALSE`.

- alternative_metric:

  The metric that should be optimised for, if it is different from the
  default, the mutual information. For an explanation of the metrics see
  [`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md).

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Default:
  concatenating the original levels with a "+" in between.

## Value

A factor vector with the lumped levels.

## See also

[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md)
for the underlying algorithm that this function wraps.

[`lump_hierarchical()`](https://daankoning.github.io/optLump/reference/lump_hierarchical.md)
for a version of this function that can take advantage of hierarchical
structure in the data to speed up the execution time.

[`lump_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/lump_nominal_heuristic.md)
to approximate this function when the runtime becomes infeasible.

## Author

Daan Koning

## Examples

``` r
m <- 5
n <- 50
q <- 10
data <- sample(LETTERS[1:m], n, replace = TRUE)
lump_nominal(data, q)
#>  [1] E   A+D E   A+D A+D E   E   E   B   C   C   E   E   A+D E   B   A+D B   C  
#> [20] A+D C   E   A+D B   E   B   A+D A+D A+D B   C   A+D A+D B   E   A+D A+D C  
#> [39] A+D A+D C   B   C   B   B   C   A+D B   A+D C  
#> Levels: A+D B C E
```
