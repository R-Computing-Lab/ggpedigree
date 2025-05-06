## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
options(rmarkdown.html_vignette.check_title = FALSE)

## -----------------------------------------------------------------------------
## Loading Required Libraries
library(BGmisc)

set.seed(5)
df_ped <- simulatePedigree(
  kpc = 4,
  Ngen = 4,
  sexR = .5,
  marR = .7
)
summary(df_ped)

## -----------------------------------------------------------------------------
df_ped[21, ]

## -----------------------------------------------------------------------------
summarizeFamilies(df_ped, famID = "fam")$family_summary

## ----fig.width=8,fig.height=6-------------------------------------------------
# Plot the simulated pedigree
plotPedigree(df_ped)

## ----fig.width=8, fig.height=6------------------------------------------------
set.seed(8)
# Simulate a family with 3 generations
df_ped_3 <- simulatePedigree(Ngen = 3)

# Simulate a family with 4 generations
df_ped_4 <- simulatePedigree(Ngen = 4)

# Set up plotting parameters for side-by-side display
par(mfrow = c(1, 2))

# Plot the 3-generation pedigree
plotPedigree(df_ped_3, width = 3)

# Plot the 4-generation pedigree
plotPedigree(df_ped_4, width = 1)

