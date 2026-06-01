# Perform lumping on a hierarchical nominal variable

Perform lumping on a hierarchical nominal variable

## Usage

``` r
lump_hierarchical(
  data,
  threshold,
  clusters,
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

- clusters:

  List of character vectors representing the levels that are allowed to
  be lumped together.

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

[`maximum_mutual_information_hierarchical()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical.md)
for the underlying algorithm that this function wraps.

[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
for a more general version of this function that does not need the
hierarchical structure in the data, but may be slower.

## Author

Daan Koning

## Examples

``` r
country <- c("Germany", "Netherlands", "France", "France", "China", "China",
             "China", "China", "Vietnam", "Vietnam", "Japan", "Japan")
lump_hierarchical(
     country,
     4,
     list(c("Germany", "Netherlands", "France"), c("China", "Vietnam", "Japan"))
)
#>  [1] Germany+Netherlands+France Germany+Netherlands+France
#>  [3] Germany+Netherlands+France Germany+Netherlands+France
#>  [5] China                      China                     
#>  [7] China                      China                     
#>  [9] Vietnam+Japan              Vietnam+Japan             
#> [11] Vietnam+Japan              Vietnam+Japan             
#> Levels: China Germany+Netherlands+France Vietnam+Japan
```
