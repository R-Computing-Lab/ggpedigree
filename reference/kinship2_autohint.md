# Automatically generate alignment hints for pedigree plotting

This function automatically generates alignment hints for pedigree
plotting. Hints control the relative horizontal positioning of subjects
within their generation and the placement of spouse pairs. The function
handles twins, multiple marriages, and complex pedigree structures. It
is a somewhat optimized version of kinship2's autohint.

## Usage

``` r
kinship2_autohint(ped, hints, packed = TRUE, align = FALSE)
```

## Arguments

- ped:

  A pedigree object

- hints:

  Optional existing hints (list with \`order\` and optionally \`spouse\`
  components)

- packed:

  Logical, if TRUE uses compact packing algorithm (default TRUE)

- align:

  Logical, if TRUE attempts to align spouses on the same level (default
  FALSE)

## Value

A list containing:

- order:

  Numeric vector of relative ordering hints for subjects

- spouse:

  Matrix of spouse pair information

## Details

The function is called automatically by kinship2_align.pedigree if no
hints are provided. It analyzes the pedigree structure, identifies
twins, handles multiple marriages, and determines optimal subject
ordering to minimize crossing lines and produce aesthetically pleasing
plots.

Full documentation is available in the align_code_details vignette.
