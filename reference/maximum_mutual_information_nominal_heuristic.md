# Approximate maximum information preservable by nominal lumping

Since the proper optimisation function,
[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md),
has superpolynomial time complexity, this function provides a heuristic
to find a good lumping in polynomial time.

## Usage

``` r
maximum_mutual_information_nominal_heuristic(
  counts,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE,
  heuristic = c("smart", "largest", "other")
)
```

## Arguments

- counts:

  Named numeric vector containing the number of times each level is
  observed.

- threshold:

  Minimum number of samples each level must contain.

- adj_matrix:

  Adjancency matrix of the preference graph. Default: a complete graph,
  allowing all lumpings.

- verbose:

  Whether to print diagnostic messages or not. Default: `FALSE`.

- heuristic:

  Character string specifying the algorithm to use. See
  [`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md)
  for their behaviour. Default: `"smart"`.

## Value

A list containing information about the optimal lumping:

- mutual_information:

  Double representing the mutual information between the lumped and
  unlumped variable.

- loss:

  Double representing the amount of entropy lost in the lumping process.

- lumping:

  A list of character vectors, where each vector contains the names of
  the original levels that have been lumped together.

## Details

The lumping returned is guaranteed to satisfy the constraints, but the
mutual information conserved is not guaranteed to be maximal.
Additionally, it is not guaranteed that a lumping is found at all, even
when it exists.

## See also

[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md)
for the non-approximate version of this function.

[`lump_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/lump_nominal_heuristic.md)
for a more user-friendly wrapper around this function that actually
carries out the lumping.

## Author

Daan Koning

## Examples

``` r
counts = c(A = 3, B = 1, C = 3, D = 2, E = 2)
threshold <- 3
maximum_mutual_information_nominal_heuristic(counts, threshold)
#> $mutual_information
#> [1] 1.06709
#> 
#> $loss
#> [1] 0.4795092
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "C"
#> 
#> $lumping[[2]]
#> [1] "B" "D"
#> 
#> $lumping[[3]]
#> [1] "A" "E"
#> 
#> 
```
