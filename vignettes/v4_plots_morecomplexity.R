## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----libraries, message=FALSE, warning=FALSE----------------------------------
# Install your package from GitHub

library(ggpedigree) # ggPedigree lives here
library(BGmisc) # helper utilities & example data
library(ggplot2) # ggplot2 for plotting
library(viridis) # viridis for color palettes
library(tidyverse) # for data wrangling

## ----echo=TRUE, message=FALSE, warning=FALSE----------------------------------
data(ASOIAF)

## -----------------------------------------------------------------------------
head(ASOIAF)

## -----------------------------------------------------------------------------
df_got <- checkSex(ASOIAF,
  code_male = "M",
  code_female = "F",
  repair = TRUE
)


# Find the IDs of Jon Snow and Daenerys Targaryen

jon_id <- df_got %>%
  filter(name == "Jon Snow") %>%
  pull(ID)

dany_id <- df_got %>%
  filter(name == "Daenerys Targaryen") %>%
  pull(ID)

## -----------------------------------------------------------------------------
df_repaired <- checkParentIDs(df_got,
  addphantoms = TRUE,
  repair = TRUE,
  parentswithoutrow = FALSE,
  repairsex = FALSE
) %>% mutate(
  famID = 1,
  affected = case_when(
    ID %in% c(jon_id, dany_id, "365") ~ 1,
    TRUE ~ 0
  )
)

## ----message=FALSE, warning=FALSE---------------------------------------------
plotPedigree(df_repaired,
  affected = df_repaired$affected,
  verbose = FALSE
)

## ----message=FALSE, warning=FALSE---------------------------------------------

pltstatic <- ggPedigree(df_repaired,
  status_column = "affected",
  personID = "ID",
  config = list(
    return_static = TRUE,
    status_label_unaffected = 0,
    sex_color_include = TRUE,
    code_male = "M",
    point_size=1,
    status_label_affected = 1,
    status_affected_shape = 4,
    ped_width = 14,
    tooltip_include = TRUE,
    label_nudge_y = -.25,
    label_include = TRUE,
    label_method = "geom_text",
    segment_self_color = "purple",
    tooltip_columns = c("ID", "name")
  )
)

pltstatic

## ----message=FALSE, warning=FALSE---------------------------------------------
plt <- ggPedigreeInteractive(df_repaired,
  status_column = "affected",
  personID = "ID",
  config = list(
    status_label_unaffected = 0,
    sex_color_include = TRUE,
    code_male = "M",
    point_size = 1,
    status_label_affected = 1,
    status_affected_shape = 4,
    ped_width = 14,
    segment_self_angle = 90,
    segment_self_curvature = -0.2,
    tooltip_include = TRUE,
    label_nudge_y = -.25,
    label_include = TRUE,
    label_method = "geom_text",
    segment_self_color = "purple",
    tooltip_columns = c("ID", "name")
  )
)

plt

