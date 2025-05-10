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

