# Maximum information preservable by supervised continuous ordinal lumping

Calculates the lumping of an ordinal covariate that preserves the
maximum Ross-estimated mutual information with a numeric outcome.

## Usage

``` r
maximum_mutual_information_ordinal_supervised_continuous(
  x,
  y,
  threshold,
  k = 3L
)
```

## Arguments

- x:

  Ordinal covariate. A factor is interpreted in factor level order.
  Otherwise the sorted unique values are used as the ordinal levels.

- y:

  Numeric outcome vector.

- threshold:

  Minimum number of samples each lumped level must contain.

- k:

  Number of nearest neighbours used by the Ross estimator. Default: 3.

## Value

A list containing information about the optimal lumping:

- mutual_information:

  Double representing the Ross-estimated mutual information between the
  lumped covariate and the outcome.

- loss:

  Double representing the amount of information lost by lumping.

- lumping:

  Integer vector containing the cut points of the optimal lumping, in
  the same convention as the ordinal discrete implementation.

## See also

[`maximum_mutual_information_ordinal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_ordinal_supervised.md)
for the discrete-outcome version.

[`maximum_mutual_information_nominal_supervised_continuous()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised_continuous.md)
for the nominal analogue.

[`lump_ordinal_supervised()`](https://daankoning.github.io/optLump/reference/lump_ordinal_supervised.md)
for a user-friendly wrapper that applies the lumping.

## Author

Daan Koning

## Examples

``` r
set.seed(1)
x <- ordered(rep(c("Low", "Medium", "High"), each = 5),
             levels = c("Low", "Medium", "High"))
y <- c(rnorm(5, 0), rnorm(5, 2), rnorm(5, 4))
maximum_mutual_information_ordinal_supervised_continuous(x, y, threshold = 5)
#> $mutual_information
#> [1] 0.4307968
#> 
#> $loss
#> [1] 0
#> 
#> $lumping
#> [1] 1 2 3 4
#> 
```
