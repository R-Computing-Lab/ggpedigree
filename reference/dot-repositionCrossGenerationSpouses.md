# Reposition founders placed in the wrong generation

kinship2 assigns a founder's generation row based on its placed
descendants. When a founder's only shared child with their spouse is
unplaced (nid = NA), kinship2 has no generation constraint for that
founder and may place them in a different row from their spouse. The
result is a long diagonal spouse segment instead of the expected short
horizontal one.

This function detects that pattern and repositions affected founders
adjacent to their spouse at the spouse's generation. Only founders with
zero placed children are eligible — moving a founder whose descendants
are already laid out would misalign the parent-stub segments for those
children.

## Usage

``` r
.repositionCrossGenerationSpouses(ds, ped, personID, momID, dadID)
```

## Arguments

- ds:

  A data frame of layout coordinates (output of
  \`extractCoordinatesFromAlignedPedigree\`).

- personID:

  Name of the individual ID column.

- momID:

  Name of the mother ID column.

- dadID:

  Name of the father ID column.

## Value

The input data frame with eligible founders repositioned.
