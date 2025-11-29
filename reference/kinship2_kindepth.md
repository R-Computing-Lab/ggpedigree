# Calculate the depth (generation level) of subjects in a pedigree

This function computes the depth of each subject in a pedigree, defined
as the maximal number of generations of ancestors (distance to the
farthest founder). Optionally aligns spouses to plot on the same
generation level.

## Usage

``` r
kinship2_kindepth(id, dad.id, mom.id, align = FALSE)
```

## Arguments

- id:

  Either a pedigree/pedigreeList object, or a vector of subject IDs

- dad.id:

  Vector of father IDs (required if \`id\` is not a pedigree object)

- mom.id:

  Vector of mother IDs (required if \`id\` is not a pedigree object)

- align:

  Logical, if TRUE attempts to align married couples at the same depth
  level for better visualization (default FALSE)

## Value

Integer vector of depth values for each subject, where 0 = founder, 1 =
child of founder, etc.

## Details

When \`align=TRUE\`, the function adjusts depths so that married couples
appear on the same generation level when possible. This produces more
aesthetically pleasing pedigree plots. The alignment algorithm handles
marry-ins, multiple marriages, and inbreeding loops.
