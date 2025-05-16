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
    sex_color = FALSE,
    line_width = 1,
    segment_spouse_color = viridis_pal()(5)[1],
    segment_sibling_color = viridis_pal()(5)[2],
    segment_parent_color =viridis_pal()(5)[3],
    segment_offspring_color = viridis_pal()(5)[4],
    outline = TRUE,
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
    label_text_angle =  -45,
    label_nudge_y= -.25,
    label_nudge_x = 0.45,
    label_method = "geom_text",
    sex_color = TRUE
  )
)

## -----------------------------------------------------------------------------
data("hazard")

p <- ggPedigree(
  hazard,
  famID = "famID",
  personID = "ID",
  status_col = "affected",
  config = list(
    code_male = 0,
    sex_color = TRUE,
    status_affected_lab = TRUE,
    status_unaffected_lab = FALSE,
    status_affected_shape = 4
  )
)

p

## -----------------------------------------------------------------------------
ggPedigree(
  hazard,
  famID = "famID",
  personID = "ID",
  status_col = "affected",
  config = list(
    code_male = 0,
    sex_color = FALSE,
    status_affected_lab = TRUE,
    status_unaffected_lab = FALSE
  )
)

## -----------------------------------------------------------------------------
df <- potter

df <- df %>%
  mutate(proband = ifelse(name %in% c("Harry Potter", "Dudley Dursley"), TRUE, FALSE))

ggPedigree(
  df,
  famID = "famID",
  personID = "personID",
  status_col = "proband",
  config = list(
    sex_color = TRUE,
    status_affected_lab = TRUE,
    status_unaffected_lab = FALSE,
    status_affected_shape = 8  # star shape
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
    discrete = TRUE,
    labels = c("Female", "Male", "Unknown")
  )

## ----self-loops, message=FALSE, warning=FALSE---------------------------------
library(BGmisc) # helper utilities & example data

data("inbreeding")

df <- inbreeding # multigenerational pedigree with consanguinity

#df  <- dplyr::filter(df, famID %in% c(5, 7))


p <- ggPedigree(
  df,
  famID = "famID",
  personID = "ID",
  status_col = "proband",
  #  debug = TRUE,
  config = list(
    code_male = 0,
    sex_color = FALSE,
    status_affected_lab = TRUE,
    status_unaffected_lab = FALSE,
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

## -----------------------------------------------------------------------------

library(tibble)
library(dplyr)
pedigree_df <- tribble(
  ~personID, ~momID, ~dadID, ~sex, ~famID,
  10011, NA, NA, 0, 1,
  10012, NA, NA, 1, 1,
  10021, NA, NA, 1, 1,
  10022, 10011, 10012, 1, 1,
  10023, 10011, 10012, 0, 1,
  10024, NA, NA, 0, 1,
  10025, NA, NA, 0, 1,
  10026, 10011, 10012, 0, 1,
  10027, 10011, 10012, 1, 1,
  10031, 10023, 10021, 0, 1,
  10032, 10023, 10021, 1, 1,
  10033, 10023, 10021, 1, 1,
  10034, 10023, 10021, 1, 1,
  10035, 10023, 10021, 0, 1,
  10036, 10024, 10022, 1, 1,
  10037, 10024, 10022, 0, 1,
  10038, 10025, 10027, 1, 1,
  10039, 10025, 10027, 0, 1,
  10310, 10025, 10027, 1, 1,
  10311, 10025, 10027, 1, 1,
  10312, 10025, 10027, 0, 1,
  10011, NA, NA, 0, 2,
  10012, NA, NA, 1, 2,
  10021, NA, NA, 0, 2,
  10022, 10011, 10012, 0, 2,
  10023, 10011, 10012, 1, 2,
  10024, 10011, 10012, 1, 2,
  10025, NA, NA, 1, 2,
  10026, 10011, 10012, 0, 2,
  10027, NA, NA, 1, 2,
  10031, 10021, 10023, 1, 2,
  10032, 10021, 10023, 0, 2,
  10033, 10021, 10023, 1, 2,
  10034, 10022, 10025, 0, 2,
  10035, 10022, 10025, 0, 2,
  10036, 10022, 10025, 1, 2,
  10310, 10022, 10025, 1, 2,
  10037, 10026, 10027, 0, 2,
  10038, 10026, 10027, 0, 2,
  10039, 10026, 10027, 0, 2,
  10311, 10026, 10027, 1, 2,
  10312, 10026, 10027, 1, 2
) %>% 
  mutate(
    cleanpersonID = personID - 10000,
    personID = ifelse(famID == 1, personID - 10000, personID),
    momID    = ifelse(famID == 1 & !is.na(momID), momID - 10000, momID),
    dadID    = ifelse(famID == 1 & !is.na(dadID), dadID - 10000, dadID),
    proband =  case_when(personID %in% c(11,22,23,26,27,31,32,33,34,35) ~ TRUE,
                        personID %in% c(10011,10022,10022,10023,10024,10026,
                                        10034,10035,10036,10310,
                                        10037,10038,10039,10311,
                                        10312) ~ TRUE,
                         TRUE ~ FALSE)
  )

## -----------------------------------------------------------------------------
p <- ggPedigree(
  pedigree_df,
  famID = "famID",
  personID = "personID",
  status_col = "proband",
  #  debug = TRUE,
  config = list(
    code_male = 1,
    sex_color = FALSE,
    apply_default_scales = FALSE,
    label_method = "geom_text",
    label_col = "cleanpersonID",
    status_affected_lab = TRUE,
    status_unaffected_lab = FALSE,
    generation_height = 1,
    generation_width = 1,
    status_affected_shape = 4,
    segment_spouse_color = "black",
    segment_sibling_color = "black",
    segment_parent_color = "black",
    segment_offspring_color = "black"
  )
)

## ----message=FALSE, warning=FALSE---------------------------------------------
p + scale_shape_manual(
  values = c(16, 15, 15),
  labels = c("Female", "Male", "Unknown")
) +
  guides(shape = "none") + scale_color_viridis(
    discrete = TRUE,
    labels = c("TRUE", "FALSE"),
    name = "Founding MtDNA Line"
  ) + 
  facet_wrap(~famID, scales= "free", shrink = TRUE) + 
  theme(strip.text = element_blank(),
        legend.position = "bottom")

