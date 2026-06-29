# Perform supervised lumping on an ordinal variable

Lumps the levels of an ordered categorical variable, combining only
adjacent levels, so as to preserve as much mutual information as
possible with a supplied `outcome`. The outcome may be discrete (a
factor) or continuous (numeric); see
[`vignette("supervised")`](https://daankoning.github.io/optLump/articles/supervised.md)
for the distinction.

## Usage

``` r
lump_ordinal_supervised(
  data,
  outcome,
  threshold,
  levels = NULL,
  verbose = FALSE,
  level_namer = default_level_namer,
  outcome_mode = c("auto", "discrete", "continuous")
)
```

## Arguments

- data:

  Factor or character vector of the categorical data.

- outcome:

  Vector to be used as a source of information about `data`.

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

- outcome_mode:

  Whether to treat the outcome as discrete or continuous. Default:
  inferred based on the type of `outcome`.

## Value

An ordered factor vector with the lumped levels.

## See also

[`maximum_mutual_information_ordinal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_ordinal_supervised.md)
for the underlying algorithm that this function wraps.

[`lump_ordinal()`](https://daankoning.github.io/optLump/reference/lump_ordinal.md)
for the unsupervised version of this function.

## Author

Daan Koning

## Examples

``` r
# Discrete outcomes:
data    <- c("Low", "Medium", "Low", "High", "Medium",
             "Medium", "High", "High", "Low", "High")
outcome <- c(  0,      1,       0,     1,      1,
               0,      1,       1,     0,      1)
outcome <- factor(outcome)
lump_ordinal_supervised(data, outcome, threshold = 4,
                        levels = c("Low", "Medium", "High"))
#>  [1] Low+Medium Low+Medium Low+Medium High       Low+Medium Low+Medium
#>  [7] High       High       Low+Medium High      
#> Levels: Low+Medium < High

# It is also possible to directly pass ordered data:
data <- ordered(data, levels = c("Low", "Medium", "High"))
lump_ordinal_supervised(data, outcome, threshold = 4)
#>  [1] Low+Medium Low+Medium Low+Medium High       Low+Medium Low+Medium
#>  [7] High       High       Low+Medium High      
#> Levels: Low+Medium < High

# Alternatively, use a continuous outcome variable:
data <- c(rep("Low", 10), rep("Medium", 4), rep("High", 5))
n <- length(data)
outcome <- rnorm(n, mean = ifelse(data == "High", 10, 0))
lump_ordinal_supervised(data, outcome, threshold = 5,
                        levels = c("Low", "Medium", "High"))
#>  [1] Low+Medium Low+Medium Low+Medium Low+Medium Low+Medium Low+Medium
#>  [7] Low+Medium Low+Medium Low+Medium Low+Medium Low+Medium Low+Medium
#> [13] Low+Medium Low+Medium High       High       High       High      
#> [19] High      
#> Levels: Low+Medium < High
```
