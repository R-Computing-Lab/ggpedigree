library(profvis)
pak::pak("ropensci-review-tools/goodpractice")
library(goodpractice)

gp <- goodpractice::gp()

if (F) {
  profvis({
    library(dplyr)
    library(ggplot2)
    library(ggpedigree)
    plt <- ggPedigreeInteractive(df_repaired,
      status_column = "affected",
      personID = "ID",
      config = list(
        status_label_unaffected = 0,
        sex_color_include = TRUE,
        code_male = "M",
        point_size = 1,
        status_label_affected = 1,
        status_affected_shape = 4,
        ped_width = 14,
        segment_self_angle = 90,
        segment_self_curvature = -0.2,
        tooltip_include = TRUE,
        label_nudge_y = -.25,
        label_include = TRUE,
        label_method = "geom_text",
        segment_self_color = "purple",
        tooltip_columns = c("ID", "name")
      )
    )

    plt
  })
}
