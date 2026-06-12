# Split pedigree rows into connected-component index lists

Delegates to \[BGmisc::ped2fam()\], which uses \`igraph::components()\`
on the parent-child graph. Returns row indices per component in original
\`ped\` order.

## Usage

``` r
splitPedigreeComponents(ped, personID, momID, dadID)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID,
  dadID, and sex columns.

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

## Value

Unnamed list of integer row-index vectors, one per component.
