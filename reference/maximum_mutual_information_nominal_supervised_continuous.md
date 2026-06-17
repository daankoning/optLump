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
