#' Plot a custom pedigree diagram
#'
#' Generates a ggplot2-based diagram of a pedigree using custom coordinate layout,
#' calculated relationship connections, and flexible styling via `config`.
#' It processes the data using `ped2fam()`. This function
#' supports multiple families and optionally displays affected status and sex-based color/shape.
#'
#' @param ped A data frame containing the pedigree data. Needs personID, momID, and dadID columns
#' @param famID Character string specifying the column name for family IDs. Defaults to "famID".
#' @param personID Character string specifying the column name for individual IDs. Defaults to "personID".
#' @param momID Character string specifying the column name for mother IDs. Defaults to "momID".
#' @param dadID Character string specifying the column name for father IDs. Defaults to "dadID".
#' @param spouseID Character string specifying the column name for spouse IDs. Defaults to "spouseID".
#' @param matID Character string specifying the column name for maternal lines Defaults to "matID".
#' @param patID Character string specifying the column name for paternal lines Defaults to "patID".
#' @param twinID Character string specifying the column name for twin IDs. Defaults to "twinID".
#' @param status_column Character string specifying the column name for affected status. Defaults to NULL.
#' @param debug Logical. If TRUE, prints debugging information. Default: FALSE.
#' @param hints Data frame with hints for layout adjustments. Default: NULL.
#' @param interactive Logical. If TRUE, generates an interactive plot using `plotly`. Default: FALSE.
#' @param overlay_column Character string specifying the column name for overlay alpha values.
#' @param tooltip_columns Character vector of column names to show when hovering.
#'        Defaults to c("personID", "sex").  Additional columns present in `ped`
#'        can be supplied – they will be added to the Plotly tooltip text.
#'        Defaults to NULL, which uses the default tooltip columns.
#' @param return_widget Logical; if TRUE (default) returns a plotly htmlwidget.
#'        If FALSE, returns the underlying plotly object (useful for further
#'        customization before printing).
#' @param focal_fill_column Character string specifying the column name for focal fill color.
#' @param phantoms Logical. If TRUE, adds phantom parents for individuals without parents.
#' @param ... Additional arguments passed to `ggplot2` functions.
#' @param config A list of configuration options for customizing the plot.
#'        See getDefaultPlotConfig for details. The list can include:
#'  \describe{
#'     \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
#'     \item{segment_spouse_color, segment_self_color}{Character. Line colors for respective connection types.}
#'     \item{segment_sibling_color, segment_parent_color, segment_offspring_color}{Character. Line colors for respective connection types.}
#'     \item{label_text_size, point_size, segment_linewidth}{Numeric. Controls text size, point size, and line thickness.}
#'     \item{generation_height}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
#'     \item{shape_unknown, shape_female, shape_male, status_shape_affected}{Integers. Shape codes for plotting each group.}
#'     \item{sex_shape_labels}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown"))}
#'     \item{unaffected, affected}{Values indicating unaffected/affected status.}
#'     \item{sex_color_include}{Logical. If TRUE, uses color to differentiate sex.}
#'     \item{label_max_overlaps}{Maximum number of overlaps allowed in repelled labels.}
#'     \item{label_segment_color}{Color used for label connector lines.}
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
#' @import ggplot2
#' @importFrom dplyr mutate filter left_join select join_by case_when rename
#' @importFrom BGmisc ped2fam ped2paternal ped2maternal recodeSex checkParentIDs
#' @importFrom rlang sym
#' @importFrom utils modifyList
#' @aliases ggpedigree
ggPedigree <- function(ped,
                       famID = "famID",
                       personID = "personID",
                       momID = "momID",
                       dadID = "dadID",
                       spouseID = "spouseID",
                       matID = "matID",
                       patID = "patID",
                       twinID = "twinID",
                       status_column = NULL,
                       focal_fill_column = NULL,
                       tooltip_columns = NULL,
                       overlay_column = NULL,
                       return_widget = FALSE,
                       config = list(),
                       debug = FALSE,
                       hints = NULL,
                       interactive = FALSE,
                       phantoms = FALSE,
                       ...) {
  if (!inherits(ped, "data.frame")) {
    if (rlang::inherits_any(ped, c("ped", "pedigree", "kinship2.pedigree"))) {
      # Convert ped object to data.frame
      ped <- as.data.frame(ped)
    } else if (rlang::inherits_any(ped, "pedigreeList")) {
      class(ped) <- "list"
      ped <- as.data.frame(ped)
    } else {
      # If not a data.frame or compatible type, throw an error
      stop("ped should be a data.frame or inherit to a data.frame")
    }
  }
  if (!all(c(personID, dadID, momID, "sex") %in% names(ped))) {
    stop("ped must contain personID, sex, dadID, and momID columns")
  }

  if (interactive == TRUE &&
    requireNamespace("plotly", quietly = TRUE)) {
    # Call the interactive function with the provided arguments

    ggPedigreeInteractive(
      ped = ped,
      famID = famID,
      personID = personID,
      spouseID = spouseID,
      momID = momID,
      dadID = dadID,
      matID = matID,
      patID = patID,
      overlay_column = overlay_column,
      twinID = twinID,
      status_column = status_column,
      focal_fill_column = focal_fill_column,
      config = config,
      debug = debug,
      hints = hints,
      return_widget = return_widget,
      tooltip_columns = tooltip_columns,
      phantoms = phantoms,
      ...
    )
  } else {
    if (interactive == TRUE &&
      !requireNamespace("plotly", quietly = TRUE)) {
      message("The 'plotly' package is required for interactive plots.")
    }

    # Set default styling and layout parameters
    default_config <- getDefaultPlotConfig(function_name = "ggpedigree", personID = personID)

    # Merge with user-specified overrides
    # This allows the user to override any of the default values
    config <- buildPlotConfig(
      default_config = default_config,
      config = config,
      function_name = "ggpedigree",
      pedigree_size = nrow(ped)
    )
    # Call the core function with the provided arguments
    ggPedigree.core(
      ped = ped,
      famID = famID,
      personID = personID,
      spouseID = spouseID,
      momID = momID,
      dadID = dadID,
      matID = matID,
      patID = patID,
      overlay_column = overlay_column,
      twinID = twinID,
      status_column = status_column,
      focal_fill_column = focal_fill_column,
      config = config,
      debug = debug,
      hints = hints,
      phantoms = phantoms,
      ...
    )
  }
}

#' @rdname ggPedigree
#' @export
ggpedigree <- ggPedigree
