# Align pedigree with additional relations

This function aligns a pedigree object using relations if provided, or
defaults to the default alignment settings.

## Usage

``` r
alignPedigreeWithRelations(
  ped,
  personID,
  dadID,
  momID,
  code_male,
  sexVar,
  config
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- code_male:

  Value used to indicate male sex. Defaults to NULL.

- sexVar:

  Character. Name of the column in \`ped\` for the sex variable.

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

A data frame with the aligned positions of individuals in the pedigree.
