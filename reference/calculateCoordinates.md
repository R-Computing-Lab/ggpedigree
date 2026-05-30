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

  :   Logical, default TRUE. Passed to \`kinship2_align.pedigree\`.

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

## Examples

``` r
# Load example data
data(potter, package = "BGmisc")

# Calculate coordinates for the pedigree
coords <- calculateCoordinates(
  ped = potter,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  code_male = 1
)

# View the coordinates
head(coords)
#>   personID famID             name first_name surname gen momID dadID spouseID
#> 1        1     1   Vernon Dursley     Vernon Dursley   1   101   102        3
#> 2        2     1 Marjorie Dursley   Marjorie Dursley   1   101   102       NA
#> 3        3     1    Petunia Evans    Petunia   Evans   1   103   104        1
#> 4        4     1       Lily Evans       Lily   Evans   1   103   104        5
#> 5        5     1     James Potter      James  Potter   1    NA    NA        4
#> 6        6     1   Dudley Dursley     Dudley Dursley   2     3     1       NA
#>   sex twinID zygosity nid        x_pos x_order y_order y_pos parent_fam
#> 1   1     NA     <NA>   1 1.000000e+00       2       2     2          1
#> 2   0     NA     <NA>   2 5.551115e-17       1       2     2          1
#> 3   0     NA     <NA>   3 2.000000e+00       3       2     2          3
#> 4   0     NA     <NA>   4 4.000000e+00       5       2     2          3
#> 5   1     NA     <NA>   5 3.000000e+00       4       2     2          0
#> 6   1     NA     <NA>   6 1.500000e+00       1       3     3          2
#>   spousehint y_fam extra x_fam
#> 1          1     1 FALSE   0.5
#> 2          0     1 FALSE   0.5
#> 3          0     1 FALSE   3.0
#> 4          0     1 FALSE   3.0
#> 5          1    NA FALSE    NA
#> 6          0     2 FALSE   1.5

# Example with custom configuration
coords_custom <- calculateCoordinates(
  ped = potter,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  code_male = 1,
  config = list(
    ped_packed = FALSE,
    ped_width = 20
  )
)
# Load example data
data(potter, package = "BGmisc")

# Calculate coordinates for the pedigree
coords <- calculateCoordinates(
  ped = potter,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  config = list(
    code_male = 1
  )
)

# View the coordinates
head(coords)
#>   personID famID             name first_name surname gen momID dadID spouseID
#> 1        1     1   Vernon Dursley     Vernon Dursley   1   101   102        3
#> 2        2     1 Marjorie Dursley   Marjorie Dursley   1   101   102       NA
#> 3        3     1    Petunia Evans    Petunia   Evans   1   103   104        1
#> 4        4     1       Lily Evans       Lily   Evans   1   103   104        5
#> 5        5     1     James Potter      James  Potter   1    NA    NA        4
#> 6        6     1   Dudley Dursley     Dudley Dursley   2     3     1       NA
#>   sex twinID zygosity nid        x_pos x_order y_order y_pos parent_fam
#> 1   1     NA     <NA>   1 1.000000e+00       2       2     2          1
#> 2   0     NA     <NA>   2 5.551115e-17       1       2     2          1
#> 3   0     NA     <NA>   3 2.000000e+00       3       2     2          3
#> 4   0     NA     <NA>   4 4.000000e+00       5       2     2          3
#> 5   1     NA     <NA>   5 3.000000e+00       4       2     2          0
#> 6   1     NA     <NA>   6 1.500000e+00       1       3     3          2
#>   spousehint y_fam extra x_fam
#> 1          1     1 FALSE   0.5
#> 2          0     1 FALSE   0.5
#> 3          0     1 FALSE   3.0
#> 4          0     1 FALSE   3.0
#> 5          1    NA FALSE    NA
#> 6          0     2 FALSE   1.5

# Example with custom configuration
coords_custom <- calculateCoordinates(
  ped = potter,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  config = list(
    ped_packed = FALSE,
    ped_width = 20
  )
)
```
