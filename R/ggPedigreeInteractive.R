#' Interactive pedigree plot (Plotly wrapper around ggPedigree)
#'
#' Generates an interactive HTML widget built on top of the static ggPedigree
#' output.  All layout, styling, and connection logic are inherited from
#' ggPedigree(); this function simply augments the plot with Plotly hover,
#' zoom, and pan functionality.
#'
#' @inheritParams ggPedigree
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
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("The 'plotly' package is required for interactive plots.")
  }
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
  if (!is.null(tooltip_cols)) {
    config$tooltip_cols <- tooltip_cols
  }
  # Set default styling and layout parameters
  default_config <- list(
    label_method = "geom_text",
    include_labels = FALSE, # default to FALSE
    include_tooltips = TRUE,
    tooltip_cols = c(personID, "sex", status_col),
    return_static = FALSE
  )
  config <- utils::modifyList(default_config, config)

  ## 1. Build the static ggplot using the existing engine
  static_plot <- ggPedigree.core(ped,
    famID       = famID,
    personID    = personID,
    momID       = momID,
    dadID       = dadID,
    status_col  = status_col,
    config      = config,
    debug       = debug,
    ...
  )

  ## 2. Identify data columns for tooltips ----------------------------------
  #   When ggplotly is called, it creates a single data frame that merges all
  #   layer data.  We therefore build a 'text' aesthetic ahead of time so that
  #   it survives the conversion.
if(personID != "personID" && personID %in% config$tooltip_cols) {
  # replace config$tooltip_cols with personID, core function renames it to "personID"
  config$tooltip_cols <- gsub(personID, "personID", config$tooltip_cols)
 }
  config$tooltip_cols <- intersect(config$tooltip_cols, names(static_plot$data)) # guard against typos

  if (length(config$tooltip_cols) == 0L) {
    stop("None of the specified tooltip_cols found in `ped`.")
  }
  if (config$return_static == TRUE) {
    return(static_plot) # return the static plot
  }

  ## 3. Convert ggplot → plotly ---------------------------------------------
  #   Add the tooltip text to the data frame
  if (config$include_tooltips == TRUE) {
    # add tooltips to geom_point layers
    point_layers <- which(sapply(static_plot$layers, function(l) {
      inherits(l$geom, "GeomPoint")
    }))

    if (length(point_layers) == 0L) {
      warnings("No GeomPoint layer found for tooltips.")

      static_plot <- static_plot + ggplot2::aes(text = tooltip_fmt(
        df = static_plot$data,
        config$tooltip_cols
      ))
    } else {
    #  static_ped <- static_plot$data


      for (i in point_layers) {
        static_plot$layers[[i]]$mapping <- utils::modifyList(
          static_plot$layers[[i]]$mapping,
          ggplot2::aes(text = tooltip_fmt(
            df = static_plot$data,
            tooltip_cols = config$tooltip_cols
          ))
        )
      }
    }

    plt <- plotly::ggplotly(static_plot,
      tooltip = "text",
      width   = NULL,
      height  = NULL
    )

  } else {
    plt <- plotly::ggplotly(static_plot,
      # tooltip = "text",
      width = NULL,
      height = NULL
    )
  }

if (as_widget == TRUE) {
    return(plt)
  } else {
    class(plt) <- c("plotly", class(plt)) # ensure proper S3 dispatch
    return(plt)
  }
}
#' @rdname ggPedigreeInteractive
#' @export
ggpedigreeinteractive <- ggPedigreeInteractive

#' @title Format tooltip text
#' @description
#' Format tooltip text for ggplotly
#'
#' @param df A data frame containing the data to be displayed in the tooltip.
#' @param tooltip_cols A character vector of column names to be included in the tooltip.
#'
#' @return A character vector of formatted tooltip text for each row in the data frame.
#'
#' @keywords internal

tooltip_fmt <- function(df, tooltip_cols) {
  apply(df[tooltip_cols], 1, function(row) {
    paste(paste(tooltip_cols, row, sep = ": "), collapse = "<br>")
  })
}
