## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----libraries, message=FALSE, warning=FALSE----------------------------------
library(ggpedigree) # ggPedigree lives here
library(BGmisc) # helper utilities & example data
library(ggplot2) # ggplot2 for plotting
library(viridis) # viridis for color palettes
library(tidyverse) # for data wrangling

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
    offspring_segment_color = "black"
  )
)

## -----------------------------------------------------------------------------
ggPedigree(potter,
  famID_col = "famID",
  personID_col = "personID",
  code_male = 1
) +
  theme_bw(base_size = 12)

## -----------------------------------------------------------------------------
data("hazard")

p <- ggPedigree(
  hazard, #%>% mutate(affected = as.factor(ifelse(affected == TRUE, "affected", "uneffected"))),
  famID_col = "famID",
  personID_col = "ID",
  code_male = 0,
  status_col = "affected",
  config =list (affected=TRUE,
                unaffected=FALSE,
                affected_shape = 4
))

p

## -----------------------------------------------------------------------------
p +
  facet_wrap(~famID, scales = "free_x")

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
  ) + scale_color_viridis(
    discrete = TRUE,
    labels = c("Female", "Male", "Unknown")
  )

