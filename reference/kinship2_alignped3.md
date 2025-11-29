# Merge two aligned pedigree structures

This is an internal helper function for pedigree alignment. It takes two
previously aligned pedigree structures (x1 and x2) and merges them
side-by-side, handling overlapping subjects and adjusting positions
appropriately.

## Usage

``` r
kinship2_alignped3(x1, x2, packed, space = 1)
```

## Arguments

- x1:

  First aligned pedigree structure (list)

- x2:

  Second aligned pedigree structure (list)

- packed:

  Logical, if TRUE uses compact packing; if FALSE adds spacing

- space:

  Numeric, horizontal spacing between structures when packed=FALSE
  (default 1)

## Value

A list containing the merged pedigree structure:

- n:

  Vector of counts per level

- nid:

  Matrix of subject IDs at each level and position

- pos:

  Matrix of horizontal positions

- fam:

  Matrix of family indices
