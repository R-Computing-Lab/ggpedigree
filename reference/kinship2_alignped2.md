# Align pedigree - Process a set of siblings

This is an internal helper function for pedigree alignment. It processes
a set of siblings, ordering them according to hints and calling
kinship2_alignped1 for each sibling. The results are merged together
using kinship2_alignped3.

## Usage

``` r
kinship2_alignped2(x, dad, mom, level, horder, packed, spouselist)
```

## Arguments

- x:

  Integer vector of sibling IDs to process

- dad:

  Integer vector of father indices

- mom:

  Integer vector of mother indices

- level:

  Integer vector indicating the generation level of each subject

- horder:

  Numeric vector of hint order for positioning subjects

- packed:

  Logical, if TRUE uses compact packing algorithm

- spouselist:

  Matrix defining spouse relationships

## Value

A list containing the aligned pedigree structure for the sibling group:

- nid:

  Matrix of subject IDs at each level and position

- pos:

  Matrix of horizontal positions

- fam:

  Matrix of family indices

- n:

  Vector of counts per level

- spouselist:

  Updated spouse list
