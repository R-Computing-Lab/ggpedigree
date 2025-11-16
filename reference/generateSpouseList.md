# Generate a spouselist matrix

Generate a spouselist matrix

## Usage

``` r
generateSpouseList(
  ped,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  spouseID = "spouseID"
)
```

## Arguments

- ped:

  A data frame containing the pedigree information

- personID:

  Character. Name of the column in ped for the person ID variable

- momID:

  Character. Name of the column in ped for the mother ID variable

- dadID:

  Character. Name of the column in ped for the father ID variable

- spouseID:

  Character. Name of the column in ped for the spouse ID variable

## Value

A spouselist matrix

## Examples

``` r
library(BGmisc)
data("potter")
generateSpouseList(potter,
  personID = "personID",
  momID = "momID", dadID = "dadID", spouseID = "spouseID"
)
#>       ID1 ID2 sex1 sex2
#>  [1,] 101 102    0    1
#>  [2,] 103 104    0    1
#>  [3,]   3   1    0    1
#>  [4,]   4   5    0    1
#>  [5,]  10   9    0    1
#>  [6,] 105 106    0    1
#>  [7,]   8   7    0    1
#>  [8,]  17  11    0    1
#>  [9,]  18  16    0    1
#> [10,]  20  14    0    1
```
