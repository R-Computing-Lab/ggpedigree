# Wars of the Roses Pedigree Data

A pedigree dataset representing the familial relationships among key
figures in the historical War of the Roses, a series of English civil
wars for control of the throne of England fought between the houses of
Lancaster and York during the 15th century. This dataset includes
information on individuals' parentage, birth and death years, and
titles, allowing for the exploration of lineage, alliances, and
succession during this tumultuous period in English history.

## Usage

``` r
data(warsofroses)
```

## Format

A data frame with many observations on 6 variables.

## Source

\<https://en.wikipedia.org/wiki/Wars_of_the_Roses#Family_tree\>

## Details

The variables are as follows:

- `id`: Person identification variable

- `momID`: ID of the mother

- `dadID`: ID of the father

- `name`: Name of the person

- `sex`: Biological sex

- `url`: URL to a wiki page about the character
