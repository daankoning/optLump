# Maximum information preservable by supervised nominal lumping

Calculates the maximum amount of mutual information between a lumped
nominal covariate and a discrete outcome that can be preserved by
lumping.

## Usage

``` r
maximum_mutual_information_nominal_supervised(
  joint_counts,
  threshold,
  adj_matrix = NULL,
  verbose = FALSE
)
```

## Arguments

- joint_counts:

  Named numeric matrix with one row per level and one column per outcome
  category. Row names must identify the levels. Entry (k, y) is the
  number of observations with covariate level k and outcome y.

- threshold:

  Minimum number of samples each lumped level must contain.

- adj_matrix:

  Adjacency matrix of the preference graph. Default: a complete graph,
  allowing all lumpings.

- verbose:

  Whether to print diagnostic messages. Default: `FALSE`.

## Value

A list containing information about the optimal lumping:

- mutual_information:

  Mutual information between the lumped covariate and the outcome, in
  nats.

- loss:

  Mutual information lost by the lumping.

- lumping:

  A list of character vectors, where each vector contains the names of
  the original levels that have been lumped together.

## Details

Be advised that, since the problem is NP-hard, the implementation here
has time complexity \\O\left(2^{2^m}\right)\\, where \\m\\ is the number
of levels in the nominal variable.

## See also

[`maximum_mutual_information_nominal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal.md)
for the unsupervised version.

[`maximum_mutual_information_hierarchical_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical_supervised.md)
for a version that exploits hierarchical structure to speed up
execution.

[`maximum_mutual_information_nominal_supervised_continuous()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised_continuous.md)
for a version that accepts a continuous outcome.

## Author

Daan Koning

## Examples

``` r
joint_counts <- matrix(
  c(8, 2, 1, 4, 1, 2),
  nrow = 3,
  dimnames = list(c("A", "B", "C"), c("y0", "y1"))
)
maximum_mutual_information_nominal_supervised(joint_counts, threshold = 3)
#> $mutual_information
#> [1] 0.03173431
#> 
#> $loss
#> [1] -2.220446e-16
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
