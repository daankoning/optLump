# Perform lumping on an ordinal variable

Perform lumping on an ordinal variable

## Usage

``` r
lump_ordinal_supervised(
  data,
  outcome,
  threshold,
  levels = NULL,
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

- levels:

  Character vector specifying the strict ordinal hierarchy of the levels
  (from lowest to highest). Required if `data` is not already an ordered
  factor.

- verbose:

  Logical value dictating if values should be printed. Default: `FALSE`.

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Default:
  concatenating the original levels with a "+" in between.

## Value

An ordered factor vector with the lumped levels.

## See also

[`maximum_mutual_information_ordinal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_ordinal_supervised.md)
for the underlying algorithm that this function wraps.

## Author

Daan Koning

## Examples

``` r
data    <- c("Low", "Medium", "Low", "High", "Medium",
             "Medium", "High", "High", "Low", "High")
outcome <- c(  0,      1,       0,     1,      1,
               0,      1,       1,     0,      1)
lump_ordinal_supervised(data, outcome, threshold = 3,
                        levels = c("Low", "Medium", "High"))
#>  [1] Low    Medium Low    High   Medium Medium High   High   Low    High  
#> Levels: Low < Medium < High
```
