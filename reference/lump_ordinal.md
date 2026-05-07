# Perform lumping on an ordinal variable

Perform lumping on an ordinal variable

## Usage

``` r
lump_ordinal(
  data,
  threshold,
  levels = NULL,
  alternative_metric = c("mutual information", "bin count", "surplus"),
  level_namer = default_level_namer
)
```

## Arguments

- data:

  Factor or character vector of the categorical data.

- threshold:

  The minimum number of samples each lumped level should contain.

- levels:

  Character vector specifying the strict ordinal hierarchy of the levels
  (from lowest to highest). Required if `data` is not already an ordered
  factor.

- alternative_metric:

  The metric that should be optimised for, if it is different from the
  default, the mutual information. For an explanation of the metrics see
  [`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md).

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Default:
  concatenating the original levels with a "+" in between.

## Value

An ordered factor vector with the lumped levels.

## See also

[`maximum_mutual_information_ordinal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_ordinal.md)
for the underlying algorithm that this function wraps.

## Author

Daan Koning

## Examples

``` r
risk_group <- c("low", "medium", "very low", "high", "medium", "low",
                 "high", "medium", "low", "very high", "very low", "medium")

# Provide the order of the levels:
strict_order <- c("very low", "low", "medium", "high", "very high")
lump_ordinal(risk_group, 3, levels = strict_order)
#>  [1] very low+low   medium         very low+low   high+very high medium        
#>  [6] very low+low   high+very high medium         very low+low   high+very high
#> [11] very low+low   medium        
#> Levels: very low+low < medium < high+very high

# Alternatively, pass a pre-ordered factor:
risk_ordered <- ordered(risk_group, levels = strict_order)
lump_ordinal(risk_ordered, 3)
#>  [1] very low+low   medium         very low+low   high+very high medium        
#>  [6] very low+low   high+very high medium         very low+low   high+very high
#> [11] very low+low   medium        
#> Levels: very low+low < medium < high+very high
```
