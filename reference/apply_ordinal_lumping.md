# Apply a lumping to an ordinal variable

Transforms ordered categorical data by combining its levels according to
a given lumping. The order of the entries of the lumping defines the
order of the new levels, from lowest to highest. This makes it possible
to reuse a lumping, for example one learned on training data, on new
data.

## Usage

``` r
apply_ordinal_lumping(data, lumping, level_namer = default_level_namer)
```

## Arguments

- data:

  Factor or character vector of the categorical data. If `data` is an
  ordered factor, the lumping must respect its level order.

- lumping:

  Named list of character vectors, where each vector contains the
  original levels that are combined into a new level named after the
  entry. If the list is unnamed, names are generated with `level_namer`.

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Only used when
  `lumping` is unnamed. Default: concatenating the original levels with
  a "+" in between.

## Value

An ordered factor vector with the lumped levels.

## Details

Levels that appear in the lumping but not in the data are kept as empty
levels, so that applying the same lumping always yields the same factor
levels. Conversely, levels that appear in the data but not in the
lumping are replaced by `NA`, with a warning.

## See also

[`lump_ordinal()`](https://daankoning.github.io/optLump/reference/lump_ordinal.md)
to find and apply the optimal lumping in one step.

[`apply_nominal_lumping()`](https://daankoning.github.io/optLump/reference/apply_nominal_lumping.md)
for the nominal analogue of this function.

## Author

Daan Koning

## Examples

``` r
risk_group <- c("low", "high", "medium", "low", "very high")
lumping <- list("low" = "low", "medium+" = c("medium", "high", "very high"))
apply_ordinal_lumping(risk_group, lumping)
#> [1] low     medium+ medium+ low     medium+
#> Levels: low < medium+
```
