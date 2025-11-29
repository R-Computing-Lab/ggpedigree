# Align a pedigree for plotting

This is the main function for aligning a pedigree structure for
plotting. It arranges subjects by generation, positions them
horizontally to minimize line crossings, handles spouse relationships,
and produces the coordinate system needed for drawing the pedigree.

## Usage

``` r
kinship2_align.pedigree(
  ped,
  packed = TRUE,
  width = 10,
  align = TRUE,
  hints = ped$hints
)
```

## Arguments

- ped:

  A pedigree object or pedigreeList object

- packed:

  Logical, if TRUE uses compact packing algorithm (default TRUE)

- width:

  Numeric, maximum width of the pedigree plot (default 10)

- align:

  Logical or numeric. If TRUE, attempts to align spouses on same level.
  If numeric, a vector c(a1, a2) controlling alignment penalties
  (default TRUE)

- hints:

  Optional list with \`order\` and \`spouse\` components to guide
  alignment. If NULL, kinship2_autohint is called to generate hints

## Value

For a single pedigree, a list containing:

- n:

  Vector of counts per generation level

- nid:

  Matrix of subject IDs at each position

- pos:

  Matrix of horizontal positions

- fam:

  Matrix of family indices indicating parent connections

- spouse:

  Matrix indicating spouse connections

- twins:

  Optional matrix indicating twin relationships

For a pedigreeList, returns the input with alignment information added.

## Details

This function handles the complete pedigree alignment process:

- Determines generation levels using kinship2_kindepth

- Generates or validates alignment hints using kinship2_autohint or
  kinship2_check.hint

- Builds spouse relationships list

- Processes founders and their descendants using kinship2_alignped1,
  kinship2_alignped2, kinship2_alignped3

- Optimizes horizontal spacing using kinship2_alignped4

- Identifies inbreeding loops and twin relationships
