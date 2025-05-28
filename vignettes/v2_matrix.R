## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5,
  echo = TRUE
)

suppressPackageStartupMessages({
  library(BGmisc)
  library(ggplot2)
  library(dplyr)
  library(reshape2)
  library(tidyverse)
})

## -----------------------------------------------------------------------------
library(ggpedigree)
# Load the example data
data("redsquirrels")

## -----------------------------------------------------------------------------
# sumped <- summarizePedigrees(redsquirrels,
#  famID = "famID",
#  personID = "personID",
#  nbiggest = 5
# )


# Set target family for visualization
fam_filter <- 160 # sumped$biggest_families$famID[3]

# Filter for the largest family, recode sex if needed
ped_filtered <- redsquirrels %>%
  recodeSex(code_female = "F") %>%
  filter(famID == fam_filter)

# Calculate relatedness matrices
add_mat <- ped2add(ped_filtered, isChild_method = "partialparent", sparse = FALSE)
mit_mat <- ped2mit(ped_filtered, isChild_method = "partialparent", sparse = FALSE)

## -----------------------------------------------------------------------------
p_add <- ggRelatednessMatrix(
  add_mat,
  interactive = FALSE,
  config = list(
    color_palette = c("white", "orange", "red"),
    scale_midpoint = 0.55,
    cluster = TRUE,
    title = "Additive Genetic Relatedness",
    include_upper_triangle = F,
    include_lower_triangle = T
  )
)

p_add

## ----mit_mat------------------------------------------------------------------
p_mit <- ggRelatednessMatrix(
  mit_mat,
  interactive = TRUE,
  config = list(
    color_palette = c("white", "skyblue", "darkblue"),
    scale_midpoint = 0.55,
    cluster = TRUE,
    title = "Mitochondrial Relatedness",
    text_size = 6,
    as_widget = TRUE
  )
)

## ----eval=FALSE, include=TRUE-------------------------------------------------
# p_mit

## ----echo=FALSE---------------------------------------------------------------
# reduce file size for CRAN
if (interactive()) {
  plotly::partial_bundle(p_mit)
} else {
  plotly::partial_bundle(p_mit, local = TRUE)
}

## -----------------------------------------------------------------------------
p_add_noclust <- ggRelatednessMatrix(
  add_mat,
  config = list(
    cluster = FALSE, title = "Additive Relatedness (No Clustering)" # ,
    #  geom = "geom_raster"
  )
)
p_add_noclust

## -----------------------------------------------------------------------------
if (requireNamespace("corrplot", quietly = TRUE)) {
  corrplot::corrplot(
    as.matrix(add_mat),
    method = "color",
    type = "lower",
    col.lim = c(0, 1.25),
    is.corr = FALSE,
    title = "Additive Relatedness",
    order = "hclust",
    col = corrplot::COL1("Reds", 100),
    tl.pos = "l", tl.col = "black", tl.srt = 5, tl.cex = 0.2,
    mar = c(0, 0, 2, 0)
  )
}

