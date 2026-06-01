# Introduction to optLump

Categorical variables with many rare levels can often cause problems
such as overfitting. A potential solution is to lump these rare
categories together, to ensure every level meets a minimum sample size
constraint.

Unlike naive approaches that simply lump the smallest levels into a
generic `Other` category, `optLump` uses information theory to find the
combinations that preserve the maximum amount of mutual information from
the original data distribution. For an (abridged) explanation of mutual
information, see
[`vignette("metrics")`](https://daankoning.github.io/optLump/articles/metrics.md).

> **Note**
>
> This vignette only covers the primary usecase of optLump, looking
> purely at the distribution of the variable of interest. To take into
> account more information, see
> [`vignette("supervised")`](https://daankoning.github.io/optLump/articles/supervised.md).

## Handling Different Types of Variables

Suppose we are given some data containing a response variable `outcome`,
based on some predictors, which are categorical:

``` r

summary(data)
#>     outcome         education_level         diagnosis  country_of_origin
#>  Min.   :0.00   <High School:14     Diabetes     :22   China  :17       
#>  1st Qu.:0.00   High School :41     Heart Disease:10   Japan  :15       
#>  Median :1.00   Bachelor's  :28     Hypertension :19   Mexico :12       
#>  Mean   :1.07   Master's    :14     None         :49   Vietnam:12       
#>  3rd Qu.:2.00   PhD         : 3                        US     :11       
#>  Max.   :4.00                                          Germany:10       
#>                                                        (Other):23
```

This means that we would be trying to model `outcome` as a function of
the predictors. The goal we want to achieve is to lump the categories of
the predictors together in order to reduce the dimensionality of the
problem. The treatment for each type of variable is different, and
optLump provides different methods for each type of variable.

``` r

library(optLump)
```

### Ordinal Variables

The simplest case is that of ordinal variables, which are variables that
have a natural ordering of the categories. In our example, the variable
`education_level` is an ordinal variable. We might decide that the
smaller levels, `<High School` and `PhD` are too small to be useful, and
that we want to lump them together with other levels. We would do this
by specifying a threshold value, in this instance 15, which is the
minimum number of observations that we want in each level after lumping.

``` r

lumped_levels <- lump_ordinal(data$education_level, 15)
summary(lumped_levels)
#> <High School+High School               Bachelor's             Master's+PhD 
#>                       55                       28                       17
```

We see that the algorithm has lumped the level `<High School` with
`High School`, and the level `PhD` with `Master's`. Of course, the
interpretation of the levels has changed (the new levels should perhaps
be interpreted as “High school or less” and “Postgraduate”), but we see
that all levels meet the threshold of 15 observations now.

### Nominal Variables

For nominal variables, we lose the ordering and thus we can’t rely on
the computer to automatically know what levels can be lumped together.
The simplest, and most common approach is to simply allow all levels to
be lumped with all other levels. This is the default behaviour:

``` r

lumped_levels <- lump_nominal(data$diagnosis, 15)
summary(lumped_levels)
#>                   Diabetes Heart Disease+Hypertension 
#>                         22                         29 
#>                       None 
#>                         49
```

A less common situation is when we have some prior knowledge about which
levels can be lumped together. Suppose we know based on domain knowledge
that `Heart Disease` should not be lumped with `Hypertension`, since
they are too different. This information can also be encoded in the
preference graph,[^1] by disallowing the corresponding pairing. Notice
that the preference graph is taken in as its adjacency matrix.

``` r

preference_graph <- adjacency_from_edge_list(
  levels(data$diagnosis),
  disallow = list(c("Heart Disease", "Hypertension"))
)
lumped_levels <- lump_nominal(data$diagnosis, 15, preference_graph)
summary(lumped_levels)
#> Diabetes+Heart Disease           Hypertension                   None 
#>                     32                     19                     49
```

Of course, if the preference graph is more sparse, corresponding to a
situation in which only a small number of pairings are admissible, it
would make more sense to build the graph the other way around, by
starting with an empty graph and adding edges for the pairings that are
allowed.

#### Hierarchical Variables

An important subclass of nominal variables are hierarchical variables,
where we have some structure inherited a hierarchy. A common example –
and the one demonstrated here – is that of geographical variables. We
know, a priori, that countries belong to continents, naturally
clustering countries together, so it makes more sense to lump countries
together that exist within the same continent. It is simple to pass this
knowledge in:

``` r

clusters <- list(
    c("US", "Canada", "Mexico"),
    c("France", "Germany"),
    c("China", "Japan", "South Korea", "Vietnam")
)
lumped_levels <- lump_hierarchical(data$country_of_origin, 15, clusters)
summary(lumped_levels)
#>    US+Canada+Mexico               China      France+Germany               Japan 
#>                  30                  17                  17                  15 
#> South Korea+Vietnam 
#>                  21
```

The reason this function exists separately from
[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
– which can achieve the exact same behaviour by passing an appropriate
preference graph – is, in addition to the ergonomic gains, that it
allows certain speedups that are not possible in the general case.

## Dplyr Integration

``` r

library(dplyr)
```

The package works very naturally with dplyr pipelines. For instance, we
can easily apply the
[`lump_ordinal()`](https://daankoning.github.io/optLump/reference/lump_ordinal.md)
function to the `education_level` variable in our dataset:

``` r

data |>
  mutate(education_level = lump_ordinal(education_level, 15)) |>
  slice_head(n = 10)
#>    outcome          education_level    diagnosis country_of_origin
#> 1        1             Master's+PhD         None           Vietnam
#> 2        3 <High School+High School         None            France
#> 3        0 <High School+High School         None             Japan
#> 4        0 <High School+High School         None                US
#> 5        1 <High School+High School         None            Canada
#> 6        0               Bachelor's         None             Japan
#> 7        2             Master's+PhD         None            Canada
#> 8        0               Bachelor's Hypertension            Mexico
#> 9        1 <High School+High School     Diabetes                US
#> 10       1 <High School+High School         None           Germany
```

## Computation and Large Datasets

Due to inherent computational constraints,[^2]
[`lump_nominal()`](https://daankoning.github.io/optLump/reference/lump_nominal.md)
might be very slow. In fact, the algorithm has O\left(2^{2^m}\right)
runtime, where m is the number of levels. To partially remedy this,
[`lump_hierarchical()`](https://daankoning.github.io/optLump/reference/lump_hierarchical.md)
is substantially faster when it can be used, having
O\left(\frac{m}{c}2^{2^c}\right), where c is the number of levels in the
largest cluster. In our example, we would have c = 4, since we have 4
Asian countries. Since c \leq m, this is a substantial improvement.

When even this is too slow, we can use
[`lump_nominal_heuristic()`](https://daankoning.github.io/optLump/reference/lump_nominal_heuristic.md),
which approximates a solution in polynomial time, but does not guarantee
an optimal solution.

Note that
[`lump_ordinal()`](https://daankoning.github.io/optLump/reference/lump_ordinal.md)
does not suffer from the same issue and runs in polynomial time.

[^1]: The preference graph is a graph that encodes what lumpings are
    allowed; it has an edge between two levels if and only if those
    levels are allowed to be lumped together.

[^2]: being that the nominal problem is NP-hard
