# Apply a lumping to a nominal variable

Transforms categorical data by combining its levels according to a given
lumping, such as one previously found by
[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md).
This makes it possible to reuse a lumping, for example one learned on
training data, on new data.

## Usage

``` r
apply_nominal_lumping(data, lumping, level_namer = default_level_namer)
```

## Arguments

- data:

  Factor or character vector of the categorical data.

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

A factor vector with the lumped levels.

## Details

Levels that appear in the lumping but not in the data are kept as empty
levels, so that applying the same lumping always yields the same factor
levels. Conversely, levels that appear in the data but not in the
lumping are replaced by `NA`, with a warning.

## See also

[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
to find and apply the optimal lumping in one step.

[`apply_ordinal_lumping()`](https://daankoning.github.io/optLump/reference/apply_ordinal_lumping.md)
for the ordinal analogue of this function.

## Author

Daan Koning

## Examples

``` r
country <- c("NL", "DE", "FR", "NL", "BE")
lumping <- list(benelux = c("NL", "BE"), other = c("DE", "FR"))
apply_nominal_lumping(country, lumping)
#> [1] benelux other   other   benelux benelux
#> Levels: benelux other
```
