# devtools::install_github("R-Computing-Lab/BGmisc")
library(tidyverse)
library(here)
library(readr)
library(usethis)
library(BGmisc)


## Create dataframe
ged <- read_csv("data-raw/df_raw_wor.csv",
  col_types = cols(
    twinID = col_double(),
    zygosity = col_character()
  )
) %>%
  select(-famID)


df <- ped2fam(ged, personID = "id") %>%
  rename(
    personID = id
  )

# df <- df %>%
#  addPersonToPed(
#    personID = 247,
#    url ="",
#  name = "Lady Belmore",
#   sex = "F",

#  momID = NA, dadID = NA,
#   overwrite = FALSE
# )


warsofroses <- df %>%
  select(-famID) %>%
  ped2fam(personID = "personID", famID = "famID") %>%
  rename(
    id = personID
  )

# checks
df_repaired <- checkSex(warsofroses,
  code_male = "M",
  code_female = "F",
  verbose = TRUE, repair = TRUE
) %>%
  checkParentIDs(
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  ) %>%
  rename(
    personID = ID
  )

if (FALSE) {
  ggpedigree::ggPedigree(df_repaired,
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    famID = "famID",
    config = list(
      code_male = "M",
      code_female = "F",
      code_na = "U",
      focal_fill_include = TRUE,
      focal_fill_force_zero = TRUE,
      focal_fill_personID = 1, # Edward III
      # apply_default_scales = FALSE,
      label_column = "name",
      label_method = "ggrepel",
      sex_legend_show = FALSE,
      sex_color_include = FALSE,
      #  focal_fill_high_color = "#4A7023",
      # focal_fill_mid_color =  "#C1E1A6",
      #  focal_fill_low_color =  "#F0F8FF",
      #  focal_fill_na_color = "lightgrey",
      label_include = TRUE,
      label_text_angle = -90,
      label_text_size = 2,
      # label_nudge_y = -0.05#,
      label_nudge_x = -.05
    )
  )
}
checkIDs(df_repaired)

checkis_acyclic <- checkPedigreeNetwork(df_repaired,
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  verbose = TRUE
)
checkis_acyclic
if (checkis_acyclic$is_acyclic) {
  message("The pedigree is acyclic.")
  write_csv(warsofroses, here("data-raw", "warsofroses.csv"))
  usethis::use_data(warsofroses, overwrite = TRUE, compress = "xz")
} else {
  message("The pedigree contains cyclic relationships.")
}

warsofroses %>%
  filter(is.na(momID) & is.na(dadID)) %>%
  select(id, name, famID, momID, dadID, sex) %>%
  mutate(
    first_name = str_extract(name, "^[^ ]+"),
    last_name = str_extract(name, "[^ ]+$"),
  ) %>%
  arrange(last_name, id)
