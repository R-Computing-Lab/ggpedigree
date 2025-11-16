# Kluane Red Squirrel Data

A tidy data frame of life‐history and reproductive metrics for 7,799
individual red squirrels from the Kluane Red Squirrel Project
(1987–present). Each row corresponds to one squirrel with associated
pedigree links and reproductive success summaries. The original data are
published under a CC0 1.0 Universal Public Domain Dedication:

## Usage

``` r
data(redsquirrels)
```

## Format

\## \`redsquirrels\` A data frame with 7799 rows and 16 columns:

- personID:

  Unique identifier for each squirrel

- momID, dadID:

  Unique identifiers for each squirrel's parents

- sex:

  Biological sex of the squirrel

- famID:

  Unique identifier for each family. Derived from ped2fam

- byear:

  Birth year of the squirrel

- dyear:

  Death year of the squirrel

- lrs:

  lifetime reproductive success for the squirrel

- ars_mean:

  Mean annual reproductive success for the squirrel

- ars_max:

  Maximum ARS value for the squirrel

- ars_med:

  Median ARS value for the squirrel

- ars_min:

  Minimum ARS value for the squirrel

- ars_sd:

  Standard deviation of ARS values for the squirrel

- ars_n:

  Number of ARS values for the squirrel

- year_first:

  First year of ARS data for the squirrel

- year_last:

  Last year of ARS data for the squirrel

## Source

\<https://doi.org/10.5061/dryad.n5q05\>

## Details

McFarlane, S. Eryn; Boutin, Stan; Humphries, Murray M. et al. (2015).
Data from: Very low levels of direct additive genetic variance in
fitness and fitness components in a red squirrel population \[Dataset\].
Dryad. \<https://doi.org/10.5061/dryad.n5q05\>
