# Optimize Static Pedigree Plot

Optimize a static pedigree plot by rounding coordinates to reduce file
size and removing unnecessary variables from the data frame.

## Usage

``` r
optimizeStaticPedigree(
  p,
  config = list(),
  variable_drop = c("parent_hash", "couple_hash", "gen", "spousehint", "parent_fam",
    "nid", "x_order", "y_order", "y_fam", "zygosity", "extra", "x_fam")
)
```

## Arguments

- p:

  A ggplot object representing the pedigree plot.

- config:

  A list of configuration parameters, including
  \`value_rounding_digits\`.

- variable_drop:

  A character vector of variable names to be removed from the data
  frame. Default variables to drop include "parent_hash", "couple_hash",
  "gen", "spousehint", "parent_fam", "nid", "x_order", "y_order",
  "y_fam", "zygosity", "extra", and "x_fam".

## Value

The optimized ggplot object with rounded coordinates and reduced data
frame.
