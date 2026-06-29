# Approximate the lumping on a nominal variable

A drop-in approximation to
[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
for when the exact solver becomes too slow. It applies a greedy
heuristic that runs in polynomial time but does not guarantee the
optimal lumping. See
[`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md)
for the available heuristics.

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

## Examples

``` r
m <- 5
n <- 50
q <- 10
data <- sample(LETTERS[1:m], n, replace = TRUE)
lump_nominal_heuristic(data, q)
#>  [1] A   B+C A   D+E A   D+E A   B+C B+C D+E B+C D+E D+E B+C D+E A   D+E A   D+E
#> [20] A   A   D+E B+C D+E B+C A   D+E B+C A   B+C A   B+C D+E D+E D+E A   D+E B+C
#> [39] D+E B+C D+E B+C D+E B+C A   B+C B+C D+E B+C A  
#> Levels: A B+C D+E
```
