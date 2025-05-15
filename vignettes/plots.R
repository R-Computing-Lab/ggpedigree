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
  famID = "famID",
  personID = "personID"
)

## -----------------------------------------------------------------------------
ggPedigree(
  potter,
  famID = "famID",
  personID = "personID",
  config = list(
    code_male = 1,
    sex_color = FALSE,
    spouse_segment_color = "pink",
    sibling_segment_color = "blue",
    parent_segment_color = "green",
    offspring_segment_color = "black"
  )
)

## -----------------------------------------------------------------------------
ggPedigree(potter,
  famID = "famID",
  personID = "personID"
) +
  theme_bw(base_size = 12)

## -----------------------------------------------------------------------------
data("hazard")

p <- ggPedigree(
  hazard, # %>% mutate(affected = as.factor(ifelse(affected == TRUE, "affected", "uneffected"))),
  famID = "famID",
  personID = "ID",
  status_col = "affected",
  config = list(
    code_male = 0,
    sex_color = TRUE,
    affected = TRUE,
    unaffected = FALSE,
    affected_shape = 4
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
    affected = TRUE,
    unaffected = FALSE
  )
)

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

## ----message=FALSE, warning=FALSE---------------------------------------------
library(BGmisc) # helper utilities & example data
data("inbreeding")

df <- inbreeding %>% filter(
    famID %in% c(5, 7),
  )


p <- ggPedigree(
  df,
  famID = "famID",
  personID = "ID",
  status_col = "proband",
#  debug = TRUE,
  config = list(
    code_male = 0,
    sex_color = F,
  #  label_method = "geom_text",
    affected = TRUE,
    unaffected = FALSE,
    generation_height = 2,
    generation_width = 1,
    affected_shape = 4,
    spouse_segment_color = "pink",
    sibling_segment_color = "blue",
    parent_segment_color = "green",
    offspring_segment_color = "black"
  )
) 

# p$connections%>%filter(personID     ==60) %>% nrow()
# p$connections%>%filter(personID     ==66) %>% unique()
# p$connections%>%filter(personID     ==65) %>% unique()

# p$connections%>%filter(personID  >=61 &
#       personID  <62 ) %>% unique()

p  + facet_wrap(~famID, scales= "free") #+ scale_color_viridis(
 #   discrete = TRUE,
 #   labels = c("TRUE", "FALSE")
#  )  + theme_bw(base_size = 14)  +  guides(colour="none", shape="none")

## -----------------------------------------------------------------------------
library(tibble)

pedigree_df <- tribble(
  ~personID, ~momID, ~dadID, ~sex, ~famID,
  10011,     NA,     NA,     0,    1,
  10012,     NA,     NA,     1,    1,
  10021,     NA,     NA,     1,    1,
  10022,  10011,  10012,     1,    1,
  10023,  10011,  10012,     0,    1,
  10024,     NA,     NA,     0,    1,
  10025,     NA,     NA,     0,    1,
  10026,  10011,  10012,     0,    1,
  10027,  10011,  10012,     1,    1,
  10031,  10023,  10021,     0,    1,
  10032,  10023,  10021,     1,    1,
  10033,  10023,  10021,     1,    1,
  10034,  10023,  10021,     1,    1,
  10035,  10023,  10021,     0,    1,
  10036,  10024,  10022,     1,    1,
  10037,  10024,  10022,     0,    1,
  10038,  10025,  10027,     1,    1,
  10039,  10025,  10027,     0,    1,
  10310, 10025,  10027,     1,    1,
  10311, 10025,  10027,     1,    1,
  10312, 10025,  10027,     0,    1,
  10011,     NA,     NA,     0,    2,
  10012,     NA,     NA,     1,    2,
  10021,     NA,     NA,     0,    2,
  10022,  10011,  10012,     0,    2,
  10023,  10011,  10012,     1,    2,
  10024,  10011,  10012,     1,    2,
  10025,     NA,     NA,     1,    2,
  10026,  10011,  10012,     0,    2,
  10027,     NA,     NA,     1,    2,
  10031,  10021,  10023,     1,    2,
  10032,  10021,  10023,     0,    2,
  10033,  10021,  10023,     1,    2,
  10034,  10022,  10025,     0,    2,
  10035,  10022,  10025,     0,    2,
  10036,  10022,  10025,     1,    2,
  100310, 10022,  10025,     1,    2,
  10037,  10026,  10027,     0,    2,
  10038,  10026,  10027,     0,    2,
  10039,  10026,  10027,     0,    2,
  100311, 10026,  10027,     1,    2,
  100312, 10026,  10027,     1,    2
) %>% mutate (proband = TRUE)

#pedigree_df <- recodeSex(pedigree_df,code_male = 1, recode_male = "M")
pedigree_df$personID[pedigree_df$famID == 1] <- pedigree_df$personID[pedigree_df$famID == 1]-10000
pedigree_df$momID[pedigree_df$famID == 1] <- pedigree_df$momID[pedigree_df$famID == 1]-10000
pedigree_df$dadID[pedigree_df$famID == 1] <- pedigree_df$dadID[pedigree_df$famID == 1]-10000



p <- ggPedigree(
  pedigree_df,
  famID = "famID",
  personID = "personID",
  status_col = "proband",
#  debug = TRUE,
  config = list(
    code_male = 1,
    sex_color = F,
    apply_default_scales = FALSE,
   label_method = "geom_text",
 #   affected = TRUE,
 #   unaffected = FALSE,
    generation_height = 1,
    generation_width = 1,
    affected_shape = 4,
    spouse_segment_color = "black",
    sibling_segment_color = "black",
    parent_segment_color = "black",
    offspring_segment_color = "black"
  )
)

p + scale_shape_manual(
      values = c(16, 15, 15),
      labels =  c("Female", "Male", "Unknown")
    ) +
  guides(colour="none", shape="none")
 # guides(colour="none", shape="none") + 
#facet_wrap(~famID, scales= "free") 



