# Renumber Pedigree IDs

Renumber pedigree identifiers to short sequential integer values while
preserving parent-child references.

The function constructs a crosswalk from the original person identifiers
to new integer identifiers beginning at 1. The same crosswalk is then
applied to the person, mother, and father identifier columns, ensuring
that references remain internally consistent. For example, if an
original \`personID\` is recoded to 1, then any matching value in the
mother or father identifier columns is also recoded to 1.

## Usage

``` r
.renumberPedigreeIDs(
  ped,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  twinID = "twinID",
  spouseID = "spouseID",
  sort_ids = TRUE,
  return_key = FALSE
)

renumberPedigreeIDs(
  ped,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  twinID = "twinID",
  spouseID = "spouseID",
  sort_ids = TRUE,
  return_key = FALSE
)
```

## Arguments

- ped:

  A data frame containing pedigree identifiers.

- personID:

  Character scalar. Name of the column containing unique person
  identifiers. Default is \`"personID"\`.

- momID:

  Character scalar. Name of the column containing maternal identifiers.
  Default is \`"momID"\`.

- dadID:

  Character scalar. Name of the column containing paternal identifiers.
  Default is \`"dadID"\`.

- sort_ids:

  Logical scalar. If \`TRUE\`, original identifiers are sorted before
  assigning new IDs. If \`FALSE\`, new IDs follow the order of first
  appearance in \`ped\[\[personID\]\]\`. Default is \`TRUE\`.

- return_key:

  Logical scalar. If \`TRUE\`, returns a list containing both the
  renumbered pedigree data frame and the ID crosswalk. If \`FALSE\`,
  returns only the renumbered pedigree data frame. Default is \`FALSE\`.

## Value

If \`return_key = FALSE\`, a data frame with renumbered person, mother,
and father identifiers.

If \`return_key = TRUE\`, a list with two elements:

- ped:

  The renumbered pedigree data frame.

- id_key:

  A data frame mapping original IDs to new IDs.

## Details

\* Only values appearing in the person identifier column are used to
construct the ID crosswalk. \* Parent identifiers that do not appear in
the person identifier column are recoded to \`NA\`, because they cannot
be matched to a known individual in the data. \* Existing \`NA\` values
in the mother and father identifier columns remain \`NA\`. \* The
returned ID columns are integer vectors.

## See also

Related pedigree-cleaning helpers such as \`recodeMissingIDs()\`.
