# Perform lumping on a hierarchical nominal variable

Perform lumping on a hierarchical nominal variable

## Usage

``` r
lump_hierarchical_supervised(
  data,
  outcome,
  threshold,
  clusters,
  verbose = FALSE,
  level_namer = default_level_namer
)
```

## Arguments

- data:

  Factor or character vector of the categorical data.

- outcome:

  Factor or character vector. Variable to be used as a source of
  information about `data`.

- threshold:

  The minimum number of samples each lumped level should contain.

- clusters:

  List of character vectors representing the levels that are allowed to
  be lumped together.

- verbose:

  Logical value dictating if values should be printed. Default: `FALSE`.

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Default:
  concatenating the original levels with a "+" in between.

## Value

A factor vector with the lumped levels.

## See also

[`maximum_mutual_information_hierarchical_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical_supervised.md)
for the underlying algorithm that this function wraps.

[`lump_nominal_supervised()`](https://daankoning.github.io/optLump/reference/lump_nominal_supervised.md)
for a more general version of this function that does not need the
hierarchical structure in the data, but may be slower.

## Author

Daan Koning

## Examples

``` r
data <- c("Utrecht", "Utrecht", "Friesland",
          "Friesland", "Friesland", "Bayern",
          "Bayern", "Bayern", "Sachsen")
outcome <- c(1, 0, 1, 1, 0, 0, 0, 1, 1)
clusters <- list(
  c("Utrecht", "Friesland"),
  c("Bayern", "Sachsen")
)
lump_hierarchical_supervised(data, outcome, threshold = 3, clusters = clusters)
#> [1] Utrecht+Friesland Utrecht+Friesland Utrecht+Friesland Utrecht+Friesland
#> [5] Utrecht+Friesland Bayern+Sachsen    Bayern+Sachsen    Bayern+Sachsen   
#> [9] Bayern+Sachsen   
#> Levels: Bayern+Sachsen Utrecht+Friesland
```
