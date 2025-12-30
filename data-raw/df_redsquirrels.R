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

# Ped <- readxl::read_excel("data-raw/Pedigree_dryadcopy.xlsx",
#  col_types = c(
#    "numeric", "numeric", "numeric",
#    "text"
#  )
# )
# write_csv(Ped, here("data-raw", "Pedigree_dryadcopy.csv"), na = "")

Ped <- read.csv(here("data-raw", "Pedigree_dryadcopy.csv")) %>%
  suppressWarnings()

Ped <- Ped %>% rename(
  momID = dam,
  personID = id,
  dadID = sire,
  sex = Sex
)

# LRS <- readxl::read_excel("data-raw/LRS_fordryad.xlsx", col_types = c(
#  "numeric", "numeric", "numeric",
#  "text", "numeric", "numeric", "text",
#  "numeric"
# )) %>%
#  suppressWarnings()

# write_csv(LRS, here("data-raw", "LRS_fordryad.csv"), na = "")
LRS <- read.csv(here("data-raw", "LRS_fordryad.csv")) %>%
  suppressWarnings()

LRS <- LRS %>%
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

# ARS <- readxl::read_excel("data-raw/ARS_dryadcopy.xlsx",
#  col_types = c(
#    "numeric", "numeric", "numeric",
#    "text", "numeric", "numeric", "text",
#    "numeric", "numeric"
#  )
# ) %>%
#  suppressWarnings()


# write_csv(ARS, here("data-raw", "ARS_dryadcopy.csv"), na = "")
ARS <- read.csv(here("data-raw", "ARS_dryadcopy.csv")) %>%
  suppressWarnings()

ARS <- ARS %>%
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
  summarize(
    ars_mean = round(mean(ars, na.rm = TRUE), digits = 2),
    ars_max = round(max(ars, na.rm = TRUE), digits = 2),
    ars_med = round(median(ars, na.rm = TRUE), digits = 2),
    ars_min = round(min(ars, na.rm = TRUE), digits = 2),
    ars_sd = round(sd(ars, na.rm = TRUE), digits = 2),
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

redsquirrels_full <- ds_grouped %>%
  arrange(personID)

write_csv(redsquirrels_full, here("data-raw", "redsquirrels_full.csv"), na = "")

usethis::use_data(redsquirrels_full, overwrite = TRUE, compress = "xz")


group_fams_withdads <- ds_grouped %>%
  group_by(famID) %>%
summarize(
    unq_dadID_n =  n_distinct(dadID[!is.na(dadID)]),
    unq_momID_n =  n_distinct(momID[!is.na(momID)])
  ) %>% filter(unq_dadID_n > 0 )


# handling families that have at least one dadID present
redsquirrels <- ds_grouped %>%
  filter(famID %in% group_fams_withdads$famID) %>%
  select(-year_first, -year_last, -ars_sd, -ars_n, -ars_min, -ars_med, -ars_max) %>%
  arrange(personID)

write_csv(redsquirrels, here("data-raw", "redsquirrels.csv"), na = "")

usethis::use_data(redsquirrels, overwrite = TRUE, compress = "xz")
