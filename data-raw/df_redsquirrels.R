# These data are from the Kluane Red Squirrel Project, which has been running since 1987. The data are available on Dryad at https://doi.org/10.5061/dryad.2z34tmpr3. The pedigree data are in the file `Pedigree_dryadcopy.xlsx` and the phenotype data are in the file `LRS_fordryad.xlsx`.

library(tidyverse)
library(here)
library(readr)
library(usethis)
library(haven)
library(readxl)
library(BGmisc)

## Create dataframe

Ped <- read_excel("data-raw/Pedigree_dryadcopy.xlsx",
  col_types = c(
    "numeric", "numeric", "numeric",
    "text"
  )
) %>% rename(
  momID = dam,
  personID = id,
  dadID = sire, sex = Sex
)

ds <- ped2fam(Ped, famID = "famID", personID = "personID")

redsquirrels <- ds

write_csv(redsquirrels, here("data-raw", "redsquirrels.csv"))
usethis::use_data(redsquirrels, overwrite = TRUE, compress = "xz")
