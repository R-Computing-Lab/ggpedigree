# Calculate the bit size of a pedigree

This function calculates the bit size of a pedigree, which is a measure
of the information content. The bit size is calculated as 2 \* (number
of non-founders) - (number of founders). This is used in pedigree.shrink
functions.

## Usage

``` r
kinship2_bitSize(ped)
```

## Arguments

- ped:

  A pedigree object

## Value

A list containing:

- bitSize:

  The bit size of the pedigree

- nFounder:

  The number of founders in the pedigree

- nNonFounder:

  The number of non-founders in the pedigree

## Examples

``` r
if (FALSE) { # \dontrun{
# Example requires a pedigree object
# ped <- pedigree(id=1:5, dadid=c(0,0,1,1,1), momid=c(0,0,2,2,2),
#                 sex=c(1,2,1,2,1))
# kinship2_bitSize(ped)
} # }
```
