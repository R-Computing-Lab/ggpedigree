#' Plot a relatedness matrix as a heatmap (ggpedigree style)
#'
#' Plots a relatedness matrix using ggplot2 with config options.
#'
#' @param mat A square numeric matrix of relatedness values (precomputed, e.g., from ped2add).
#' @param config A list of graphical and display parameters.
#'   See Details for available options.
#' @param interactive Logical; if TRUE, returns an interactive plotly object.
#' @param tooltip_columns A character vector of column names to include in tooltips.
#' @param ... Additional arguments passed to ggplot2 layers.
#'
#' @details
#' Config options include:
#'  \describe{
#'   \item{color_palette}{A vector of colors for the heatmap (default: Reds scale)}
#'   \item{scale_midpoint}{Numeric midpoint for diverging color scale (default: 0.25)}
#'   \item{title}{Plot title}
#'   \item{cluster}{Logical; should rows/cols be clustered (default: TRUE)}
#'   \item{xlab, ylab}{Axis labels}
#'   \item{axis_text_size}{Axis text size}
#' }
#' @return A ggplot object displaying the relatedness matrix as a heatmap.
#' @export
#' @examples
#' # Example relatedness matrix
#' set.seed(123)
#' mat <- matrix(runif(100, 0, 1), nrow = 10)
#' rownames(mat) <- paste0("ID", 1:10)
#' colnames(mat) <- paste0("ID", 1:10)
#'
#' # Plot the relatedness matrix
#' ggRelatednessMatrix(mat,
#'   config = list(
#'     color_palette = c("white", "gold", "red"),
#'     scale_midpoint = 0.5,
#'     cluster = TRUE,
#'     title = "Relatedness Matrix",
#'     xlab = "Individuals",
#'     ylab = "Individuals",
#'     axis_text_size = 8
#'   )
#' )
ggRelatednessMatrix <- function(
    mat,
    config = list(),
    interactive = FALSE,
    tooltip_columns = NULL,
    ...) {
  # Check if the input is a matrix
  if (!is.matrix(mat)) {
    stop("Input 'mat' must be a matrix.")
  }
  default_config <- list(
    color_palette = c("white", "gold", "red"),
    scale_midpoint = 0.25,
    cluster = TRUE,
    title = "Relatedness Matrix",
    xlab = "Individual",
    ylab = "Individual",
    # layout aesthetics
    layout_text_angle_x = 90, # rotate x-axis labels
    layout_text_angle_y = 0,
    axis_text_size = 8,
    layout_text_color = "black",
    # geom aesthetics
    geom = "geom_tile", # default geom for heatmap
    geom_interpolate = TRUE, # for raster
    tile_color = NA, # border color for tiles
    # diagonal
    include_diagonal = TRUE, # whether to include diagonal elements
    include_upper_triangle = FALSE, # whether to include upper triangle
    include_lower_triangle = TRUE, # whether to include lower triangle
    # tooltip aesthetics
    tooltip_include = TRUE,
    tooltip_columns = c("ID1", "ID2", "value"),
    # label aesthetics
    include_labels = FALSE,
    label_col = "value",
    label_max_overlaps = 15,
    label_method = "ggrepel", # "geom_label" or "geom_text"
    label_nudge_x = 0,
    label_nudge_y = -.10,
    label_segment_color = NA,
    label_text_angle = 0,
    label_text_size = 2,
    label_text_color = "black",
    rounding = 5,
    return_widget = FALSE
  )

  if (!is.null(tooltip_columns)) {
    config$tooltip_columns <- tooltip_columns
  }

  config <- utils::modifyList(default_config, config)

  # Core plot
  p_list <- ggRelatednessMatrix.core(
    mat = mat,
    config = config, ...
  )

  static_plot <- p_list$plot
  ped <- p_list$data

  if (interactive == TRUE) {
    # If interactive is TRUE, use plotly
    if (!requireNamespace("plotly", quietly = TRUE)) {
      stop("The 'plotly' package is required for interactive plots.")
    }
    if (config$tooltip_include) {
      ## 2. Identify data columns for tooltips ----------------------------------
      #   When ggplotly is called, it creates a single data frame that merges all
      #   layer data.  We therefore build a 'text' aesthetic ahead of time so that
      #   it survives the conversion.
      config$tooltip_columns <- intersect(config$tooltip_columns, names(ped)) # guard against typos
      if (length(config$tooltip_columns) == 0L) {
        stop("None of the specified tooltip_columns found in `ped`.")
      }

      tooltip_fmt <- function(df, tooltip_columns) {
        apply(df[tooltip_columns], 1, function(row) {
          paste(paste(tooltip_columns, row, sep = ": "), collapse = "<br>")
        })
      }
      # add tooltips to geom_point layers


      static_plot <- static_plot + ggplot2::aes(text = tooltip_fmt(
        df = ped,
        config$tooltip_columns
      ))
    }


    p <- plotly::ggplotly(static_plot, tooltip = "text")


    if (config$return_widget == TRUE) {
      return(p)
    } else {
      class(p) <- c("plotly", class(p)) # ensure proper S3 dispatch
      return(p)
    }
  } else {
    # If interactive is FALSE, return the ggplot object
    return(static_plot)
  }
}

