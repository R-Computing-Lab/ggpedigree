# Compute optimal horizontal spacing for pedigree alignment

This is an internal helper function for pedigree alignment. It uses
quadratic programming to find optimal horizontal positions for subjects
that minimize the distance between parents and children while keeping
spouses together and respecting spacing constraints. Requires the
quadprog package.

## Usage

``` r
kinship2_alignped4(rval, spouse, level, width, align)
```

## Arguments

- rval:

  Aligned pedigree structure from previous alignment steps

- spouse:

  Logical matrix indicating spouse connections

- level:

  Integer vector of generation levels

- width:

  Numeric, maximum width of the pedigree plot

- align:

  Logical or numeric vector. If logical, uses default alignment
  parameters. If numeric, should be a vector c(a1, a2) where a1 controls
  parent-child penalties and a2 controls spouse penalties

## Value

Matrix of optimized horizontal positions for each subject
