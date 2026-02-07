# Restore user-specified column names in a connections data frame

Rename standard internal columns in a pedigree connections data frame
back to user-specified names.

## Usage

``` r
.restoreNames(
  connections,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  spouseID = "spouseID",
  twinID = "twinID",
  famID = "famID",
  sexVar = "sex"
)

restoreNames(
  connections,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  spouseID = "spouseID",
  twinID = "twinID",
  famID = "famID",
  sexVar = "sex"
)
```

## Arguments

- connections:

  A data frame containing connection identifiers whose columns may
  currently be named with internal defaults such as \`personID\`,
  \`momID\`, \`dadID\`, \`spouseID\`, \`twinID\`, \`famID\`, and
  \`sex\`.

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

  Character string specifying the column name for spouse IDs. Defaults
  to "spouseID".

- twinID:

  Character string specifying the column name for twin IDs. Defaults to
  "twinID".

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- sexVar:

  Character string specifying the column name for sex. Defaults to
  "sex".
