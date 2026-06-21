# Supervised Lumping

In the introductory vignette
([`vignette("optLump")`](https://daankoning.github.io/optLump/articles/optLump.md))
we lumped a categorical variable by looking only at its own
distribution. This is the right thing to do when the variable is all we
have. More often, however, we are lumping a predictor because we
eventually want to model some outcome based on it. In that case we do
not really care about the predictor on its own; we care about what it
tells us about the outcome.

Supervised lumping takes this into account. Instead of preserving the
mutual information between the variable before and after lumping, it
preserves the mutual information between the lumped variable and an
outcome that we supply.[^1] In practice this means that two small levels
are lumped together when they say similar things about the outcome,
rather than simply when doing so keeps the distribution balanced.

Each of the supervised functions corresponds to one of the unsupervised
functions from
[`vignette("optLump")`](https://daankoning.github.io/optLump/articles/optLump.md).
They take the same arguments, with one addition: the `outcome` that
supervises the lumping.

``` r

library(optLump)
```

## Lumping with an Outcome

Suppose we are given some data on hospital admissions. For each patient
we know a triage `severity`, the `admission` route they came in through,
and the `hospital` that treated them. What we would like to model is
whether the patient was `readmitted` within a month, as well as their
`length_of_stay` in days.

``` r

summary(patients)
#>      severity           admission         hospital  readmitted length_of_stay  
#>  Minimal :22   GP            :51   St Thomas' :66   0:108      Min.   : 0.600  
#>  Mild    :60   Specialist    :58   Guy's      :59   1: 92      1st Qu.: 2.800  
#>  Moderate:14   Emergency     :56   Whittington:28              Median : 4.200  
#>  Severe  :48   Self-referral :15   Royal Free :24              Mean   : 5.937  
#>  Critical:56   Walk-in clinic:20   Homerton   :23              3rd Qu.: 8.325  
#>                                                                Max.   :30.100
```

As before, we want to lump the categories of the predictors together so
that every level meets some minimum sample size. The difference is that
we now want to do this without throwing away what the predictors tell us
about the outcome.

### Ordinal Variables

Just like in the unsupervised case, `severity` is ordinal, so we are
only allowed to lump levels that are next to each other in the ordering.
Suppose we want every level to contain at least 30 patients. Lumping
without the outcome looks only at the counts:

``` r

summary(lump_ordinal(severity, 30))
#>    Minimal+Mild Moderate+Severe        Critical 
#>              82              62              56
```

To meet the threshold, the algorithm has lumped the small `Moderate`
level in with `Severe`. This is a sensible choice if all we know are the
counts, but it is an unfortunate one here: `Moderate` patients are
rarely readmitted, whereas `Severe` patients usually are.

``` r

round(tapply(readmitted == "1", severity, mean), 2)
#>  Minimal     Mild Moderate   Severe Critical 
#>     0.27     0.17     0.21     0.75     0.66
```

If we supervise the lumping with the outcome, the algorithm can take
this into account. We simply pass the outcome in as the second argument:

``` r

summary(lump_ordinal_supervised(severity, readmitted, 30))
#> Minimal+Mild+Moderate                Severe              Critical 
#>                    96                    48                    56
```

This time `Moderate` is lumped with the lower-severity levels that it
actually resembles, and `Severe` is left on its own. The resulting
levels make a lot more sense if we are about to use them to predict
readmission.

#### Continuous Outcomes

The outcome does not have to be discrete. If we give it a numeric
outcome such as `length_of_stay`, the same function instead preserves
the mutual information between the lumped variable and that continuous
outcome, estimated using a nearest-neighbour approach (Ross 2014). By
default, optLump infers the type of the outcome from its class—a factor
is treated as discrete, a numeric vector as continuous—so there is
nothing extra to specify:

``` r

summary(lump_ordinal_supervised(severity, length_of_stay, 30))
#> Minimal+Mild+Moderate                Severe              Critical 
#>                    96                    48                    56
```

Since longer stays go hand in hand with higher severity, we end up with
the same grouping as before. Of course, if the automatic choice is ever
wrong – say the outcome is stored as integers but is really categorical
– we can set it by hand through the `outcome_mode` argument.

### Nominal Variables

For nominal variables we lose the ordering, so in principle any two
levels can be lumped together. `admission` is such a variable. Asking
once more for at least 25 patients per level, the unsupervised method
lumps together the two smallest levels:

``` r

summary(lump_nominal(admission, 25))
#>                           GP                   Specialist 
#>                           51                           58 
#>                    Emergency Self-referral+Walk-in clinic 
#>                           56                           35
```

`Self-referral` and `Walk-in clinic` are indeed the two rarest routes.
The trouble is that they disagree about the outcome: self-referred
patients are readmitted often, whereas walk-in patients hardly ever are.

``` r

round(tapply(readmitted == "1", admission, mean), 2)
#>             GP     Specialist      Emergency  Self-referral Walk-in clinic 
#>           0.47           0.50           0.39           0.67           0.35
```

The supervised version keeps them apart, and instead lumps each rare
level in with a larger one that behaves like it:

``` r

summary(lump_nominal_supervised(admission, readmitted, 25))
#>                       GP Specialist+Self-referral Emergency+Walk-in clinic 
#>                       51                       73                       76
```

Just as in the unsupervised case, we can supply a preference graph
through the `adj_matrix` argument to forbid certain pairings, and a
continuous outcome is handled exactly as it was for ordinal variables.
See
[`vignette("optLump")`](https://daankoning.github.io/optLump/articles/optLump.md)
for how to build a preference graph.

#### Hierarchical Variables

When the levels come with a known grouping,
[`lump_hierarchical_supervised()`](https://daankoning.github.io/optLump/reference/lump_hierarchical_supervised.md)
can take advantage of it, just like
[`lump_hierarchical()`](https://daankoning.github.io/optLump/reference/lump_hierarchical.md)
does in the unsupervised case. Suppose our five hospitals belong to two
networks, and that we only want to lump patients together within the
same network:

``` r

networks <- list(
  c("St Thomas'", "Guy's"),
  c("Whittington", "Royal Free", "Homerton")
)
summary(lump_hierarchical_supervised(hospital, readmitted, 25, clusters = networks))
#>          St Thomas'               Guy's         Whittington Royal Free+Homerton 
#>                  66                  59                  28                  47
```

Within each network, the rarest hospitals are lumped together in the way
that holds on to the most information about readmission. Unlike the
ordinal and nominal versions, the hierarchical function only supports
discrete outcomes.

## Computation and Large Datasets

The supervised functions behave computationally much like their
unsupervised counterparts.
[`lump_ordinal_supervised()`](https://daankoning.github.io/optLump/reference/lump_ordinal_supervised.md)
runs in time cubic in the number of levels.
[`lump_nominal_supervised()`](https://daankoning.github.io/optLump/reference/lump_nominal_supervised.md),
on the other hand, solves an NP-hard problem, so it is only practical
for a modest number of levels. When the data has a hierarchy,
[`lump_hierarchical_supervised()`](https://daankoning.github.io/optLump/reference/lump_hierarchical_supervised.md)
is substantially faster, since it only ever works on one cluster at a
time. For more on these trade-offs, and on the heuristics available when
the nominal problem becomes too slow, see
[`vignette("optLump")`](https://daankoning.github.io/optLump/articles/optLump.md).

## References

Ross, Brian C. 2014. “Mutual Information Between Discrete and Continuous
Data Sets.” *PLOS ONE* 9 (2): e87357.
<https://doi.org/10.1371/journal.pone.0087357>.

[^1]: For an explanation of mutual information, see
    [`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md).
