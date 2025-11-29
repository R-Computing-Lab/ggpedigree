# Align pedigree - Process a single subject and their spouses

This is an internal helper function for pedigree alignment. It processes
a single subject (founder or not) along with their spouse(s), building
up the alignment structure. This function is called recursively by
kinship2_align.pedigree to construct the entire pedigree layout.

## Usage

``` r
kinship2_alignped1(x, dad, mom, level, horder, packed, spouselist)
```

## Arguments

- x:

  Integer vector of subject ID(s) to process

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

A list containing:

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
