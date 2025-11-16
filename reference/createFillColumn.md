# Get fill column for ggPedigree

This function creates a fill column for ggPedigree plots as a function
of the focal person relative to everyone else in the tree.

## Usage

``` r
createFillColumn(
  ped,
  focal_fill_personID = 2,
  personID = "personID",
  component = "additive",
  config = list()
)
```

## Arguments

- ped:

  A data frame containing the pedigree data.

- focal_fill_personID:

  Numeric ID of the person to use as the focal point for fill.

- personID:

  Character string specifying the column name for individual IDs.

- component:

  Character string specifying the component type (e.g., "additive").

- config:

  A list of configuration options for customizing the fill column.

## Value

A data frame with two columns: \`fill\` and \`personID\`.
