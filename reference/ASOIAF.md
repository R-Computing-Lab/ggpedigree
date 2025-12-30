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

- `momID`: ID of the mother

- `dadID`: ID of the father

- `name`: Name of the person

- `sex`: Biological sex

- `twinID`: ID of the twin, if applicable

- `zygosity`: Zygosity of the twin, if applicable. mz is monozygotic; dz
  is dizygotic

- `url`: URL to a wiki page about the character
