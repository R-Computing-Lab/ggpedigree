# Core Function for ggRelatednessMatrix

This function is the core implementation of the ggRelatednessMatrix
function. It handles the data preparation, layout calculation, and
plotting of the pedigree diagram. It is not intended to be called
directly by users.

## Usage

``` r
ggRelatednessMatrix.core(mat, config = list(), ...)
```

## Arguments

- mat:

  A square numeric matrix of relatedness values (precomputed, e.g., from
  ped2add).

- config:

  A list of graphical and display parameters. See Details for available
  options.

- ...:

  Additional arguments passed to ggplot2 layers.
