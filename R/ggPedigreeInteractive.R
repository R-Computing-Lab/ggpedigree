#' Interactive pedigree plot (Plotly wrapper around ggPedigree)
#'
#' Generates an interactive HTML widget built on top of the static ggPedigree
#' output.  All layout, styling, and connection logic are inherited from
#' ggPedigree(); this function simply augments the plot with Plotly hover,
#' zoom, and pan functionality.
#'
#' @inheritParams ggPedigree
#' @return A plotly htmlwidget (or plotly object if `return_widget = FALSE`)
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
                                  patID = "patID",
                                  matID = "matID",
                                  twinID = "twinID",
                                  spouseID = "spouseID",
                                  status_column = NULL,
                                  tooltip_columns = NULL,
                                  focal_fill_column = NULL,
                                  overlay_column = NULL,
                                  config = list(optimize_plotly = TRUE),
                                  debug = FALSE,
                                  return_widget = TRUE,
                                  hints = NULL,
                                  code_male = NULL,
                                  sexVar = "sex") {
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
    tooltip_columns <- NULL
  }
  if (!is.null(return_widget)) {
    config$return_widget <- return_widget
    return_widget <- NULL
  }
  if (!is.null(debug)) {
    config$debug <- debug
    debug <- NULL
  }
  # Set default styling and layout parameters
  default_config <- getDefaultPlotConfig(
    function_name = "ggpedigreeinteractive",
    personID = personID,
    color_theme = ifelse(is.null(config$color_theme), "color", config$color_theme)
  )

  # Merge with user-specified overrides
  # This allows the user to override any of the default values
  config <- buildPlotConfig(
    default_config = default_config,
    config = config,
    function_name = "ggpedigreeinteractive",
    pedigree_size = nrow(ped)
  )
  if (exists("code_male") && is.null(code_male) == FALSE) {
    config$code_male <- code_male
    code_male <- NULL
  }

  ## 1. Build the static ggplot using the existing engine
  static_plot <- ggPedigree.core(ped,
    famID = famID,
    personID = personID,
    momID = momID,
    dadID = dadID,
    patID = patID,
    matID = matID,
    twinID = twinID,
    spouseID = spouseID,
    status_column = config$status_column,
    overlay_column = overlay_column,
    config = config,
    debug = config$debug,
    focal_fill_column = focal_fill_column,
    function_name = "ggpedigreeinteractive",
    sexVar = sexVar
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

  #  if (config$optimize_static == TRUE) {
  #    static_plot <- optimizeStaticPedigree(static_plot, config=config)
  #  }
  # assign("DEBUG_static_plot", static_plot, envir = .GlobalEnv)

  ## 3. Convert ggplot → plotly ---------------------------------------------
  #   Add the tooltip text to the data frame
  if (config$tooltip_include == TRUE) {
    # add tooltips to geom_point layers
    point_layers <- which(vapply(static_plot$layers, FUN = function(l) {
      inherits(l$geom, "GeomPoint")
    }, FUN.VALUE = logical(1)))

    if (length(point_layers) == 0L) {
      warning("No GeomPoint layer found for tooltips.")
      static_plot <- static_plot + ggplot2::aes(text = formatTooltip(
        df = static_plot$data,
        config$tooltip_columns
      ))
    } else {
      for (i in point_layers) {
        static_plot$layers[[i]]$mapping <- utils::modifyList(
          static_plot$layers[[i]]$mapping,
          ggplot2::aes(text = formatTooltip(
            df = static_plot$data,
            tooltip_columns = config$tooltip_columns
          ))
        )
      }
    }

    if (config$optimize_plotly == TRUE) {
      static_plot <- optimizePedigree(static_plot, config = config, plot_type = "static")
    }
    plt <- tryCatch(
      plotly::ggplotly(static_plot,
        tooltip = "text",
        width   = NULL,
        height  = NULL # , originalData = !config$optimize_plotly # retain original data for hover if not optimizing
      ),
      error = function(e) {
        warning("Error in ggplotly conversion: ", e$message)
        message("Returning static ggplot object instead.")
        return(static_plot)
      }
    )
  } else {
    if (config$optimize_plotly == TRUE) {
      static_plot <- optimizePedigree(static_plot, config = config, plot_type = "static")
    }
    plt <- tryCatch(
      plotly::ggplotly(static_plot,
        tooltip = NULL,
        width = NULL,
        height = NULL,
        originalData = !config$optimize_plotly # retain original data for hover if not optimizing
      ),
      error = function(e) {
        warning("Error in ggplotly conversion: ", e$message)
        message("Returning static ggplot object instead.")
        return(static_plot)
      }
    )
  }

  #     assign("DEBUG_static_plot", static_plot, envir = .GlobalEnv)
  if (config$optimize_plotly == TRUE) {
    plt <- optimizePedigree(plt, config = config, plot_type = "plotly")
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
#' @aliases tooltip_fmt
formatTooltip <- function(df, tooltip_columns, sep = ": ") {
  apply(df[tooltip_columns], 1, function(row) {
    paste(paste(tooltip_columns, row, sep = sep), collapse = "<br>")
  })
}


#' @title Optimize Pedigree Plot
#' @description
#' Optimize a pedigree plot by rounding coordinates to reduce file size.
#' @param p A plotly or ggplot object representing the pedigree plot.
#' @param config A list of configuration parameters, including `value_rounding_digits`.
#' @param plot_type A string indicating the type of plot: "plotly" or
#'  "static". Default is "plotly".
#'  @return The optimized plot object with rounded coordinates.
#'  @keywords internal
#'  @aliases optimisePedigree

optimizePedigree <- function(p, config = list(), plot_type = c("plotly", "static")) {
  plot_type <- match.arg(plot_type)
  if (plot_type == "plotly") {
    p <- optimizePlotlyPedigree(p, config = config)
  } else if (plot_type == "static") {
    p <- optimizeStaticPedigree(p, config = config)
  } else {
    stop("plot_type must be either 'plotly' or 'static'")
  }
  p
}

#' @rdname ggPedigreeInteractive
#' @export
ggpedigreeInteractive <- ggPedigreeInteractive

#' @rdname ggPedigreeInteractive
#' @export
ggpedigreeinteractive <- ggPedigreeInteractive

#' @title Optimize Plotly Pedigree Plot
#' @description
#' Optimize a Plotly pedigree plot by rounding coordinates to reduce file size.
#' @param p A plotly object representing the pedigree plot.
#' @param config A list of configuration parameters, including `value_rounding_digits`.
#' @return The optimized plotly object with rounded coordinates.
optimizePlotlyPedigree <- function(p, config = list()) {
  # round coordinates to reduce file size
  if (!inherits(p, "plotly")) {
    stop("Input must be a plotly object.")
  }
  for (i in seq_along(p$x$data)) {
    if (!is.null(p$x$data[[i]]$x)) {
      p$x$data[[i]]$x <- round(p$x$data[[i]]$x, config$value_rounding_digits)
    }
    if (!is.null(p$x$data[[i]]$y)) {
      p$x$data[[i]]$y <- round(p$x$data[[i]]$y, config$value_rounding_digits)
    }
  }


  p
}
#' @title Optimize Static Pedigree Plot
#' @description
#' Optimize a static pedigree plot by rounding coordinates to reduce file size
#' and removing unnecessary variables from the data frame.
#' @param p A ggplot object representing the pedigree plot.
#' @param config A list of configuration parameters, including `value_rounding_digits`.
#' @param variable_drop A character vector of variable names to be removed from the data frame.
#' Default variables to drop include "parent_hash", "couple_hash", "gen",
#' "spousehint", "parent_fam", "nid", "x_order",
#' "y_order", "y_fam", "zygosity", "extra", and "x_fam".
#' @return The optimized ggplot object with rounded coordinates and reduced data frame.
#' @keywords internal
#' @aliases optimiseStaticPedigree


optimizeStaticPedigree <- function(p, config = list(), variable_drop = c(
                                     "parent_hash",
                                     "couple_hash",
                                     "gen",
                                     "spousehint",
                                     "parent_fam",
                                     "nid",
                                     "x_order",
                                     "y_order",
                                     "y_fam",
                                     "zygosity",
                                     "extra", "x_fam"
                                   )) {
  # round coordinates to reduce file size
  if (!inherits(p, "ggplot")) {
    stop("Input must be a ggplot object.")
  }
  if (!is.null(p$data$x_pos)) {
    p$data$x_pos <- round(p$data$x_pos, config$value_rounding_digits)
    p[["plot_env"]][["ds"]]$x_pos <- round(p[["plot_env"]][["ds"]][["x_pos"]], config$value_rounding_digits)
  }
  if (!is.null(p$data$y_pos)) {
    p$data$y_pos <- round(p$data$y_pos, config$value_rounding_digits)
    p[["plot_env"]][["ds"]]$y_pos <- round(p[["plot_env"]][["ds"]][["y_pos"]], config$value_rounding_digits)
  }

  if (!is.null(variable_drop)) {
    p$data <- p$data[, !(names(p$data) %in% variable_drop)]
    p[["plot_env"]][["ds"]] <- p[["plot_env"]][["ds"]][, !(names(p[["plot_env"]][["ds"]]) %in% variable_drop)]

    # Also drop from layer data if present
    # for (i in seq_along(p$layers)) {
    #    layer_data <- p[["layers"]][[i]][["data"]]
    #  if (!is.null(layer_data)) {
    #     p[["layers"]][[i]][["data"]] <- layer_data[ , !(names(layer_data) %in% variable_drop)]
    #   }
  }


  p
}
