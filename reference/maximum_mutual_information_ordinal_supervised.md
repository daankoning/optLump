# Maximum information preservable by supervised ordinal lumping

Calculates the lumping of an ordinal categorical covariate that
preserves the maximum mutual information between the lumped covariate
and a discrete outcome variable.

## Usage

``` r
maximum_mutual_information_ordinal_supervised(joint_counts, threshold)
```

## Arguments

- joint_counts:

  Matrix with one row per level (in order) and one column per outcome
  category. Entry (k, y) is the number of observations with covariate
  level k and outcome y.

- threshold:

  Minimum number of samples each lumped level must contain.

## Value

A list containing information about the optimal lumping:

- mutual_information:

  Double representing the mutual information between the lumped and
  unlumped variable.

- loss:

  Double representing the amount of entropy lost in the lumping process.

- lumping:

  Integer vector containing, sequentially, the points at which the
  lumped levels are separated. Lower bound inclusive and upper bound
  exclusive, so that if a_1,...,a_k is returned, the lumped levels
  correspond to the levels \[a_1, a_2), ..., \[a\_(k-1), a_k).

## Details

The runtime complexity is cubic in the number of levels.

## See also

[`maximum_mutual_information_ordinal()`](https://daankoning.github.io/optLump/reference/maximum_mutual_information_ordinal.md)
for the unsupervised version.

## Author

Daan Koning

## Examples

``` r
joint_counts <- matrix(c(10, 2, 5, 8, 1, 9, 3, 7, 4, 6), nrow = 5)
maximum_mutual_information_ordinal_supervised(joint_counts, threshold = 10)
#> $mutual_information
#> [1] 0.004307169
#> 
#> $loss
#> [1] 0.04793657
#> 
#> $lumping
#> [1] 1 2 4 6
#> 
```
