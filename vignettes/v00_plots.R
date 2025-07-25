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

## ----load-data, include=FALSE-------------------------------------------------
# if you don't have the most recent version of BGmisc, you may need to install it first as a stop-gap I've added the data loading here
data("potter") # load example data from BGmisc
# if (!"twinID" %in% names(potter)) {
# Add twinID and zygosity columns for demonstration purposes
potter <- potter %>%
  mutate(
    twinID = case_when(
      name == "Fred Weasley" ~ 13,
      name == "George Weasley" ~ 12,
      TRUE ~ NA_real_
    ),
    zygosity = case_when(
      name == "Fred Weasley" ~ "mz",
      name == "George Weasley" ~ "mz",
      TRUE ~ NA_character_
    )
  )
# }

## ----basic-usage--------------------------------------------------------------
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
    segment_linewidth = .5,
    point_size = 3,
    outline_multiplier = 1.5,
    # outline_additional_size = -1,
    sex_shape_female = "💸",
    sex_shape_male = "🖤",
    segment_spouse_color = viridis_pal()(5)[1],
    segment_sibling_color = viridis_pal()(5)[2],
    segment_parent_color = viridis_pal()(5)[3],
    segment_offspring_color = viridis_pal()(5)[4],
    segment_mz_color = viridis_pal()(5)[5],
    #   segment_linetype = 3,
    outline_include = FALSE,
    outline_color = "grey"
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
    # label_column = "first_name",
    sex_color_palette = c("pink", "blue"),
    label_text_angle = -35,
    label_nudge_y = .215,
    label_nudge_x = 0.45,
    label_method = "geom_text", # "ggrepel", #
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
    status_shape_affected = 4
  )
)

p

## -----------------------------------------------------------------------------
ggPedigree(
  hazard,
  famID = "famID",
  personID = "ID",
  status_column = "affected",
  overlay_column = NULL,
  config = list(
    code_male = 0,
    sex_color_include = TRUE,
    status_include = TRUE,
    overlay_include = FALSE,
    status_code_affected = TRUE,
    status_code_unaffected = FALSE,
    status_label_affected = "Infected",
    status_label_unaffected = "Not infected",
    status_legend_title = "Status",
    focal_fill_include = FALSE,
    status_shape_affected = 4, # "🦠"  # virus shape
    status_legend_show = TRUE
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
    status_include = TRUE,
    status_code_affected = TRUE,
    status_code_unaffected = FALSE,
    status_shape_affected = 8 # "✨"  # star shape
  )
)

## ----focal_fill---------------------------------------------------------------
ggPedigree(potter,
  famID = "famID",
  personID = "personID",
  config = list(
    focal_fill_personID = 7,
    focal_fill_include = TRUE,
    #  focal_fill_high_color = "yellow",
    #  focal_fill_mid_color = "red",
    #   focal_fill_low_color = "#0D082AFF",
    focal_fill_force_zero = TRUE,
    focal_fill_na_value = "black",
    focal_fill_scale_midpoint = 0.25,
    focal_fill_component = "additive",
    focal_fill_method = "gradient",
    focal_fill_n_breaks = NULL,
    focal_fill_legend_title = "Genetic Relatives \nof Harry Potter",
    # "additive",
    sex_color_include = FALSE
  ) # highlight Harry Potter
  # config  = list(segment_mz_color = NA) # color for monozygotic twins
)

## ----focal_fill_mitochondrial-------------------------------------------------
m1 <- ggPedigree(potter,
  famID = "famID",
  personID = "personID",
  config = list(
    focal_fill_personID = 7,
    focal_fill_include = TRUE,
    focal_fill_high_color = "green",
    # focal_fill_mid_color = "white",
    focal_fill_low_color = "black",
    focal_fill_scale_midpoint = 0.55,
    focal_fill_component = "mitochondrial",
    focal_fill_method = "steps",
    focal_fill_n_breaks = 19,
    focal_fill_legend_show = FALSE,
    focal_fill_legend_title = "Mitochondrial Relatives \nof Harry Potter",
    sex_color_include = FALSE
  ) # highlight Harry Potter
  # config  = list(segment_mz_color = NA) # color for monozygotic twins
) + ggplot2::guides(shape = "none")
m2 <- ggPedigree(potter,
  famID = "famID",
  personID = "personID",
  config = list(
    focal_fill_personID = 8,
    focal_fill_include = TRUE,
    focal_fill_high_color = "orange",
    # focal_fill_mid_color = "white",
    focal_fill_low_color = "black",
    focal_fill_scale_midpoint = 0.55,
    focal_fill_component = "mitochondrial",
    focal_fill_method = "steps",
    focal_fill_n_breaks = 19,
    focal_fill_legend_show = FALSE,
    focal_fill_legend_title = "Mitochondrial Relatives \nof Ginny Weasley",
    sex_color_include = FALSE
  ) # highlight Harry Potter
  # config  = list(segment_mz_color = NA) # color for monozygotic twins
) + ggplot2::guides(shape = "none")

library(patchwork) # for combining plots
m1 + m2 + plot_layout(ncol = 2) +
  plot_annotation(title = "Mitochondrial Relatives of Harry Potter and Ginny Weasley")

## ----focal_fill_matID---------------------------------------------------------
ggPedigree(potter,
  famID = "famID",
  personID = "personID",
  config = list(
    focal_fill_personID = 8,
    focal_fill_include = TRUE,
    # focal_fill_mid_color = "white",
    focal_fill_low_color = "black",
    focal_fill_scale_midpoint = 0.55,
    focal_fill_component = "matID",
    focal_fill_method = "viridis_d",
    focal_fill_viridis_option = "turbo",
    focal_fill_n_breaks = 19,
    focal_fill_legend_show = FALSE,
    focal_fill_legend_title = "Mitochondrial Relatives",
    sex_color_include = FALSE,
    overlay_include = FALSE
  ) # highlight Harry Potter
  # config  = list(segment_mz_color = NA) # color for monozygotic twins
) + ggplot2::guides(shape = "none")

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
    option = "mako",
    discrete = TRUE,
    labels = c("Female", "Male", "Unknown")
  )

