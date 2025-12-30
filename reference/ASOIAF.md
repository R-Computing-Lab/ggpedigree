# A pedigree of ice and fire

A structured dataset of fictional characters derived from the Song of
Ice and Fire universe by George R. R. Martin. The character
relationships were partially based on a GEDCOM file publicly posted in
the \[Westeros.org
forum\](https://asoiaf.westeros.org/index.php?/topic/88863-all-the-family-trees/),
and were updated based on publicly available summaries from \[A Wiki of
Ice and Fire\](https://awoiaf.westeros.org/index.php/Main_Page). This
dataset was created for educational and illustrative purposes, such as
demonstrating pedigree construction, relationship tracing, and
algorithmic logic in family-based data. It includes no narrative content
or protected expression from the original works. No rights to the
characters, names, or intellectual property of George R. R. Martin or
HBO are claimed, and the dataset is not intended to represent any real
individuals or families.

## Usage

``` r
data(ASOIAF)
```

## Format

A data frame with 679 observations on 9 variables.

## Details

The variables are as follows:

- `id`: Person identification variable

- `famID`: Family identification variable

- `momID`: ID of the mother

- `dadID`: ID of the father

- `name`: Name of the person

- `sex`: Biological sex (M/F)

- `url`: URL to a wiki page about the character

- `twinID`: ID of the twin, if applicable

- `zygosity`: Zygosity of the twin, if applicable. mz is monozygotic; dz
  is dizygotic

## Examples

``` r
# Load the ASOIAF dataset
data(ASOIAF)

# View the structure of the dataset
str(ASOIAF)
#> 'data.frame':    679 obs. of  9 variables:
#>  $ id      : num  1 2 3 4 5 6 7 8 9 10 ...
#>  $ famID   : num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ momID   : num  566 NA 2 2 2 NA 6 NA NA NA ...
#>  $ dadID   : num  564 NA 1 1 1 NA 3 7 7 7 ...
#>  $ name    : chr  "Walder Frey" "Perra Royce" "Stevron Frey" "Emmon Frey" ...
#>  $ sex     : chr  "M" "F" "M" "M" ...
#>  $ url     : chr  "https://awoiaf.westeros.org/index.php/Walder_Frey" "https://awoiaf.westeros.org/index.php/Perra_Royce" "https://awoiaf.westeros.org/index.php/Stevron_Frey" "https://awoiaf.westeros.org/index.php/Emmon_Frey" ...
#>  $ twinID  : num  NA NA NA NA NA NA NA NA NA NA ...
#>  $ zygosity: chr  NA NA NA NA ...

# Plot a pedigree for a specific family
if (requireNamespace("ggplot2", quietly = TRUE)) {
  # Create a pedigree plot for House Stark
  ggPedigree(ASOIAF,
    famID = "famID",
    personID = "id",
    momID = "momID",
    dadID = "dadID",
    config = list(
      add_phantoms = TRUE,
      code_male = "M"
    )
  )
}
#> REPAIR IN EARLY ALPHA
```
