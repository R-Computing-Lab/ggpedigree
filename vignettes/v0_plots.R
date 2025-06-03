## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 5.6,
  fig.height = 4
)

## ----libraries, message=FALSE, warning=FALSE----------------------------------
library(ggpedigree) # ggPedigree lives here
library(BGmisc) # helper utilities & example data
library(ggplot2) # ggplot2 for plotting
library(viridis) # viridis for color palettes
library(tidyverse) # for data wrangling

## ----load-data, include=FALSE-------------------------------------------------
# if you don't have the most recent version of BGmisc, you may need to install it first as a stop-gap I've added the data loading here
data("potter") # load example data from BGmisc
if (!"twinID" %in% names(potter)) {
  # Add twinID and zygosity columns for demonstration purposes
  potter <- potter %>%
    mutate(
      twinID = case_when(
        name == "Fred Weasley" ~ 13,
        name == "George Weasley" ~ 12,
        TRUE ~ NA_real_
      ),
      zygosity = case_when(
        name == "Fred Weasley" ~ "mz",
        name == "George Weasley" ~ "mz",
        TRUE ~ NA_character_
      )
    )
}

## ----basic-usage--------------------------------------------------------------
ggPedigree(potter,
  famID = "famID",
  personID = "personID"
)

## ----customize-aesthetics-----------------------------------------------------
ggPedigree(
  potter,
  famID = "famID",
  personID = "personID",
  config = list(
    code_male = 1, # Here, 1 = male, 0 = female
    sex_color_include = FALSE,
    point_size = 4,
    line_width = 1,
    segment_spouse_color = viridis_pal()(5)[1],
    segment_sibling_color = viridis_pal()(5)[2],
    segment_parent_color = viridis_pal()(5)[3],
    segment_offspring_color = viridis_pal()(5)[4],
    segment_mz_color = viridis_pal()(5)[5],
    segment_linetype = 3,
    outline_include = TRUE,
    outline_color = viridis_pal()(5)[5]
  )
)

## -----------------------------------------------------------------------------
ggPedigree(potter,
  famID = "famID",
  personID = "personID"
) +
  theme_bw(base_size = 12)

## -----------------------------------------------------------------------------
ggPedigree(
  potter,
  famID = "famID",
  personID = "personID",
  config = list(
    label_col = "name",
    label_text_angle = -45,
    label_nudge_y = -.25,
    label_nudge_x = 0.45,
    label_method = "geom_text",
    #   sex_color_palette = c("black", "black"),
    sex_color_include = TRUE
  )
)

