# Check kinship2 hints for consistency

This function checks the consistency of kinship2 hints, particularly
focusing on the \`order\` and \`spouse\` components. It ensures that the
order is numeric and matches the length of the \`sex\` vector, and that
marriages are valid male/female pairs without duplicates.

## Usage

``` r
kinship2_check.hint(hints, sex)
```

## Arguments

- hints:

  A list containing kinship2 hints, including \`order\` and optionally
  \`spouse\`.

- sex:

  A character vector indicating the sex of each individual ('male' or
  'female').

## Value

The original \`hints\` list if all checks pass; otherwise, an error is
raised.

## Details

Extracted from checks.Rnw This routine tries to remove inconsistencies
in spousal hints. These and arise in autohint with complex pedigrees.
One can have ABA (subject A is on both the left and the right of B),
cycles, etc. Actually, these used to arise in autohint, I don't know if
it's so after the recent rewrite. Users can introduce problems as well
if they modify the hints.
