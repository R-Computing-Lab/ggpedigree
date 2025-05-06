#' Plot a custom pedigree diagram
#'
#' This function takes a pedigree dataset and generates a custom ggplot2-based pedigree diagram.
#' It processes the data using `ped2fam()`, calculates coordinates and family connections, and
#' returns a ggplot object with customized styling.
#'
#' @param ped A data frame containing the pedigree data.
#' @param famID_col Character string specifying the column name for family IDs.
#' @param personID_col Character string specifying the column name for individual IDs.
#' @param momID_col Character string specifying the column name for mother IDs. Defaults to "momID".
#' @param dadID_col Character string specifying the column name for father IDs. Defaults to "dadID".
#' @param code_male Numeric value specifying the male code (typically 0 or 1). Defaults to 1.
#' @param status_col Character string specifying the column name for affected status. Defaults to NULL.
#' @param config A list of configuration options for customizing the plot. The list can include:
#'  - `spouse_segment_color`: Color for spouse segments (default: "pink").
#'  - `sibling_segment_color`: Color for sibling segments (default: "blue").
#'  - `parent_segment_color`: Color for parent segments (default: "green").
#'  - `offspring_segment_color`: Color for offspring segments (default: "black").
#'  - `text_size`: Size of the text labels (default: 3).
#'  - `point_size`: Size of the points (default: 4).
#'  - `line_width`: Width of the lines (default: 0.5).
#'  - `generation_gap`: Gap between generations (default: 1).
#'  - `unknown_shape`: shape id for unknown sex (default: 18).
#'  - `female_shape`: shape id for female sex (default: 16).
#'  - `male_shape`: shape id for male sex (default: 15).
#'  - `affected_shape`: shape id for affected individuals (default: 4).
#'  - `sex_shape_labs`: labels for sex variable  (default: c("Female", "Male", "Unknown"))

#' @return A ggplot object representing the pedigree diagram.
#' @examples
#' library(BGmisc)
#' data("potter")
#' ggPedigree(potter, famID_col = "famID", personID_col = "personID", code_male = 1)
#'
#' data("hazard")
#' ggPedigree(hazard, famID_col = "famID", personID_col = "ID", code_male = 0)
#'
#' @export

ggPedigree <- function(ped, famID_col = "famID",
                       personID_col = "personID",
                       momID_col = "momID",
                       dadID_col = "dadID", code_male = 1,
                       status_col = NULL,
                       config = list()) {
  # STEP 1: Convert to pedigree format


  # default config
  default_config <- list(
    spouse_segment_color = "black",
    sibling_segment_color = "black",
    parent_segment_color = "black",
    offspring_segment_color = "black",
    text_size = 3,
    point_size = 4,
    line_width = 0.5,
    generation_gap = 1,
    unknown_shape = 18,
    female_shape = 16,
    male_shape = 15,
    affected_shape = 4,
    shape_labs = c("Female", "Male", "Unknown")
  )

  # Add fill in default_config values to config if config doesn't already have them

  config <- utils::modifyList(default_config, config)


  ds <- BGmisc::ped2fam(ped,
    famID = famID_col,
    personID = personID_col,
    momID = momID_col,
    dadID = dadID_col
  )

  if ("famID.y" %in% names(ds)) {
    ds <- dplyr::select(ds, -.data$famID.y)
  }


  if ("famID.x" %in% names(ds)) {
    ds <- dplyr::rename(ds, famID = .data$famID.x)
  }

  # If the input personID_col was not "personID", rename to "personID" for downstream functions

  if (personID_col != "personID") {
    ds <- dplyr::rename(ds, personID = !!personID_col)
  }

  # If the input personID_col was not "personID", rename to "personID" for downstream functions
  # STEP 2: Recode sex

  ds <- BGmisc::recodeSex(ds, recode_male = code_male)

  # STEP 3: Calculate coordinates
  ds <- calculateCoordinates(ds,
    personID = "personID",
    momID = momID_col,
    dadID = dadID_col,
    code_male = code_male
  )

  if (!isTRUE(all.equal(config$generation_gap, 1))) {
    ds$y_pos <- ds$y_pos * config$generation_gap # expand/contract generations
  }

  # STEP 4: Calculate connections

  connections <- calculateConnections(ds)

  # STEP 5: Create the plot
  gap_off <- 0.5 * config$generation_gap # single constant for all “stub” offsets

  p <- ggplot2::ggplot(ds, ggplot2::aes(
    x = .data$x_pos,
    y = .data$y_pos
  )) +
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_spouse,
        xend = .data$x_pos,
        y = .data$y_spouse,
        yend = .data$y_pos
      ),
      linewidth = config$line_width,
      color = config$spouse_segment_color,
      na.rm = TRUE
    ) +
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_mid_sib,
        xend = .data$x_midparent,
        y = .data$y_mid_sib - gap_off,
        yend = .data$y_midparent
      ),
      linewidth = config$line_width,
      color = config$parent_segment_color,
      na.rm = TRUE
    ) +
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_pos,
        xend = .data$x_mid_sib,
        y = .data$y_pos - gap_off,
        yend = .data$y_mid_sib - gap_off
      ),
      linewidth = config$line_width,
      color = config$offspring_segment_color,
      na.rm = TRUE
    ) +
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_pos,
        xend = .data$x_pos,
        y = .data$y_mid_sib - gap_off,
        yend = .data$y_pos
      ),
      linewidth = config$line_width,
      color = config$sibling_segment_color,
      na.rm = TRUE
    )


  ## -- node layer -----------------------------------------------------------
  p <- p +
    ggplot2::geom_point(
      ggplot2::aes(
        color = as.factor(.data$sex),
        shape = as.factor(.data$sex)
      ),
      size = config$point_size,
      na.rm = TRUE
    )
  ## -- affected individuals -------------------------------------------------
  if (!is.null(status_col)) {
    p <- p + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(status_col)),
      shape = config$affected_shape,
      size = config$point_size,
      na.rm = TRUE
    )
  }

  ## -- labels ---------------------------------------------------------------

  p <- p +
    ggrepel::geom_text_repel(ggplot2::aes(label = .data$personID),
      nudge_y = -.15*config$generation_gap,
      size = config$text_size
    )
  ## -- scales / legends -----------------------------------------------------
  shape_vals <- c(config$female_shape, config$male_shape, config$unknown_shape)

  p <- p +
    ggplot2::scale_shape_manual(
      values = shape_vals,
      labels = config$shape_labs
    ) +
    ggplot2::scale_y_reverse()

  if (!is.null(status_col)) {
    p <- p + ggplot2::scale_alpha_manual(
      name = NULL,
      values = c("unaffected" = 0, "affected" = 1),
      na.translate = FALSE
    ) + ggplot2::guides(alpha = "none")
  }

  ## -- theme ----------------------------------------------------------------

  p <- p +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.title.y = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank()
    ) +
    ggplot2::scale_color_discrete(labels = config$shape_labs) +
    ggplot2::labs(color = "Sex", shape = "Sex")

  return(p)
}
