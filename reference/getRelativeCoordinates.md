# Get coordinate positions of relatives for each individual

Helper function used to retrieve the x and y coordinates of a specified
relative (e.g., mom, dad, spouse) and join them into the main connection
table. This supports relative-specific positioning in downstream layout
functions like \`calculateConnections()\`.

## Usage

``` r
getRelativeCoordinates(
  ped,
  connections,
  relativeIDvar,
  x_name,
  y_name,
  personID = "personID",
  multiple = "all",
  only_unique = TRUE
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- connections:

  A \`data.frame\` containing the individuals and their associated
  relative IDs.

- relativeIDvar:

  Character. Name of the column in \`connections\` for the relative ID
  variable.

- x_name:

  Character. Name of the new column to store the x-coordinate of the
  relative.

- y_name:

  Character. Name of the new column to store the y-coordinate of the
  relative.

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- multiple:

  Character. Specifies how to handle multiple matches. Options are "all"
  or "any".

- only_unique:

  Logical. If TRUE, return only unique rows. Defaults to TRUE.

## Value

A \`data.frame\` with columns:

- \`personID\`, \`relativeIDvar\`

- \`x_name\`, \`y_name\`: Coordinates of the specified relative

- Optionally, \`newID\` if present in \`ped\`
