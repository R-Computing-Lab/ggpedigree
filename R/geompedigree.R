#' GeomPedigree ggproto object
#'
#' This encapsulates all the segment, point, overlay, and label drawing logic
#' from `ggPedigree.core()` into a reusable ggproto-based Geom.
#'
#' Used internally by `ggPedigree()` only. Not exported.
#'
GeomPedigree <- ggplot2::ggproto("GeomPedigree", ggplot2::Geom,
                                 required_aes = c("x", "y"),

                                 draw_panel = function(data, panel_params, coord,
                                                       config, connections,
                                                       focal_fill_column = NULL,
                                                       status_column = NULL,
                                                       overlay_column = NULL,
                                                       plot_connections = NULL) {

                                   grobs <- list()

                                   # 1. Spouse segments
                                   grobs[["spouse"]] <- ggplot2::GeomSegment$draw_panel(
                                     data = connections |> dplyr::rename(
                                       x = x_spouse, y = y_spouse, xend = x_pos, yend = y_pos
                                     ) |>
                                       dplyr::mutate(
                                         linewidth = config$segment_linewidth,
                                         linetype  = config$segment_linetype,
                                         colour    = config$segment_spouse_color,
                                         lineend   = config$segment_lineend,
                                         linejoin  = config$segment_linejoin,
                                         alpha    = config$segment_alpha
                                       ),
                                     panel_params = panel_params,
                                     coord = coord,
                                     na.rm = TRUE
                                   )

                                   # 2. Parent-child segments
                                   parent_child_segments <- list(
                                     ggplot2::GeomSegment$draw_panel(
                                       data = connections |> dplyr::rename(
                                         x = x_mid_sib, y = y_mid_sib, xend = x_fam, yend = y_fam
                                       ) |> dplyr::mutate(y = y - config$gap_hoff,
                                           linewidth = config$segment_linewidth,
                                           linetype  = config$segment_linetype,
                                           colour    = config$segment_parent_color,
                                           lineend   = config$segment_lineend,
                                           linejoin  = config$segment_linejoin,
                                           alpha    = config$segment_alpha
                                         ),
                                       panel_params = panel_params, coord = coord,
                                       na.rm = TRUE
                                     ),
                                     ggplot2::GeomSegment$draw_panel(
                                       data = connections |> #dplyr::filter(link_as_twin == FALSE) |>
                                         dplyr::rename(
                                         x = x_pos, xend = x_mid_sib,
                                         y = y_pos, yend = y_mid_sib
                                       ) |> dplyr::mutate(y = y - config$gap_hoff,
                                                          yend = yend - config$gap_hoff,
                                                              linewidth = config$segment_linewidth,
                                                              linetype  = config$segment_linetype,
                                                              colour    = config$segment_offspring_color,
                                                              lineend   = config$segment_lineend,
                                                              linejoin  = config$segment_linejoin,
                                                          alpha    = config$segment_alpha
                                                            ),
                                       panel_params = panel_params, coord = coord,
                                       na.rm = TRUE
                                     ),
                                     ggplot2::GeomSegment$draw_panel(
                                       data = connections |> #dplyr::filter(link_as_twin == FALSE) |>
                                         dplyr::rename(
                                         x = x_pos, xend = x_pos,
                                         y = y_mid_sib, yend = y_pos
                                       ) |> dplyr::mutate(y = y - config$gap_hoff,
                                                          linewidth = config$segment_linewidth,
                                                          linetype  = config$segment_linetype,
                                                          colour    = config$segment_sibling_color,
                                                          lineend   = config$segment_lineend,
                                                          linejoin  = config$segment_linejoin,
                                                          alpha    = config$segment_alpha),
                                       panel_params = panel_params, coord = coord,
                                       na.rm = TRUE
                                     )
                                   )
                                 #  grobs[["parent"]] <- grid::grobTree(grobs = parent_child_segments)
                                   # 3. Node points
                                   # 3. Nodes (basic shape only)
                                   # node_data <- connections |>
                                   #   dplyr::mutate(
                                   #     shape = as.factor(.data$sex),
                                   #     size = config$point_size,
                                   #     stroke = config$segment_linewidth,
                                   #     colour = "black",
                                   #     fill = NA,
                                   #     alpha = 1
                                   #   )
                                   #
                                   # grobs[["nodes"]] <- ggplot2::GeomPoint$draw_panel(
                                   #   data = node_data,
                                   #   panel_params = panel_params,
                                   #   coord = coord,
                                   #   na.rm = TRUE
                                   # )

                                   # Combine and return all grobs
                                   grid::grobTree(grobs = grobs)

                                 }
)
