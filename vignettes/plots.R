## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)
library(ggBGmisc) # ggPedigree lives here
library(BGmisc) # helper utilities & example data
library(ggplot2) # ggplot2 for plotting
library(viridis) # viridis for color palettes

## -----------------------------------------------------------------------------
data("potter")
ggPedigree(potter,
  famID_col = "famID",
  personID_col = "personID",
  code_male = 1
)

## -----------------------------------------------------------------------------
ggPedigree(
  potter,
  famID_col = "famID",
  personID_col = "personID",
  code_male = 1,
  config = list(
    spouse_segment_color = "pink",
    sibling_segment_color = "blue",
    parent_segment_color = "green",
    offspring_segment_color = "black",
    text_size = 3,
    point_size = 4,
    line_width = 0.5,
    generation_gap = 1,
    sex_unknown_code = NA,
    unknown_shape = 18,
    female_shape = 16,
    male_shape = 15
  )
)

## -----------------------------------------------------------------------------
ggPedigree(potter,
  famID_col = "famID",
  personID_col = "personID",
  code_male = 1
) +
  theme_bw(base_size = 12)

