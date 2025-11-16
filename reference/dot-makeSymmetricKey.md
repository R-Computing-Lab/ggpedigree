# Generate a symmetric key for two IDs

This function generates a symmetric key for two IDs, ensuring that the
order of the IDs does not matter.

## Usage

``` r
.makeSymmetricKey(id1, id2, sep = ".")

makeSymmetricKey(id1, id2, sep = ".")
```

## Arguments

- id1:

  First ID

- id2:

  Second ID

- sep:

  Separator to use between the IDs

## Value

A string representing the symmetric key
