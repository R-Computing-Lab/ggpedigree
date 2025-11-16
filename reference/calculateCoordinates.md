# Calculate coordinates for plotting individuals in a pedigree

Extracts and modifies the x and y positions for each individual in a
pedigree data frame using the align.pedigree function from the
\`kinship2\` package. It returns a data.frame with positions for
plotting.

## Usage

``` r
calculateCoordinates(
  ped,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  spouseID = "spouseID",
  sexVar = "sex",
  twinID = "twinID",
  code_male = NULL,
  config = list()
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

- spouseID:

  Character. Name of the column in \`ped\` for the spouse ID variable.

- sexVar:

  Character. Name of the column in \`ped\` for the sex variable.

- twinID:

  Character string specifying the column name for twin IDs. Defaults to
  "twinID".

- code_male:

  Value used to indicate male sex. Defaults to NULL.

- config:

  List of configuration options:

  code_male

  :   Default is 1. Used by BGmisc::recodeSex().

  ped_packed

  :   Logical, default TRUE. Passed to \`kinship2::align.pedigree\`.

  ped_align

  :   Logical, default TRUE. Align generations.

  ped_width

  :   Numeric, default 15. Controls spacing.

## Value

A data frame with one or more rows per person, each containing:

- \`x_order\`, \`y_order\`: Grid indices representing layout rows and
  columns.

- \`x_pos\`, \`y_pos\`: Continuous coordinate positions used for
  plotting.

- \`nid\`: Internal numeric identifier for layout mapping.

- \`extra\`: Logical flag indicating whether this row is a secondary
  appearance.
