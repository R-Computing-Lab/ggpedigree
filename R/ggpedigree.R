#' Plot a custom pedigree diagram
#'
#' Generates a ggplot2-based diagram of a pedigree using custom coordinate layout,
#' calculated relationship connections, and flexible styling via `config`.
#' It processes the data using `ped2fam()`. This function
#' supports multiple families and optionally displays affected status and sex-based color/shape.
#'
#' @param ped A data frame containing the pedigree data. Needs personID, momID, and dadID columns
#' @param famID Character string specifying the column name for family IDs.
#' @param personID Character string specifying the column name for individual IDs.
#' @param momID Character string specifying the column name for mother IDs. Defaults to "momID".
#' @param dadID Character string specifying the column name for father IDs. Defaults to "dadID".
#' @param status_col Character string specifying the column name for affected status. Defaults to NULL.
#' @param config A list of configuration options for customizing the plot. The list can include:
#'  \describe{
#'     \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
#'     \item{spouse_segment_color, self_segment_color, sibling_segment_color, parent_segment_color, offspring_segment_color}{Character. Line colors for respective connection types.}
#'     \item{text_size, point_size, line_width}{Numeric. Controls text size, point size, and line thickness.}
#'     \item{generation_gap}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
#'     \item{unknown_shape, female_shape, male_shape, affected_shape}{Integers. Shape codes for plotting each group.}
#'     \item{sex_shape_labs}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown")}
#'     \item{unaffected, affected}{Values indicating unaffected/affected status.}
#'     \item{sex_color}{Logical. If TRUE, uses color to differentiate sex.}
#'     \item{max_overlaps}{Maximum number of overlaps allowed in repelled labels.}
#'     \item{id_segment_color}{Color used for label connector lines.}
#'   }

#' @return A `ggplot` object rendering the pedigree diagram.
#' @examples
#' library(BGmisc)
#' data("potter")
#' ggPedigree(potter, famID = "famID", personID = "personID")
#'
#' data("hazard")
#' ggPedigree(hazard, famID = "famID", personID = "ID", config = list(code_male = 0))
#'
#' @export

