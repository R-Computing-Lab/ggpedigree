# plotPedigree A wrapped function to plot simulated pedigree from function `simulatePedigree`. This function require the installation of package `kinship2`.

plotPedigree A wrapped function to plot simulated pedigree from function
`simulatePedigree`. This function require the installation of package
`kinship2`.

## Usage

``` r
kinship2_plotPedigree(
  ped,
  code_male = NULL,
  verbose = FALSE,
  affected = NULL,
  cex = 0.5,
  col = 1,
  symbolsize = 1,
  branch = 0.6,
  packed = TRUE,
  align = c(1.5, 2),
  width = 8,
  density = c(-1, 35, 65, 20),
  mar = c(2.1, 1, 2.1, 1),
  angle = c(90, 65, 40, 0),
  keep.par = FALSE,
  pconnect = 0.5,
  ...
)

plotPedigree(...)
```

## Arguments

- ped:

  The simulated pedigree data.frame from function `simulatePedigree`. Or
  a pedigree dataframe with the same colnames as the dataframe simulated
  from function `simulatePedigree`.

- code_male:

  This optional input allows you to indicate what value in the sex
  variable codes for male. Will be recoded as "M" (Male). If `NULL`, no
  recoding is performed.

- verbose:

  logical If TRUE, prints additional information. Default is FALSE.

- affected:

  This optional parameter can either be a string specifying the column
  name that indicates affected status or a numeric/logical vector of the
  same length as the number of rows in 'ped'. If `NULL`, no affected
  status is assigned.

- cex:

  The font size of the IDs for each individual in the plot.

- col:

  The color of the symbols in the plot.

- symbolsize:

  The size of the symbols in the plot.

- branch:

  The length of the branches in the plot.

- packed:

  logical. If TRUE, the pedigree is drawn in a more compact form.

- align:

  A numeric vector of length 2 indicating the alignment penalties for
  parents and spouses.

- width:

  The width of the plot.

- density:

  A numeric vector indicating the shading density for different affected
  statuses.

- mar:

  A numeric vector of length 4 indicating the margins of the plot.

- angle:

  A numeric vector indicating the shading angles for different affected
  statuses.

- keep.par:

  logical. If TRUE, the current graphical parameters are preserved.

- pconnect:

  A numeric value indicating the proportion of the pedigree to connect.

- ...:

  Additional arguments passed to
  [`kinship2::plot.pedigree`](https://rdrr.io/pkg/kinship2/man/plot.pedigree.html)

## Value

A plot of the provided pedigree

## Deprecated

\`plotPedigree()\` is deprecated; use \`kinship2_plotPedigree()\`
instead.
