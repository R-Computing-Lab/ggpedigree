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

  A data frame containing the pedigree data. Needs personID, momID,
  dadID, and sex columns.

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

- \`x_mid_parent\`, \`y_mid_parent\`: midpoint between parents

- \`x_mid_sib\`, \`y_mid_sib\`: sibling group midpoint

- \`x_mid_spouse\`, \`y_mid_spouse\`: midpoint between spouses

## See also

calculateCoordinates, ggPedigree, vignette("v00_plots")

## Examples

``` r
ped <- data.frame(
  personID = c("A", "B", "C", "D", "X"),
  momID = c(NA, "A", "A", "C", NA),
  dadID = c(NA, "X", "X", "B", NA),
  spouseID = c("X", "C", "B", NA, "A"),
  sex = c("F", "M", "F", "F", "M")
)

coords <- calculateCoordinates(ped, code_male = "M")
conns <- calculateConnections(coords, config = list(code_male = "M"))
names(conns)
#> [1] "connections" "self_coords" "twin_coords"
head(conns$connections)
#>   personID        x_pos y_pos dadID momID x_fam y_fam parent_hash couple_hash
#> 1        A 1.000000e+00     1  <NA>  <NA>    NA    NA        <NA>         A.X
#> 2        B 2.237231e-20     2     X     A   0.5     1         A.X         B.C
#> 3        C 1.000000e+00     2     X     A   0.5     1         A.X         B.C
#> 4        D 5.000000e-01     3     B     C   0.5     2         B.C        <NA>
#> 5        X 0.000000e+00     1  <NA>  <NA>    NA    NA        <NA>         A.X
#>   spouseID famID extra link_as_spouse link_as_sibling link_as_twin x_mom y_mom
#> 1        X     1 FALSE           TRUE           FALSE        FALSE    NA    NA
#> 2        C     1 FALSE           TRUE            TRUE        FALSE     1     1
#> 3        B     1 FALSE           TRUE            TRUE        FALSE     1     1
#> 4     <NA>     1 FALSE           TRUE            TRUE        FALSE     1     2
#> 5        A     1 FALSE           TRUE           FALSE        FALSE    NA    NA
#>          x_dad y_dad     x_spouse y_spouse x_mid_spouse y_mid_spouse x_mid_sib
#> 1           NA    NA 0.000000e+00        1          0.5            1        NA
#> 2 0.000000e+00     1 1.000000e+00        2          0.5            2       0.5
#> 3 0.000000e+00     1 2.237231e-20        2          0.5            2       0.5
#> 4 2.237231e-20     2           NA       NA           NA           NA       0.5
#> 5           NA    NA 1.000000e+00        1          0.5            1        NA
#>   y_mid_sib
#> 1        NA
#> 2         2
#> 3         2
#> 4         3
#> 5        NA
```
