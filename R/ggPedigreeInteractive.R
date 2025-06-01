#' Interactive pedigree plot (Plotly wrapper around ggPedigree)
#'
#' Generates an interactive HTML widget built on top of the static ggPedigree
#' output.  All layout, styling, and connection logic are inherited from
#' ggPedigree(); this function simply augments the plot with Plotly hover,
#' zoom, and pan functionality.
#'
#' @inheritParams ggPedigree
#' @return A plotly htmlwidget (or plotly object if `return_widget = FALSE`).
#' @examples
#' library(BGmisc)
#' data("potter")
#' ggPedigreeInteractive(potter, famID = "famID", personID = "personID")
#' @export
ggPedigreeInteractive <- function(ped,
                                  famID = "famID",
                                  personID = "personID",
                                  momID = "momID",
                                  dadID = "dadID",
                                  status_column = NULL,
                                  tooltip_columns = NULL,
                                  focal_fill_column = NULL,
                                  config = list(),
                                  debug = FALSE,
                                  return_widget = TRUE,
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

  if (!is.null(tooltip_columns)) {
    config$tooltip_columns <- tooltip_columns
  }
  if (!is.null(return_widget)) {
    config$return_widget <- return_widget
  }
  if (!is.null(debug)) {
    config$debug <- debug
  }
  # Set default styling and layout parameters
  default_config <- getDefaultPlotConfig(
    function_name = "ggpedigreeinteractive",
    personID = personID
  )

  # Merge with user-specified overrides
  # This allows the user to override any of the default values
  config <- buildPlotConfig(
    default_config = default_config,
    config = config,
    function_name = "ggpedigreeinteractive"
  )
  ## 1. Build the static ggplot using the existing engine
  static_plot <- ggPedigree.core(ped,
    famID = famID,
    personID = personID,
    momID = momID,
    dadID = dadID,
    status_column = config$status_column,
    config = config,
    debug = config$debug,
    focal_fill_column = focal_fill_column,
    function_name = "ggpedigreeinteractive",
    ...
  )

  ## 2. Identify data columns for tooltips ----------------------------------
  #   When ggplotly is called, it creates a single data frame that merges all
  #   layer data.  We therefore build a 'text' aesthetic ahead of time so that
  #   it survives the conversion.
  if (personID != "personID" && personID %in% config$tooltip_columns) {
    # replace config$tooltip_columns with personID, core function renames it to "personID"
    config$tooltip_columns <- gsub(personID, "personID", config$tooltip_columns)
  }
  config$tooltip_columns <- intersect(config$tooltip_columns, names(static_plot$data)) # guard against typos

  if (length(config$tooltip_columns) == 0L) {
    stop("None of the specified tooltip_columns found in `ped`.")
  }


  ## 3. Convert ggplot → plotly ---------------------------------------------
  #   Add the tooltip text to the data frame
  if (config$tooltip_include == TRUE) {
    # add tooltips to geom_point layers
    point_layers <- which(sapply(static_plot$layers, function(l) {
      inherits(l$geom, "GeomPoint")
    }))

    if (length(point_layers) == 0L) {
      warnings("No GeomPoint layer found for tooltips.")

      static_plot <- static_plot + ggplot2::aes(text = tooltip_fmt(
        df = static_plot$data,
        config$tooltip_columns
      ))
    } else {
      #  static_ped <- static_plot$data
      for (i in point_layers) {
        static_plot$layers[[i]]$mapping <- utils::modifyList(
          static_plot$layers[[i]]$mapping,
          ggplot2::aes(text = tooltip_fmt(
            df = static_plot$data,
            tooltip_columns = config$tooltip_columns
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
  if (config$return_static == TRUE) {
    return(static_plot) # return the static plot
  } else if (config$return_widget == TRUE) {
    return(plt)
  } else {
    class(plt) <- c("plotly", class(plt)) # ensure proper S3 dispatch
    return(plt)
  }
}
#' @rdname ggPedigreeInteractive
#' @export
ggpedigreeinteractive <- ggPedigreeInteractive

#' @rdname ggPedigreeInteractive
#' @export
ggpedigreeInteractive <- ggPedigreeInteractive

#' @title Format tooltip text
#' @description
#' Format tooltip text for ggplotly
#'
#' @param df A data frame containing the data to be displayed in the tooltip.
#' @param tooltip_columns A character vector of column names to be included in the tooltip.
#' @param sep A character string containing the separator for the columns
#'
#' @return A character vector of formatted tooltip text for each row in the data frame.
#'
#' @keywords internal

tooltip_fmt <- function(df, tooltip_columns, sep = ": ") {
  apply(df[tooltip_columns], 1, function(row) {
    paste(paste(tooltip_columns, row, sep = sep), collapse = "<br>")
  })
}
