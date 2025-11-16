# Count siblings of each individual

Count siblings of each individual

## Usage

``` r
countSiblings(ped, personID = "ID", momID = "momID", dadID = "dadID")
```

## Arguments

- ped:

  A data frame containing the pedigree information

- personID:

  character. Name of the column in ped for the person ID variable

- momID:

  character. Name of the column in ped for the mother ID variable

- dadID:

  character. Name of the column in ped for the father ID variable

## Value

A data frame with an additional column, siblings, that contains the
number of siblings for each individual

## Examples

``` r
library(BGmisc)
data("potter")
countSiblings(potter, personID = "personID")
#>    personID famID               name first_name  surname gen momID dadID
#> 1         1     1     Vernon Dursley     Vernon  Dursley   1   101   102
#> 2         2     1   Marjorie Dursley   Marjorie  Dursley   1   101   102
#> 3         3     1      Petunia Evans    Petunia    Evans   1   103   104
#> 4         4     1         Lily Evans       Lily    Evans   1   103   104
#> 5         5     1       James Potter      James   Potter   1    NA    NA
#> 6         6     1     Dudley Dursley     Dudley  Dursley   2     3     1
#> 7         7     1       Harry Potter      Harry   Potter   2     4     5
#> 8         8     1      Ginny Weasley      Ginny  Weasley   2    10     9
#> 9         9     1     Arthur Weasley     Arthur  Weasley   1    NA    NA
#> 10       10     1      Molly Prewett      Molly  Prewett   1    NA    NA
#> 11       11     1        Ron Weasley        Ron  Weasley   2    10     9
#> 12       12     1       Fred Weasley       Fred  Weasley   2    10     9
#> 13       13     1     George Weasley     George  Weasley   2    10     9
#> 14       14     1      Percy Weasley      Percy  Weasley   2    10     9
#> 15       15     1    Charlie Weasley    Charlie  Weasley   2    10     9
#> 16       16     1       Bill Weasley       Bill  Weasley   2    10     9
#> 17       17     1   Hermione Granger   Hermione  Granger   2    NA    NA
#> 18       18     1     Fleur Delacour      Fleur Delacour   2   105   106
#> 19       19     1 Gabrielle Delacour  Gabrielle Delacour   2   105   106
#> 20       20     1             Audrey     Audrey  Unknown   2    NA    NA
#> 21       21     1    James Potter II      James   Potter   3     8     7
#> 22       22     1       Albus Potter      Albus   Potter   3     8     7
#> 23       23     1        Lily Potter       Lily   Potter   3     8     7
#> 24       24     1       Rose Weasley       Rose  Weasley   3    17    11
#> 25       25     1       Hugo Weasley       Hugo  Weasley   3    17    11
#> 26       26     1   Victoire Weasley   Victoire  Weasley   3    18    16
#> 27       27     1  Dominique Weasley  Dominique  Weasley   3    18    16
#> 28       28     1      Louis Weasley      Louis  Weasley   3    18    16
#> 29       29     1      Molly Weasley      Molly  Weasley   3    20    14
#> 30       30     1       Lucy Weasley       Lucy  Weasley   3    20    14
#> 31      101     1     Mother Dursley     Mother  Dursley   0    NA    NA
#> 32      102     1     Father Dursley     Father  Dursley   0    NA    NA
#> 34      103     1       Mother Evans     Mother    Evans   0    NA    NA
#> 33      104     1       Father Evans     Father    Evans   0    NA    NA
#> 36      105     1    Mother Delacour     Mother Delacour   0    NA    NA
#> 35      106     1    Father Delacour     Father Delacour   0    NA    NA
#>    spouseID sex twinID zygosity parentsID siborder siblings
#> 1         3   1     NA     <NA>   101.102        1        1
#> 2        NA   0     NA     <NA>   101.102        2        1
#> 3         1   0     NA     <NA>   103.104        1        1
#> 4         5   0     NA     <NA>   103.104        2        1
#> 5         4   1     NA     <NA>      <NA>        1        0
#> 6        NA   1     NA     <NA>       3.1        1        0
#> 7         8   1     NA     <NA>       4.5        1        0
#> 8         7   0     NA     <NA>      10.9        1        6
#> 9        10   1     NA     <NA>      <NA>        1        0
#> 10        9   0     NA     <NA>      <NA>        1        0
#> 11       17   1     NA     <NA>      10.9        2        6
#> 12       NA   1     13       mz      10.9        3        6
#> 13       NA   1     12       mz      10.9        4        6
#> 14       20   1     NA     <NA>      10.9        5        6
#> 15       NA   1     NA     <NA>      10.9        6        6
#> 16       18   1     NA     <NA>      10.9        7        6
#> 17       11   0     NA     <NA>      <NA>        1        0
#> 18       16   0     NA     <NA>   105.106        1        1
#> 19       NA   0     NA     <NA>   105.106        2        1
#> 20       14   0     NA     <NA>      <NA>        1        0
#> 21       NA   1     NA     <NA>       8.7        1        2
#> 22       NA   1     NA     <NA>       8.7        2        2
#> 23       NA   0     NA     <NA>       8.7        3        2
#> 24       NA   0     NA     <NA>     17.11        1        1
#> 25       NA   1     NA     <NA>     17.11        2        1
#> 26       NA   0     NA     <NA>     18.16        1        2
#> 27       NA   0     NA     <NA>     18.16        2        2
#> 28       NA   1     NA     <NA>     18.16        3        2
#> 29       NA   0     NA     <NA>     20.14        1        1
#> 30       NA   0     NA     <NA>     20.14        2        1
#> 31      102   0     NA     <NA>      <NA>        1        0
#> 32      101   1     NA     <NA>      <NA>        1        0
#> 34      104   0     NA     <NA>      <NA>        1        0
#> 33      103   1     NA     <NA>      <NA>        1        0
#> 36      106   0     NA     <NA>      <NA>        1        0
#> 35      105   1     NA     <NA>      <NA>        1        0
```
