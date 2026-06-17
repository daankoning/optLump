# Maximum information preservable by supervised continuous nominal lumping

Calculates the maximum Ross-estimated mutual information between a
lumped nominal covariate and a numeric outcome.

## Usage

``` r
maximum_mutual_information_nominal_supervised_continuous(
  x,
  y,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE,
  k = 3L
)
```

## Arguments

- x:

  Nominal covariate. A factor is used in factor level order; otherwise
  the sorted unique values define the level order.

- y:

  Numeric outcome vector.

- threshold:

  Minimum number of samples each lumped level must contain.

- adj_matrix:

  Adjacency matrix of the preference graph. Default: complete graph,
  allowing all admissible cliques.

- verbose:

  Whether to print diagnostic messages. Default: `FALSE`.

- k:

  Number of nearest neighbours used by the Ross estimator. Default: 3.

## Value

A list containing information about the optimal lumping:

- mutual_information:

  Ross-estimated mutual information between the lumped covariate and the
  outcome, in nats.

- loss:

  Mutual information lost by the lumping.

- lumping:

  A list of character vectors, where each vector contains the names of
  the original levels that have been lumped together.

## See also

[`maximum_mutual_information_nominal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised.md)
for the discrete-outcome version.

[`maximum_mutual_information_ordinal_supervised_continuous()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_ordinal_supervised_continuous.md)
for the ordinal analogue.

[`lump_nominal_supervised()`](https://daankoning.github.io/optLump/reference/lump_nominal_supervised.md)
for a user-friendly wrapper that applies the lumping.

## Author

Daan Koning

## Examples

``` r
set.seed(1)
x <- factor(rep(c("A", "B", "C"), each = 5))
y <- c(rnorm(5, 0), rnorm(5, 0), rnorm(5, 3))
maximum_mutual_information_nominal_supervised_continuous(x, y, threshold = 5)
#> $mutual_information
#> [1] 0.2151883
#> 
#> $loss
#> [1] 4.440892e-16
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "C"
#> 
#> $lumping[[2]]
#> [1] "B"
#> 
#> $lumping[[3]]
#> [1] "A"
#> 
#> 
```
