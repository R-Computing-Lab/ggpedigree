# Calculate connections for a pedigree dataset

Computes graphical connection paths for a pedigree layout, including
parent-child, sibling, and spousal connections. Optionally processes
duplicate appearances of individuals (marked as \`extra\`) to ensure
relational accuracy.

## Usage

``` r
calculateConnections(
  ped,
  config = list(),
  spouseID = "spouseID",
  personID = "personID",
  momID = "momID",
  famID = "famID",
  twinID = "twinID",
  dadID = "dadID"
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- config:

  List of configuration parameters. Currently unused but passed through
  to internal helpers.

- spouseID:

  Character string specifying the column name for spouse IDs. Defaults
  to "spouseID".

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- twinID:

  Character string specifying the column name for twin IDs. Defaults to
  "twinID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

## Value

A \`data.frame\` containing connection points and midpoints for
graphical rendering. Includes:

- \`x_pos\`, \`y_pos\`: positions of focal individual

- \`x_dad\`, \`y_dad\`, \`x_mom\`, \`y_mom\`: parental positions (if
  available)

- \`x_spouse\`, \`y_spouse\`: spousal positions (if available)

- \`x_midparent\`, \`y_midparent\`: midpoint between parents

- \`x_mid_sib\`, \`y_mid_sib\`: sibling group midpoint

- \`x_mid_spouse\`, \`y_mid_spouse\`: midpoint between spouses
