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
