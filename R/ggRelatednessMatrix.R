#' Plot a relatedness matrix as a heatmap (ggpedigree style)
#'
#' Plots a relatedness matrix using ggplot2 with config options.
#'
#' @param mat A square numeric matrix of relatedness values (precomputed, e.g., from ped2add).
#' @param config A list of graphical and display parameters.
#'   See Details for available options.
#' @param interactive Logical; if TRUE, returns an interactive plotly object.
#' @param tooltip_cols A character vector of column names to include in tooltips.
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
#'   \item{text_size}{Axis text size}
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
#'     text_size = 8
#'   )
#' )
ggRelatednessMatrix <- function(
    mat,
    config = list(),
    interactive = FALSE,
    tooltip_cols = NULL,
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
    text_size = 8,
    include_tooltips = TRUE,
    tooltip_cols = c("ID1", "ID2", "value"),
    rounding = 5
  )

  if (!is.null(tooltip_cols)) {
    config$tooltip_cols <- tooltip_cols
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
    if (config$include_tooltips) {
      ## 2. Identify data columns for tooltips ----------------------------------
      #   When ggplotly is called, it creates a single data frame that merges all
      #   layer data.  We therefore build a 'text' aesthetic ahead of time so that
      #   it survives the conversion.
      config$tooltip_cols <- intersect(config$tooltip_cols, names(ped)) # guard against typos
      if (length(config$tooltip_cols) == 0L) {
        stop("None of the specified tooltip_cols found in `ped`.")
      }

      tooltip_fmt <- function(df, tooltip_cols) {
        apply(df[tooltip_cols], 1, function(row) {
          paste(paste(tooltip_cols, row, sep = ": "), collapse = "<br>")
        })
      }
      # add tooltips to geom_point layers


      static_plot <- static_plot + ggplot2::aes(text = tooltip_fmt(
        df = ped,
        config$tooltip_cols
      ))
    }


    p <- plotly::ggplotly(static_plot, tooltip = "text")


    if (config$as_widget == TRUE) {
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

  p <- ggplot2::ggplot(
    df_melted,
    ggplot2::aes(x = .data$ID2, y = .data$ID1, fill = .data$value)
  ) +
    ggplot2::geom_raster(interpolate = TRUE, hjust = 0, vjust = 0) +
    ggplot2::scale_fill_gradient2(
      low = config$color_palette[1],
      mid = config$color_palette[2],
      high = config$color_palette[3],
      midpoint = config$scale_midpoint
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = 90, vjust = 0.5,
        hjust = 1, size = config$text_size
      ),
      axis.text.y = ggplot2::element_text(size = config$text_size)
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
