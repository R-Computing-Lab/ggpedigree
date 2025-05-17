#' Plot a relatedness matrix as a heatmap (ggpedigree style)
#'
#' Plots a relatedness matrix using ggplot2 with config options.
#'
#' @param mat A square numeric matrix of relatedness values (precomputed, e.g., from ped2add).
#' @param config A list of graphical and display parameters.
#'   See Details for available options.
#' @param ... Additional arguments passed to ggplot2 layers.
#'
#' @details
#' Config options include:
#' \itemize{
#'   \item{\code{color_palette}}{A vector of colors for the heatmap (default: Reds scale)}
#'   \item{\code{scale_midpoint}}{Numeric midpoint for diverging color scale (default: 0.25)}
#'   \item{\code{title}}{Plot title}
#'   \item{\code{cluster}}{Logical; should rows/cols be clustered (default: TRUE)}
#'   \item{\code{xlab}, \code{ylab}}{Axis labels}
#'   \item{\code{text_size}}{Axis text size}
#' }
#' @return A ggplot object displaying the relatedness matrix as a heatmap.
#' @export


ggRelatednessMatrix <- function(
    mat,
    config = list(),
    ...
) {
  stopifnot(is.matrix(mat))
  default_config <- list(
    color_palette = c("white", "gold", "red"),
    scale_midpoint = 0.25,
    cluster = TRUE,
    title = "Relatedness Matrix",
    xlab = "Individual",
    ylab = "Individual",
    text_size = 8
  )

  config <- utils::modifyList(default_config, config)
  mat_plot <- mat

  # Optionally cluster
  mat_plot <- mat
  if (isTRUE(config$cluster)) {
    hc <- hclust(as.dist(1 - mat))
    ord <- hc$order
    mat_plot <- mat[ord, ord, drop=FALSE]
  }


  df <- reshape2::melt(mat_plot)
  colnames(df) <- c("Var1", "Var2", "value")
  df$Var1 <- factor(df$Var1, levels = unique(df$Var1))
  df$Var2 <- factor(df$Var2, levels = unique(df$Var2))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = Var2, y = Var1, fill = value)) +
    ggplot2::geom_raster(interpolate = TRUE,hjust = 0, vjust = 0) +
    ggplot2::scale_fill_gradient2(
      low = config$color_palette[1],
      mid = config$color_palette[2],
      high = config$color_palette[3],
      midpoint = config$scale_midpoint
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1, size = config$text_size),
      axis.text.y = ggplot2::element_text(size = config$text_size)
    ) +
    ggplot2::labs(
      x = config$xlab,
      y = config$ylab,
      fill = "Relatedness",
      title = config$title
    ) +
    ggplot2::coord_fixed()
  return(p)
}

