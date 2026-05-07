# Approximate the lumping on a nominal variable

Approximate the lumping on a nominal variable

## Usage

``` r
lump_nominal_heuristic(
  data,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE,
  heuristic = c("smart", "largest", "other"),
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

- heuristic:

  Character string specifying the heuristic to use. For explanation, see
  [`maximum_mutual_information_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_heuristic.md).

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Default:
  concatenating the original levels with a "+" in between.

## Value

A factor vector with the lumped levels.

## See also

[`maximum_mutual_information_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_heuristic.md)
for the underlying algorithm that this function wraps.

[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
for a non-approximate version of this function.

## Author

Daan Koning
