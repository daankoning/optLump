# Maximum information preservable by supervised hierarchical lumping

Supervised analogue of
[`maximum_mutual_information_hierarchical()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical.md),
exploiting hierarchical structure to divide the problem into independent
sub-problems.

## Usage

``` r
maximum_mutual_information_hierarchical_supervised(
  joint_counts,
  threshold,
  clusters,
  verbose = FALSE
)
```

## Arguments

- joint_counts:

  Named numeric matrix as described in
  [`maximum_mutual_information_nominal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised.md).

- threshold:

  Minimum number of samples each lumped level must contain.

- clusters:

  List of character vectors; each vector names the levels that may be
  grouped together.

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

## See also

[`maximum_mutual_information_hierarchical()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_hierarchical.md)
for the unsupervised version.

[`maximum_mutual_information_nominal_supervised()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_nominal_supervised.md)
for the general version.

## Author

Daan Koning

## Examples

``` r
joint_counts <- matrix(
  c(1, 1, 2, 0, 1, 2, 1, 1),
  nrow = 4,
  dimnames = list(c("Utrecht", "Friesland", "Bayern", "Sachsen"), c("y0", "y1"))
)
clusters <- list(c("Utrecht", "Friesland"), c("Bayern", "Sachsen"))
maximum_mutual_information_hierarchical_supervised(joint_counts, threshold = 3, clusters = clusters)
#> $mutual_information
#> [1] 0.005000792
#> 
#> $loss
#> [1] 0.1035853
#> 
#> $lumping
#> $lumping[[1]]
#> [1] "Utrecht"   "Friesland"
#> 
#> $lumping[[2]]
#> [1] "Bayern"  "Sachsen"
#> 
#> 
```
