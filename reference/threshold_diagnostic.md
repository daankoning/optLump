# Visually help decide the correct threshold paramater

Plots the information content of the variable to be lumped for various
values of the threshold. This is useful for determining the correct
value to use, in order to not lose too much information.

## Usage

``` r
threshold_diagnostic(
  X,
  y = NULL,
  thresholds = NULL,
  lumping_mode = c("auto", "ordinal", "nominal", "hierarchical", "heuristic"),
  preference_graph = NULL,
  clusters = NULL,
  levels = NULL,
  heuristic = c("smart", "largest", "other"),
  outcome_mode = c("auto", "discrete", "continuous"),
  plot = interactive(),
  ...
)
```

## Arguments

- X:

  Factor vector containing the variable to be lumped.

- y:

  Optional. The outcome variable for use with the supervised lumping
  functions.

- thresholds:

  The values of the threshold to test. Default: ranges from 1 to half
  the sample size.

- lumping_mode:

  Which type of lumping to do. Default: ordinal if `X` is ordered,
  nominal otherwise.

- preference_graph:

  The adjacency matrix of the preference graph. Error if passed and
  `lumping_mode` is not `"nominal"` or `"heuristic"`. Default: a
  complete graph.

- clusters:

  List of character vectors representing the levels that are allowed to
  be lumped together. Error if passed and `lumping_mode` is not
  `"hierarchical"`.

- levels:

  Character vector specifying the strict ordinal hierarchy of the levels
  (from lowest to highest). Only used when `lumping_mode` is `"ordinal"`
  and `X` is not already an ordered factor.

- heuristic:

  Which heuristic to use if `lumping_mode` is `"heuristic"`. Errors if
  passed but `lumping_mode` is not `"heuristic"`. See
  [`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md)
  for an explanation of the heuristics. Default: `"smart"`.

- outcome_mode:

  Whether to treat `y` as discrete or continuous. Default: inferred
  based on the type of `y`.

- plot:

  Logical value dictating whether the diagnostic plot should be drawn.
  Set to `FALSE` to only obtain the returned data. Default: `TRUE` in an
  interactive session, `FALSE` otherwise.

- ...:

  Passed to [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

Invisibly, a `data.frame` with columns `threshold` and `information`
(the mutual information preserved at each tested threshold), for the
feasible part of the range.

## Author

Daan Koning

## Examples

``` r
n <- 100
m <- 10
data <- sample(LETTERS[1:m], n, replace = TRUE)
threshold_diagnostic(data, plot = TRUE)

```
