# Process duplicate appearances of individuals in a pedigree layout

Resolves layout conflicts when the same individual appears in multiple
places (e.g., due to inbreeding loops). Keeps the layout point that is
closest to a relevant relative (mom, dad, or spouse) and removes links
to others to avoid confusion in visualization.

## Usage

``` r
processExtras(ped, config = list())
```

## Arguments

- ped:

  A data.frame containing pedigree layout info with columns including:
  \`personID\`, \`x_pos\`, \`y_pos\`, \`dadID\`, \`momID\`, and a
  logical column \`extra\`.

- config:

  A list of configuration options. Currently unused but passed through
  to internal helpers.

## Value

A modified \`ped\` data.frame with updated coordinates and removed
duplicates.
