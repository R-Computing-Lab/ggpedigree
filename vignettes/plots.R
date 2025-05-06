## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width  = 7,
  fig.height = 5
)
library(ggBGmisc)   # ggPedigree lives here
library(BGmisc)     # helper utilities & example data
library(ggplot2)   # ggplot2 for plotting


## -----------------------------------------------------------------------------
data("potter")
ggPedigree(potter, 
           famID_col = "famID", 
           personID_col = "personID", 
           code_male = 1)

## -----------------------------------------------------------------------------
ggPedigree(
  potter,
  famID_col    = "famID",
  personID_col = "personID",
  code_male    = 1,
  config = list(
    spouse_segment_color = "pink",
    sibling_segment_color = "blue",
    parent_segment_color = "green",
    offspring_segment_color = "black",
    text_size  = 3.5,
    point_size = 5,
    line_width = 0.8
  )
)


## -----------------------------------------------------------------------------
ggPedigree(potter, famID_col = "famID", 
           personID_col = "personID", 
           code_male = 1) +
  theme_bw(base_size = 12)

## -----------------------------------------------------------------------------
data("hazard")
p <- ggPedigree(
  hazard,
  famID_col    = "famID",
  personID_col = "ID",
  code_male    = 0
)

p

## -----------------------------------------------------------------------------
p +
  facet_wrap(~ famID, scales = "free_x")


## -----------------------------------------------------------------------------

p +  
  theme_bw(base_size = 12) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.line        = element_line(colour = "black"),
    axis.text.x      = element_blank(),
    axis.text.y      = element_blank(),
    axis.ticks.x     = element_blank(),
    axis.ticks.y     = element_blank(),
    axis.title.x     = element_blank(),
    axis.title.y     = element_blank()
  )