#' @title Core Function for ggRelatednessMatrix
#' @description
#' This function is the core implementation of the ggRelatednessMatrix function.
#' It handles the data preparation, layout calculation,
#' and plotting of the pedigree diagram.
#' It is not intended to be called directly by users.
#'
#' @inheritParams ggRelatednessMatrix
#' @keywords internal

ggRelatednessMatrix.core <- function(
    mat,
    config = list(),
    ...) {
  stopifnot(is.matrix(mat))

  mat_plot <- mat

  # Optionally cluster
  if (isTRUE(config$cluster)) {
    hc <- stats::hclust(stats::as.dist(1 - mat))
    ord <- hc$order
    mat_plot <- mat[ord, ord, drop = FALSE]
  }

  # Ensure diagonal is included
  if (isFALSE(config$include_diagonal)) {
    diag(mat_plot) <- NA
  }
  # Optionally include upper/lower triangle

  if (isFALSE(config$include_upper_triangle)) {
    # note that this gets rotated, so upper triangle is actually lower triangle in the plot
    mat_plot[lower.tri(mat_plot)] <- NA
  }
  if (isFALSE(config$include_lower_triangle)) {
    # note that this gets rotated, so upper triangle is actually lower triangle in the plot
    mat_plot[upper.tri(mat_plot)] <- NA
  }

  df_melted <- reshape2::melt(mat_plot)

  colnames(df_melted) <- c("ID1", "ID2", "value")

  df_melted <- df_melted |>
    dplyr::mutate(
      ID1 = factor(.data$ID1, levels = unique(.data$ID1)),
      ID2 = factor(.data$ID2, levels = unique(.data$ID2)),
      value = round(.data$value, config$rounding)
    )

  # rotate x-axis labels
  df_melted$ID2 <- factor(df_melted$ID2, levels = rev(levels(df_melted$ID2)))

  # filter out NA values
  df_melted <- df_melted[!is.na(df_melted$value), ]


  p <- ggplot2::ggplot(
    df_melted,
    ggplot2::aes(x = .data$ID2, y = .data$ID1, fill = .data$value)
  )

  if (config$geom == "geom_tile") {
    p <- p +
      ggplot2::geom_tile(color = config$tile_color, ...)
  } else if (config$geom == "geom_raster") {
    p <- p +
      ggplot2::geom_raster(interpolate = config$geom_interpolate, hjust = 0, vjust = 0, ...)
  } else {
    stop("Unsupported geom type. Use 'geom_tile' or 'geom_raster'.")
  }
  # add text labels if requested
  if (config$include_labels) {
    p <- p +
      ggplot2::geom_text(
        ggplot2::aes(label = config$label_col),
        size = config$label_text_size,
        color = config$label_text_color
      )
  }

  p <- p +
    ggplot2::scale_fill_gradient2(
      low = config$color_palette[1],
      mid = config$color_palette[2],
      high = config$color_palette[3],
      midpoint = config$scale_midpoint
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = config$layout_text_angle_x, vjust = 0.5,
        hjust = 1, size = config$axis_text_size,
        color = config$layout_text_color
      ),
      axis.text.y = ggplot2::element_text(
        size = config$axis_text_size,
        angle = config$layout_text_angle_y,
        color = config$layout_text_color
      ),
    ) +
    ggplot2::labs(
      x = config$xlab,
      y = config$ylab,
      fill = "Relatedness",
      title = config$title
    ) +
    ggplot2::coord_fixed()

  return(
    list(
      plot = p,
      data = df_melted,
      config = config
    )
  )
}

#' @rdname ggRelatednessMatrix
#' @export
ggrelatednessmatrix <- ggRelatednessMatrix
