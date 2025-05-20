# These data are from the Kluane Red Squirrel Project, which has been running since 1987.
# The data are available on Dryad at https://datadryad.org/dataset/doi:10.5061/dryad.n5q05. The pedigree data are in the file `Pedigree_dryadcopy.xlsx` and the phenotype data are in the file `LRS_fordryad.xlsx`.

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
)
Ped <- Ped %>% rename(
  momID = dam,
  personID = id,
  dadID = sire,
  sex = Sex
)

LRS <- read_excel("data-raw/LRS_fordryad.xlsx", col_types = c(
  "numeric", "numeric", "numeric",
  "text", "numeric", "numeric", "text",
  "numeric"
)) %>%
  suppressWarnings() %>%
  rename(
    momID = dam,
    personID = animal,
    dadID = sire,
    sex = Sex,
    byear = BYEAR,
    dyear = DYEAR,
    cod = Death.Type,
    lrs = LRS
  ) %>%
  select(-c("cod", "byear", "dyear"))


ARS <- read_excel("data-raw/ARS_dryadcopy.xlsx",
  col_types = c(
    "numeric", "numeric", "numeric",
    "text", "numeric", "numeric", "text",
    "numeric", "numeric"
  )
) %>%
  suppressWarnings() %>%
  rename(
    momID = dam,
    personID = animal,
    dadID = sire,
    sex = Sex,
    year = Year,
    byear = BYEAR,
    dyear = DYEAR,
    cod = Death.Type,
    ars = ARS
  ) %>%
  mutate(
    byear = ifelse(byear == 0, NA_real_, byear),
    dyear = ifelse(dyear == 0, NA_real_, dyear),
    year = ifelse(year == 0, NA_real_, year)
  ) %>%
  select(-c("cod"))

Ped <- Ped %>%
  left_join(
    ARS,
    by = c("personID", "momID", "dadID", "sex")
  ) %>%
  left_join(LRS,
    by = c("personID", "momID", "dadID", "sex")
  )

ds <- ped2fam(Ped, famID = "famID", personID = "personID")

ds$personID %>%
  unique() %>%
  length() # 7799

ds_grouped <- ds %>%
  group_by(personID, momID, dadID, sex, famID, byear, dyear, lrs) %>%
  summarise(
    ars_mean = round(mean(ars, na.rm = TRUE),digits=3),
    ars_max = round(max(ars, na.rm = TRUE),digits=3),
    ars_med = round(median(ars, na.rm = TRUE),digits=3),
    ars_min = round(min(ars, na.rm = TRUE),digits=3),
    ars_sd = round(sd(ars, na.rm = TRUE),digits=3),
    ars_n = n(),
    year_first = min(year, na.rm = TRUE),
    year_last = max(year, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  suppressWarnings() %>%
  mutate(
    ars_max = case_when(
      ars_max == Inf ~ NA_real_,
      ars_max == -Inf ~ NA_real_,
      is.na(ars_max) ~ NA_real_,
      TRUE ~ ars_max
    ),
    ars_min = case_when(
      ars_min == Inf ~ NA_real_,
      ars_min == -Inf ~ NA_real_,
      is.na(ars_min) ~ NA_real_,
      TRUE ~ ars_min
    ),
    ars_med = case_when(
      ars_med == Inf ~ NA_real_,
      ars_med == -Inf ~ NA_real_,
      is.na(ars_med) ~ NA_real_,
      TRUE ~ ars_med
    ),
    ars_mean = case_when(
      ars_mean == NaN ~ NA_real_,
      is.na(ars_mean) ~ NA_real_,
      TRUE ~ ars_mean
    ),
    ars_sd = case_when(
      ars_sd == NaN ~ NA_real_,
      is.na(ars_sd) ~ NA_real_,
      TRUE ~ ars_sd
    ),
    year_first = case_when(
      year_first == Inf ~ NA_real_,
      year_first == -Inf ~ NA_real_,
      is.na(year_first) ~ NA_real_,
      TRUE ~ year_first
    ),
    year_last = case_when(
      year_last == Inf ~ NA_real_,
      year_last == -Inf ~ NA_real_,
      is.na(year_last) ~ NA_real_,
      TRUE ~ year_last
    ),
    ars_n = case_when(
      is.na(ars_mean) ~ 0,
      TRUE ~ ars_n
    )
  )

redsquirrels <- ds_grouped

write_csv(redsquirrels, here("data-raw", "redsquirrels.csv"))
usethis::use_data(redsquirrels, overwrite = TRUE, compress = "xz")
