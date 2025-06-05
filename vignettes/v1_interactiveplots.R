## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----load-packages------------------------------------------------------------
# Load required packages
library(BGmisc) # ships the sample 'potter' pedigree
library(ggplot2) # used internally by ggPedigree*
library(viridis) # viridis for color palettes
library(plotly) # conversion layer for interactivity
library(ggpedigree) # the package itself

## ----load-data----------------------------------------------------------------
# Load the example data
data("potter")
# Display the first few rows of the dataset
head(potter)

## ----basic-usage-2------------------------------------------------------------
plt <- ggPedigreeInteractive(
  potter,
  famID    = "famID",
  personID = "personID",
  momID    = "momID",
  dadID    = "dadID"
) |> plotly::hide_legend()

## ----eval=FALSE, include=TRUE-------------------------------------------------
# plt

## ----echo=FALSE---------------------------------------------------------------
# reduce file size for CRAN
if (interactive()) {
  # If running interactively, use plotly::partial_bundle
  # to reduce file size for CRAN
  plotly::partial_bundle(plt)
} else {
  plotly::partial_bundle(plt, local = TRUE)
}