ggPedigree <- function(ped, famID = "famID",
                       personID = "personID",
                       momID = "momID",
                       dadID = "dadID",
                       status_col = NULL,
                       config = list()) {
  # -----
  # STEP 1: Configuration and Preparation
  # -----

  # Set default styling and layout parameters
  default_config <- list(
    spouse_segment_color = "black",
    self_segment_color = "purple",
    sibling_segment_color = "black",
    parent_segment_color = "black",
    offspring_segment_color = "black",
    code_male = 1,
    text_size = 3,
    point_size = 4,
    line_width = 0.5,
    generation_gap = 1,
    unknown_shape = 18,
    female_shape = 16,
    male_shape = 15,
    affected_shape = 4,
    shape_labs = c("Female", "Male", "Unknown"),
    unaffected = "unaffected",
    affected = "affected",
    sex_color = TRUE,
    status_vals = c(1, 0),
    max_overlaps = 100,
    id_segment_color = NA
  )

  # Merge with user-specified overrides
  # This allows the user to override any of the default values
  config <- utils::modifyList(default_config, config)

  # Set additional internal config values based on other entries
  config$status_labs <- c(paste0(config$affected), paste0(config$unaffected))
  config$shape_vals <- c(config$female_shape, config$male_shape, config$unknown_shape)

  # -----
  # STEP 2: Pedigree Data Transformation
  # -----

  ds_ped <- BGmisc::ped2fam(ped,
    famID = famID,
    personID = personID,
    momID = momID,
    dadID = dadID
  )

  # Clean duplicated famID columns if present

  if ("famID.y" %in% names(ds_ped)) {
    ds_ped <- dplyr::select(ds_ped, -.data$famID.y)
  }
  if ("famID.x" %in% names(ds_ped)) {
    ds_ped <- dplyr::rename(ds_ped, famID = .data$famID.x)
  }

  # If personID is not "personID", rename to "personID" internally
  if (personID != "personID") {
    ds_ped <- dplyr::rename(ds_ped, personID = !!personID)
  }

  # Recode affected status into factor, if applicable
  if (!is.null(status_col)) {
    ds_ped[[status_col]] <- factor(ds_ped[[status_col]],
      levels = c(config$affected, config$unaffected)
    )
  }

  # -----
  # STEP 3: Sex Recode
  # -----

  # Standardize sex variable using code_male convention
  ds_ped <- BGmisc::recodeSex(ds_ped, recode_male = config$code_male)

  # -----
  # STEP 4: Coordinate Generation
  # -----

  # Compute layout coordinates using pedigree structure
  ds <- calculateCoordinates(ds_ped,
    personID = "personID",
    momID = momID,
    dadID = dadID,
    code_male = config$code_male,
    config = config
  )

  # Apply vertical spacing factor if generation_gap ≠ 1
  if (!isTRUE(all.equal(config$generation_gap, 1))) {
    ds$y_pos <- ds$y_pos * config$generation_gap # expand/contract generations
  }

  # -----
  # STEP 5: Compute Relationship Connections
  # -----

  # Generate a connection table for plotting lines (parents, spouses, etc.)
  connections <- calculateConnections(ds, config = config)

  # -----
  # STEP 6: Initialize Plot
  # -----
  gap_off <- 0.5 * config$generation_gap # single constant for all “stub” offsets

  p <- ggplot2::ggplot(ds, ggplot2::aes(
    x = .data$x_pos,
    y = .data$y_pos
  ))


  # -----
  # STEP 7: Add Segments
  # -----

  # Self-segment (for duplicate layout appearances of same person)
  if ("x_otherself" %in% names(connections)) {
    p <- p + ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_otherself,
        xend = .data$x_pos,
        y = .data$y_otherself,
        yend = .data$y_pos
      ),
      linewidth = config$line_width,
      color = config$self_segment_color,
      na.rm = TRUE
    )
  }
  # Spouse link between two parents
  p <- p +
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
    # Parent-child stub (child to mid-sibling point)
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
    # Mid-sibling to parents midpoint
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
    # Sibling vertical drop line
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



  # -----
  # STEP 8: Add Points (nodes)
  # -----

  # Add point layers for each individual in the pedigree.
  # The appearance (color and shape) depends on two factors:
  # 1. Whether `sex_color` is enabled — this controls whether sex is encoded via both color and shape.
  # 2. Whether `status_col` is specified — this controls whether affected status is visualized.

  # There are three main rendering branches:
  #   1. If sex_color == TRUE: color and shape reflect sex, and affected status is shown with a second symbol.
  #   2. If sex_color == FALSE but status_col is present: shape reflects sex, and color reflects affected status.
  #   3. If neither is used: plot individuals using shape alone.

  if (config$sex_color == TRUE) {
    # Use color and shape to represent sex
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(.data$sex),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
    # If affected status is present, overlay an additional marker using alpha aesthetic
    if (!is.null(status_col)) {
      p <- p + ggplot2::geom_point(
        ggplot2::aes(alpha = !!rlang::sym(status_col)),
        shape = config$affected_shape,
        size = config$point_size,
        na.rm = TRUE
      )
    }
  } else if (!is.null(status_col)) {
    # If status_col is present but sex_color is FALSE,
    # use shape for sex and color for affected status
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(!!rlang::sym(status_col)),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  } else {
    # If neither sex color nor status_col is active,
    # plot using shape (sex) only
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  }


  # -----
  # STEP 9: Add Labels
  # -----
  # Add labels to the points using ggrepel for better visibility
  p <- p +
    ggrepel::geom_text_repel(ggplot2::aes(label = .data$personID),
      nudge_y = -.15 * config$generation_gap,
      size = config$text_size,
      na.rm = TRUE,
      max.overlaps = config$max_overlaps,
      segment.size = config$line_width * .5,
      segment.color = config$id_segment_color,
    )

  # -----
  # STEP 10: Scales, Theme
  # -----

  p <- p +
    ggplot2::scale_y_reverse() +
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
    )


  # -----
  # STEP 11: Final Legend Adjustments
  # -----
  # Adjust legend labels and colors based on the configuration
  p <- p + ggplot2::scale_shape_manual(
    values = config$shape_vals,
    labels = config$shape_labs
  )

  # Add alpha scale for affected status if applicable
  if (!is.null(status_col) && config$sex_color == TRUE) {
    p <- p + ggplot2::scale_alpha_manual(
      name = NULL,
      labels = config$status_labs,
      values = config$status_vals,
      na.translate = FALSE
    ) + ggplot2::guides(alpha = "none")
  }

  # Add color scale for sex or affected status if applicable
  if (config$sex_color == TRUE) {
    p <- p +
      ggplot2::scale_color_discrete(labels = config$shape_labs) +
      ggplot2::labs(color = "Sex", shape = "Sex")
  } else if (!is.null(status_col)) {
    p <- p +
      ggplot2::scale_color_discrete(labels = config$status_labs) +
      ggplot2::labs(color = "Affected", shape = "Sex")
  } else {
    p <- p + ggplot2::labs(shape = "Sex")
  }

  return(p)
}


#' @rdname ggPedigree
#' @export
ggpedigree <- ggPedigree

#' @rdname ggPedigree
#' @export
ggped <- ggPedigree
