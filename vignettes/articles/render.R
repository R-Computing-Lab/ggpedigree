# Load required package
library(rmarkdown)
library(ggpedigree)
library(BGmisc)
library(ggpedigree)
library(tidyverse)
library(showtext)
library(sysfonts)
library(patchwork) # for combining plots
# library(extrafont)
# font_import()
# loadfonts(device = "win")
# required for font to actually render
font_add_google(name = "Cormorant", family = "cormorant")
showtext_auto()


# Define file paths
input_dir <- "vignettes/articles"
input_file <- file.path(input_dir, "_paper.Rmd")  # Update filename if needed
output_dir <- input_dir  # Same as input location

# Render md_document
render(
  input = input_file,
  output_format = "md_document",
  output_file = "paper.md",
  output_dir = output_dir
)

# Render rticles::joss_article
render(
  input = input_file,
  output_format = "rticles::joss_article",
  output_file = "paper.pdf",
  output_dir = output_dir
)

# Render rmarkdown::html_vignette
#render(
#  input = input_file,
#  output_format = "rmarkdown::html_vignette",
#  output_file = "ggpedigree_vignette.html",
#  output_dir = output_dir
#)
