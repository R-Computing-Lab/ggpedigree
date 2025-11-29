# Create a pedigree or pedigreeList object

Create a pedigree or pedigreeList object

## Usage

``` r
pedigree(
  id,
  dadid,
  momid,
  sex,
  affected,
  status,
  relation,
  famid,
  missid,
  max_message_n = 5
)

# S3 method for class 'pedigreeList'
x[..., drop = FALSE]

# S3 method for class 'pedigree'
x[..., drop = FALSE]

# S3 method for class 'pedigree'
print(x, ...)

# S3 method for class 'pedigreeList'
print(x, ...)
```

## Arguments

- id:

  Identification variable for individual

- dadid:

  Identification variable for father. Founders' parents should be coded
  to NA, or another value specified by missid.

- momid:

  Identification variable for mother. Founders' parents should be coded
  to NA, or another value specified by missid.

- sex:

  Gender of individual noted in \`id'. Either character
  ("male","female", "unknown","terminated") or numeric (1="male",
  2="female", 3="unknown", 4="terminated") data is allowed. For
  character data the string may be truncated, and of arbitrary case.

- affected:

  A variable indicating affection status. A multi-column matrix can be
  used to give the status with respect to multiple traits. Logical,
  factor, and integer types are converted to 0/1 representing unaffected
  and affected, respectively. NAs are considered missing.

- status:

  Censor/Vital status (0="censored", 1="dead")

- relation:

  A matrix with 3 required columns (id1, id2, code) specifying special
  relationship between pairs of individuals. Codes: 1=Monozygotic twin,
  2=Dizygotic twin, 3=Twin of unknown zygosity, 4=Spouse. (The last is
  necessary in order to place a marriage with no children into the
  plot.) If famid is given in the call to create pedigrees, then famid
  needs to be in the last column of the relation matrix. Note for tuples
  of \>= 3 with a mixture of zygosities, the plotting is limited to
  showing pairwise zygosity of adjacent subjects, so it is only
  necessary to specify the pairwise zygosity, in the order the subjects
  are given or appear on the plot.

- famid:

  An optional vector of family identifiers. If it is present the result
  will contain individual pedigrees for each family in the set, which
  can be extacted using subscripts. Individuals need to have a unique id
  *within* family.

- missid:

  The founders are those with no father or mother in the pedigree. The
  dadid and momid values for these subjects will either be NA or the
  value of this variable. The default for missid is 0 if the id variable
  is numeric, and "" (empty string) otherwise.

- max_message_n:

  max number of individuals to list in error messages

- x:

  pedigree object in print and subset methods

- ...:

  optional arguments passed to internal functions

- drop:

  logical, used in subset function for dropping dimensionality

## Value

An object of class `pedigree` or `pedigreeList` Containing the following
items: famid id findex mindex sex affected status relation

## Author

Terry Therneau
