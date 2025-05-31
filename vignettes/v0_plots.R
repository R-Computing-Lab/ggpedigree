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

## ----basic-usage--------------------------------------------------------------
data("potter")
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
    line_width = 1,
    segment_spouse_color = viridis_pal()(5)[1],
    segment_sibling_color = viridis_pal()(5)[2],
    segment_parent_color = viridis_pal()(5)[3],
    segment_offspring_color = viridis_pal()(5)[4],
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

## -----------------------------------------------------------------------------
data("hazard")

p <- ggPedigree(
  hazard,
  famID = "famID",
  personID = "ID",
  status_column = "affected",
  config = list(
    code_male = 0,
    sex_color_include = TRUE,
    status_code_affected = TRUE,
    status_code_unaffected = FALSE,
    status_affected_shape = 4
  )
)

p

## -----------------------------------------------------------------------------
ggPedigree(
  hazard,
  famID = "famID",
  personID = "ID",
  status_column = "affected",
  config = list(
    code_male = 0,
    sex_color_include = FALSE,
    status_code_affected = TRUE,
    status_code_unaffected = FALSE,
    status_label_affected = "Infected",
    status_label_unaffected = "Not infected",
    status_affected_legend_title = "Status"
  )
)

## -----------------------------------------------------------------------------
df <- potter

df <- df %>%
  mutate(proband = ifelse(name %in% c(
    "Harry Potter",
    "Dudley Dursley"
  ), TRUE, FALSE))

ggPedigree(
  df,
  famID = "famID",
  personID = "personID",
  status_column = "proband",
  config = list(
    sex_color_include = TRUE,
    status_code_affected = TRUE,
    status_code_unaffected = FALSE,
    status_affected_shape = 8 # star shape
  )
)

## ----facet_wrap---------------------------------------------------------------
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
    option = "plasma",
    discrete = TRUE,
    labels = c("Female", "Male", "Unknown")
  )

## ----self-loops, message=FALSE, warning=FALSE---------------------------------
library(BGmisc) # helper utilities & example data

data("inbreeding")


df <- inbreeding # multigenerational pedigree with consanguinity


# df  <- dplyr::filter(df, famID %in% c(5, 7))


p <- ggPedigree(
  df,
  famID = "famID",
  personID = "ID",
  status_column = "proband",
  #  debug = TRUE,
  config = list(
    code_male = 0,
    sex_color_include = FALSE,
    status_code_affected = TRUE,
    status_code_unaffected = FALSE,
    generation_height = 4,
    generation_width = 2,
    status_affected_shape = 4,
    segment_self_color = "purple"
  )
)

p + facet_wrap(~famID, scales = "free") #+ scale_color_viridis(
#   discrete = TRUE,
#   labels = c("TRUE", "FALSE")
#  )  + theme_bw(base_size = 14)  +  guides(colour="none", shape="none")

