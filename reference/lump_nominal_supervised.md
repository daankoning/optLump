# Perform supervised lumping on a nominal variable

Lumps the levels of a nominal variable so as to preserve as much mutual
information as possible between the lumped variable and a supplied
`outcome`. The outcome may be discrete (a factor) or continuous
(numeric); see
[`vignette("supervised")`](https://daankoning.github.io/optLump/articles/supervised.md)
for the distinction.

## Usage

``` r
lump_nominal_supervised(
  data,
  outcome,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE,
  level_namer = default_level_namer,
  outcome_mode = c("auto", "discrete", "continuous")
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

- adj_matrix:

  Adjancency matrix of the preference graph. Default: a complete graph,
  allowing all lumpings.

- verbose:

  Logical value dictating if values should be printed. Default: `FALSE`.

- level_namer:

  Function that takes a character vector of the original levels in a
  lump and returns the name of the new lumped level. Default:
  concatenating the original levels with a "+" in between.

- outcome_mode:

  Whether to treat the outcome as discrete or continuous. Default:
  inferred based on the type of `outcome`.

## Value

A factor vector with the lumped levels.

## See also

[`maximum_mutual_information_nominal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised.md)
for the underlying algorithm that this function wraps.

[`lump_hierarchical_supervised()`](https://daankoning.github.io/optLump/reference/lump_hierarchical_supervised.md)
for a version of this function that can take advantage of hierarchical
structure in the data to speed up the execution time.

## Author

Daan Koning

## Examples

``` r
data    <-        c("NL", "NL", "DE", "DE", "FR", "FR", "FR", "BE")
outcome <- factor(c(  1,    0,    1,    1,    0,    0,    1,    1))
lump_nominal_supervised(data, outcome, threshold = 3)
#> [1] FR+NL FR+NL BE+DE BE+DE FR+NL FR+NL FR+NL BE+DE
#> Levels: BE+DE FR+NL
```
