#' Interactive pedigree plot (Plotly wrapper around ggPedigree)
#'
#' Generates an interactive HTML widget built on top of the static ggPedigree
#' output.  All layout, styling, and connection logic are inherited from
#' ggPedigree(); this function simply augments the plot with Plotly hover,
#' zoom, and pan functionality.
#'
#' @inheritParams ggPedigree
#' @param tooltip_cols Character vector of column names to show when hovering.
#'        Defaults to c("personID", "sex").  Additional columns present in `ped`
#'        can be supplied – they will be added to the Plotly tooltip text.
#' @param as_widget Logical; if TRUE (default) returns a plotly htmlwidget.
#'        If FALSE, returns the underlying plotly object (useful for further
#'        customisation before printing).
#' @return A plotly htmlwidget (or plotly object if `as_widget = FALSE`).
#' @examples
#' library(BGmisc)
#' data("potter")
#' ggPedigreeInteractive(potter, famID = "famID", personID = "personID")
#' @export
ggPedigreeInteractive <- function(ped, famID = "famID",
                                  personID = "personID",
                                  momID = "momID",
                                  dadID = "dadID",
                                  status_col = NULL,
                                  tooltip_cols = NULL,
                                  config = list(),
                                  debug = FALSE,
                                  as_widget = TRUE,
                                  ...) {



  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }
  if ("label_method" %in% names(config)) {
    #
    if (config$label_method == "geom_text_repel") {
      message("geom_GeomTextRepel() has yet to be implemented in plotly")
    } else if (config$label_method == "geom_label") {
      message("geom_GeomLabel() has yet to be implemented in plotly")
    }
 #   if (!config$label_method %in% c("geom_label", "geom_text")) {
  #    stop("label_method must be either 'geom_label' or 'geom_text'")
 #   }
  }
  # -----
  # STEP 1: Configuration and Preparation
  # -----
  if(!is.null(tooltip_cols)) {
  config$tooltip_cols <- tooltip_cols
  }
  # Set default styling and layout parameters
  default_config <- list(
    label_method = "geom_text",
    include_labels = TRUE, # default to FALSE
    tooltip_cols = c(personID, "sex", status_col),
    return_static = FALSE
  )
  config <- utils::modifyList(default_config, config)

  ## 1. Build the static ggplot using the existing engine
  static_plot <- ggPedigree(ped,
                            famID       = famID,
                            personID    = personID,
                            momID       = momID,
                            dadID       = dadID,
                            status_col  = status_col,
                            config      = config,
                            debug       = debug,
                            ...)

  ## 2. Identify data columns for tooltips ----------------------------------
  #   When ggplotly is called, it creates a single data frame that merges all
  #   layer data.  We therefore build a 'text' aesthetic ahead of time so that
  #   it survives the conversion.
  config$tooltip_cols <- intersect(config$tooltip_cols, names(ped))  # guard against typos
  if (length(config$tooltip_cols) == 0L)
    stop("None of the specified tooltip_cols found in `ped`.")

  tooltip_fmt <- function(df, tooltip_cols) {
    apply(df[tooltip_cols], 1, function(row)
      paste(paste(tooltip_cols, row, sep = ": "), collapse = "<br>"))
  }

  static_plot <- static_plot +
    ggplot2::aes(text = tooltip_fmt(ped, config$tooltip_cols))

  ## 3. Convert ggplot → plotly ---------------------------------------------
  if (config$return_static == TRUE) {
  return(static_plot)
    } else {
  plt <- plotly::ggplotly(static_plot,
                          tooltip = "text",
                          width   = NULL,
                          height  = NULL)


  }


  if (as_widget==TRUE) {
    return(plt)
  } else {
    class(plt) <- c("plotly", class(plt))  # ensure proper S3 dispatch
    return(plt)
  }
}
