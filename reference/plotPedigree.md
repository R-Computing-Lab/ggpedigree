# plotPedigree A wrapped function to plot simulated pedigree from function `simulatePedigree`. This function require the installation of package `kinship2`.

plotPedigree A wrapped function to plot simulated pedigree from function
`simulatePedigree`. This function require the installation of package
`kinship2`.

## Usage

``` r
plotPedigree(
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

  color for each id. Default assigns the same color to everyone.

- symbolsize:

  controls symbolsize. Default=1.

- branch:

  defines how much angle is used to connect various levels of nuclear
  families.

- packed:

  default=T. If T, uniform distance between all individuals at a given
  level.

- align:

  these parameters control the extra effort spent trying to align
  children underneath parents, but without making the pedigree too wide.
  Set to F to speed up plotting.

- width:

  default=8. For a packed pedigree, the minimum width allowed in the
  realignment of pedigrees.

- density:

  defines density used in the symbols. Takes up to 4 different values.

- mar:

  margin parmeters, as in the `par` function

- angle:

  defines angle used in the symbols. Takes up to 4 different values.

- keep.par:

  Default = F, allows user to keep the parameter settings the same as
  they were for plotting (useful for adding extras to the plot)

- pconnect:

  when connecting parent to children the program will try to make the
  connecting line as close to vertical as possible, subject to it lying
  inside the endpoints of the line that connects the children by at
  least `pconnect` people. Setting this option to a large number will
  force the line to connect at the midpoint of the children.

- ...:

  Extra options that feed into the plot function.

## Value

A plot of the provided pedigree
