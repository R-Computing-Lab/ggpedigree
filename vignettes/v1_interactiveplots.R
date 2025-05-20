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

## ----customize-aesthetics-----------------------------------------------------
plt <- ggPedigreeInteractive(
  potter,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  config = list(
    label_nudge_y   = -.25,
    include_labels  = TRUE,
    label_method    = "geom_text",
    sex_color       = TRUE
  ),
  tooltip_cols = c("personID", "name")
)

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

## ----further-customization----------------------------------------------------
plt2 <- plt %>%
  plotly::layout(
    title = "The Potter Family Tree (interactive)",
    hoverlabel = list(bgcolor = "white"),
    margin = list(l = 50, r = 50, t = 50, b = 50)
  ) %>%
  plotly::config(displayModeBar = TRUE)

## ----eval=FALSE, include=TRUE-------------------------------------------------
# plt2

## ----echo=FALSE---------------------------------------------------------------
# reduce file size for CRAN
if (interactive()) {
  # If running interactively, use plotly::partial_bundle
  # to reduce file size for CRAN
  plotly::partial_bundle(plt2)
} else {
  plotly::partial_bundle(plt2, local = TRUE)
}

## ----save-widget, eval=FALSE--------------------------------------------------
# htmlwidgets::saveWidget(
#   plt,
#   file = "potter_interactive.html",
#   selfcontained = TRUE
# )
# # Note: The above code will save the widget in the current working directory.

## ----static-plot--------------------------------------------------------------
static <- ggPedigreeInteractive(
  potter,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  config = list(
    label_nudge_y = -.25,
    include_labels = TRUE,
    label_method = "geom_text",
    sex_color = TRUE,
    return_static = TRUE
  ),
  tooltip_cols = c("personID", "name")
)

## ----static-plot-customization------------------------------------------------
static_plot <- static +
  ggplot2::labs(
    title = "The Potter Family Tree (static)",
    subtitle = "This is a static plot"
  ) +
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

static_plot

## ----static-to-interactive----------------------------------------------------
plt2 <- plotly::ggplotly(static_plot,
  tooltip = "text",
  width   = NULL,
  height  = NULL
)

## ----eval=FALSE, include=TRUE-------------------------------------------------
# plt2

## ----echo=FALSE---------------------------------------------------------------
# reduce file size for CRAN
if (interactive()) {
  # If running interactively, use plotly::partial_bundle
  # to reduce file size for CRAN
  plotly::partial_bundle(plt2)
} else {
  plotly::partial_bundle(plt2, local = TRUE)
}

