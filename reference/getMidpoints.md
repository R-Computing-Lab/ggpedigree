# Compute midpoints across grouped coordinates

A flexible utility function to compute x and y midpoints for groups of
individuals using a specified method. Used to support positioning logic
for sibling groups, parental dyads, or spousal pairs in pedigree
layouts.

## Usage

``` r
getMidpoints(
  data,
  group_vars,
  x_vars,
  y_vars,
  x_out,
  y_out,
  method = "mean",
  require_non_missing = group_vars
)
```

## Arguments

- data:

  A \`data.frame\` containing the coordinate and grouping variables.

- group_vars:

  Character vector. Names of the grouping variables.

- x_vars:

  Character vector. Names of the x-coordinate variables to be averaged.

- y_vars:

  Character vector. Names of the y-coordinate variables to be averaged.

- x_out:

  Character. Name of the output column for the x-coordinate midpoint.

- y_out:

  Character. Name of the output column for the y-coordinate midpoint.

- method:

  Character. Method for calculating midpoints. Options include:

  - \`"mean"\`: Arithmetic mean of the coordinates.

  - \`"median"\`: Median of the coordinates.

  - \`"weighted_mean"\`: Weighted mean of the coordinates.

  - \`"first_pair"\`: Mean of the first pair of coordinates.

  - \`"meanxfirst"\`: Mean of the x-coordinates and first y-coordinate.

  - \`"meanyfirst"\`: Mean of the y-coordinates and first x-coordinate.

- require_non_missing:

  Character vector. Names of variables that must not be missing for the
  row to be included.

## Value

A \`data.frame\` grouped by \`group_vars\` with new columns \`x_out\`
and \`y_out\` containing midpoint coordinates.
