# optLump

The `optLump` package provides functions to optimally lump together
factor levels in a data frame. This is useful for reducing the number of
levels in a factor variable, which can improve the fit and
interpretability of a model.

## Installation

The package can be obtained from
<https://github.com/daankoning/optLump/releases/latest>. Alternatively,
install with

``` bash
# install.packages("pak")
pak::pkg_install("daankoning/optLump")
```

## Usage

Pass a categorical vector and a threshold (the minimum number of
observations each level should contain after lumping):

``` r

library(optLump)

education <- factor(
  c("<High School", "High School", "High School", "Bachelor's",
    "Bachelor's", "Master's", "PhD"),
  levels = c("<High School", "High School", "Bachelor's", "Master's", "PhD"),
  ordered = TRUE
)

# Lump so that every level holds at least 2 observations.
lump_ordinal(education, threshold = 2)
#> [1] <High School+High School <High School+High School <High School+High School
#> [4] Bachelor's               Bachelor's               Master's+PhD            
#> [7] Master's+PhD            
#> Levels: <High School+High School < Bachelor's < Master's+PhD
```

The smallest levels are merged into their most informative neighbours.
For more detailed instructions, see
[`vignette("optLump")`](https://daankoning.github.io/optLump/articles/optLump.md).
