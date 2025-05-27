utils::globalVariables(c(".x"))
#' Plot correlation of genetic relatedness by phenotype
#'
#' This function plots the phenotypic correlation as a function of genetic relatedness.
#'
#' @param df Data frame containing pairwise summary statistics. Required columns:
#'  \describe{
#'     \item{addRel_min}{Minimum relatedness per group}
#'     \item{addRel_max}{Maximum relatedness per group}
#'     \item{n_pairs}{Number of pairs at that relatedness}
#'     \item{cnu}{Indicator for shared nuclear environment (1 = yes, 0 = no)}
#'     \item{mtdna}{Indicator for shared mitochondrial DNA (1 = yes, 0 = no)}
#'   }
#' @param y_var Name of the y-axis variable column (e.g., "r_pheno_rho").
#' @param y_se Name of the standard error column (e.g., "r_pheno_se").
#' @param y_stem_se Optional; base stem used to construct SE ribbon bounds. (e.g., "r_pheno")
#'  @param data_prep Logical; if TRUE, performs data preparation steps.
#'  @param ... Additional arguments passed to `ggplot2` functions.
#' @param config A list of configuration overrides. Valid entries include:
#'  \describe{
#'     \item{filter_n_pairs}{Minimum number of pairs to include (default: 500)}
#'     \item{filter_degree_min}{Minimum degree of relatedness (default: 0)}
#'     \item{filter_degree_max}{Maximum degree of relatedness (default: 7)}
#'     \item{title}{Plot title}
#'     \item{subtitle}{Plot subtitle}
#'     \item{color_scale}{Paletteer color scale name (e.g., "ggthemes::calc")}
#'     \item{only_classic_kin}{If TRUE, only classic kin are shown}
#'     \item{kin_grouping}{If TRUE, use classic kin × mtDNA for grouping}
#'     \item{drop_classic_kin}{If TRUE, remove classic kin rows}
#'     \item{drop_non_classic_sibs}{If TRUE, remove non-classic sibs (default: TRUE)}
#'     \item{annotate}{If TRUE, annotate mother/father/sibling points}
#'     \item{annotate_xshift}{Relative x-axis shift for annotations}
#'     \item{annotate_yshift}{Relative y-axis shift for annotations}
#'     \item{point_size}{Size of geom_point points (default: 1)}
#'     \item{degree_rel}{If TRUE, x-axis uses degree-of-relatedness scaling}
#'     \item{grouping}{Grouping column name (default: mtdna_factor)}
#'     \item{rounding}{Number of decimal places for rounding (default: 2)}
#'     \item{threshold}{Tolerance \% for matching known degrees}
#'     \item{max_degrees}{Maximum number of degrees to consider}
#'     }
#'  @return A ggplot object containing the correlation plot.
#'
#' @export

ggPhenotypeByDegree <- function(df,
                                y_var,
                                y_se = NULL,
                                y_stem_se = NULL,
                                config = list(),
                                data_prep = TRUE,
                                ...) {
  # ---- Early checks on input ----

  if (!is.data.frame(df)) {
    stop("Input `df` must be a data frame.")
  }
  if (is.null(y_stem_se) && is.null(y_se)) {
    stop("Must provide either `y_se` or `y_stem_se`.")
  }
  if (!is.null(y_stem_se) && is.null(y_se)) {
    y_se <- paste0(sub("_se$", "", y_stem_se), "_se")
  }
  if (!is.null(y_se) && is.null(y_stem_se)) {
    y_stem_se <- sub("_se$", "", y_se)
  }


  # Set default styling and layout parameters
  default_config <- list(
    apply_default_scales = TRUE,
    apply_default_theme = TRUE,
    point_size = 1,
    filter_n_pairs = 500,
    filter_degree_min = 0,
    filter_degree_max = 7,
    title = "Phenotypic Correlation vs Genetic Relatedness",
    subtitle = NULL,
    color_scale = "ggthemes::calc",
    only_classic_kin = TRUE,
    kin_grouping = FALSE,
    drop_classic_kin = FALSE,
    drop_non_classic_sibs = TRUE,
    annotate = TRUE,
    annotate_xshift = -0.1,
    annotate_yshift = 0.005,
    degree_rel = TRUE,
    grouping = "mtdna_factor",
    rounding = 2,
    threshold = 10,
    max_degrees = 12
  )

  # Merge user config with defaults
  config <- utils::modifyList(default_config, config)

  # ----- Data preparation -----
  if (data_prep == TRUE) {
    df <- .preparePhenotypeByDegreeData(
      df = df,
      y_var = y_var,
      y_se = y_se,
      y_stem_se = y_stem_se,
      config = config
    )
  }

  # ---- Core plotting ----
  ggPhenotypeByDegree.core(
    df = df,
    y_var = y_var,
    y_se = y_se,
    y_stem_se = y_stem_se,
    config = config,
    ...
  )
}

#' Core plotting function for ggPhenotypeByDegree
#' This function generates the core ggplot object based on the prepared data frame.
#' @inheritParams ggPhenotypeByDegree
#' @return A ggplot object containing the correlation plot.
#' @keywords internal

ggPhenotypeByDegree.core <- function(df,
                                     y_var,
                                     y_se,
                                     y_stem_se,
                                     config,
                                     ...) {
  # Dynamically create ymin and ymax variable names
  y_var_sym <- sym(y_var)
  ymin_var <- sym(paste0(y_stem_se, "_minusse"))
  ymax_var <- sym(paste0(y_stem_se, "_plusse"))
  grouping_sym <- sym(config$grouping)

  # ---- Prepare annotations plotting ----
  # Extract specific y-values based on provided positions, using dynamic column names

  if (config$annotate == TRUE) {
    config$annotation_coords <- list(x_sib = 0.5, x_mom = 0.5, x_dad = 0.5)
    y_val_coord <- function(filter_expr) {
      df |>
        dplyr::filter(!!rlang::parse_expr(filter_expr)) |>
        dplyr::pull(!!y_var_sym) |>
        as.numeric()
    }
    config$annotation_coords$y_sib <- y_val_coord(".data$cnu == 1 & .data$addRel_center == 0.5")
    config$annotation_coords$y_mom <- y_val_coord(".data$cnu == 0 & .data$mtdna == 1 & .data$addRel_center == 0.5")
    config$annotation_coords$y_dad <- y_val_coord(".data$cnu == 0 & .data$mtdna == 0 & .data$addRel_center == 0.5")
    config$annotation_coords$annotation_mom_x <- config$annotation_coords$x_mom + config$annotate_xshift * config$annotation_coords$x_mom
    config$annotation_coords$annotation_sib_x <- config$annotation_coords$x_sib + config$annotate_xshift * config$annotation_coords$x_sib
    config$annotation_coords$annotation_dad_x <- config$annotation_coords$x_dad + config$annotate_xshift * config$annotation_coords$x_dad
    config$annotation_coords$annotation_sib_y <- config$annotation_coords$y_sib + config$annotate_yshift * config$annotation_coords$y_sib
    config$annotation_coords$annotation_mom_y <- config$annotation_coords$y_mom + config$annotate_yshift * config$annotation_coords$y_mom
    config$annotation_coords$annotation_dad_y <- config$annotation_coords$y_dad + config$annotate_yshift * config$annotation_coords$y_dad
    config$annotation_coords$df_point <- df |> dplyr::filter(.data$cnu == 1, .data$addRel_center == .5)
  } else {
    config$annotation_coords <- NULL
  }


  # drop rows based on filter conditions
  df <- df |>
    tidyr::drop_na(!!y_var_sym) |>
    mutate(classic_kin_factor = factor(paste0(classic_kin, mtdna))) |>
    dplyr::filter(.data$n_pairs > config$filter_n_pairs & .data$addRel_center < 1 & .data$degree_relative < config$filter_degree_max & degree_relative > config$filter_degree_min)

  # drop weird sibs
  if (config$drop_non_classic_sibs == TRUE) {
    df <- df |>
      mutate(drop = case_when(
        .data$mtdna == 1 & .data$classic_kin == 0 & .data$cnu == 1 ~ 1,
        TRUE ~ 0
      )) |>
      dplyr::filter(.data$drop != 1) |>
      select(-"drop")
  }
  # if only_classic_kin is TRUE, filter out non-classic kinship
  if (config$only_classic_kin == TRUE) {
    df <- df |> dplyr::filter(.data$classic_kin == 1)
  } else if (config$drop_classic_kin == TRUE) {
    df <- df |> dplyr::filter(.data$classic_kin == 0)
  }

  # make plot
  core_plot <- df |>
    ggplot2::ggplot(ggplot2::aes(
      x = .data$addRel_center,
      y = !!y_var_sym,
      group = !!grouping_sym,
      color = !!grouping_sym,
      shape = !!grouping_sym
    ))

  if (config$only_classic_kin == TRUE | config$kin_grouping == TRUE) {
    core_plot <- core_plot +
      ggplot2::geom_ribbon(
        ggplot2::aes(
          ymin = !!ymin_var,
          ymax = !!ymax_var, fill = !!grouping_sym
        ),
        alpha = .3, linetype = 0
      ) + # , stat = "smooth", method = "loess") +
      ggplot2::geom_line(ggplot2::aes(linetype = !!grouping_sym))
  } else {
    core_plot <- core_plot +
      ggplot2::geom_ribbon(
        ggplot2::aes(
          ymin = !!ymin_var,
          ymax = !!ymax_var,
          fill = .data$classic_kin_factor,
          color = .data$classic_kin_factor,
          group = .data$classic_kin_factor
        ),
        stat = "smooth", span = .02,
        outline.type = "upper", method = "lm", # group = df$classic_kin,
        alpha = .3, linetype = 0,
        show.legend = FALSE
      ) +
      ggplot2::geom_line(ggplot2::aes(
        group = !!grouping_sym,
        color = !!grouping_sym
      ), linetype = "solid")
  }

  core_plot <- core_plot +
    ggplot2::geom_point(size = config$point_size)

  # annotate if and only if
  if (config$annotate == TRUE && config$filter_degree_min == 0) {
    core_plot <- .addAnnotate(
      p = core_plot,
      config = config,
      y_var_sym = y_var_sym
    )
  }
  # naming

  if (config$grouping == "mtdna_factor") {
    config$grouping_name <- "mtDNA"
  } else {
    config$grouping_name <- paste0(config$grouping)
  }

  if (config$apply_default_theme == TRUE) {
    core_plot <- core_plot +
      ggplot2::theme(axis.text.x = element_text(size = 12, angle = -65, hjust = 0)) +
      ggplot2::theme_bw() +
      ggplot2::theme(legend.position = "top") # scale_x_reverse() +
  }

  if (config$degree_rel) {
    core_plot <- core_plot + scale_x_continuous(
      trans = scales::compose_trans("log2", "reverse"),
      breaks = scales::trans_breaks("log2", function(x) 2^x),
      labels = scales::trans_format("log2", scales::label_math(.5^.x, format = abs))
    ) +
      labs(
        x = "Degree of Relatedness", y = "Correlation",
        title = config$title,
        subtitle = config$subtitle, color = paste0(config$grouping_name),
        shape = paste0(config$grouping_name),
        linetype = paste0(config$grouping_name),
        group = paste0(config$grouping_name),
        fill = paste0(config$grouping_name)
      )
  } else {
    core_plot <- core_plot + scale_x_continuous(
      trans = scales::compose_trans("log2", "reverse"),
      breaks = scales::trans_breaks("log2", function(x) 2^x),
      labels = scales::label_parse()
    ) +
      labs(
        x = "Coefficient of Genetic Variation",
        y = "Correlation", title = config$title,
        subtitle = config$subtitle,
        color = paste0(config$grouping_name),
        shape = paste0(config$grouping_name),
        linetype = paste0(config$grouping_name),
        group = paste0(config$grouping_name),
        fill = paste0(config$grouping_name)
      )
  }
  if (config$apply_default_scale == TRUE && !is.null(config$color_scale) && requireNamespace("paletteer", quietly = TRUE)
  ) {
    core_plot <- core_plot +
      paletteer::scale_color_paletteer_d(config$color_scale) +
      paletteer::scale_fill_paletteer_d(config$color_scale)
  } else if (config$apply_default_scale == TRUE) {
    core_plot <- core_plot + ggplot2::scale_color_brewer(palette = "Set1") +
      ggplot2::scale_fill_brewer(palette = "Set1")
  }
  return(core_plot)
}

#' Prepare data for ggPhenotypeByDegree
#' This function prepares the data frame for plotting by calculating necessary columns and ensuring required columns are present.
#'
#' @inheritParams ggPhenotypeByDegree
#' @return A modified data frame with additional columns for plotting.
#' @keywords internal
#'
.preparePhenotypeByDegreeData <- function(df,
                                          y_var,
                                          y_se = NULL,
                                          y_stem_se = NULL,
                                          config = list()) {
  required_cols <- c("addRel_min", "addRel_max", "n_pairs", "cnu", "mtdna")
  if (!all(required_cols %in% names(df))) {
    stop(paste("Data frame must contain the following columns:", paste(required_cols, collapse = ", ")))
  }

  if (!"addRel_center" %in% names(df)) {
    df <- df |>
      mutate(addRel_center = (.data$addRel_max + .data$addRel_min) / 2) # Centering the addRel values
  }
  if (!"classic_kin" %in% names(df)) {
    df <- df |>
      mutate(
        classic_kin =
          case_when(
            .data$addRel_max %in% (2^(0:(-config$max_degrees)) * (1 + config$threshold / 100)) ~ 1,
            .data$addRel_max == 0 ~ 1,
            TRUE ~ 0
          )
      )
  }
  if (!"degree_relative" %in% names(df)) {
    df <- df |>
      mutate(
        degree_relative = # solve for as a function of addRel_max
          case_when(
            .data$addRel_max >= (1 + config$threshold / 100) ~ 0,
            .data$addRel_max < 1 ~ log2(1 / (.data$addRel_max) * (1 + config$threshold / 100))
          )
      )
  }

  if (!paste0(y_stem_se, "_minusse") %in% names(df)) {
    df <- df |>
      mutate(!!sym(paste0(y_stem_se, "_minusse")) :=
        .data[[y_se]] - 1.96 * (.data[[y_se]] / sqrt(.data$n_pairs)))
  }
  if (!paste0(y_stem_se, "_plusse") %in% names(df)) {
    df <- df |>
      mutate(!!sym(paste0(y_stem_se, "_plusse")) :=
        .data[[y_se]] + 1.96 * (.data[[y_se]] / sqrt(.data$n_pairs)))
  }
  if (!"mtdna_factor" %in% names(df)) {
    df <- df |>
      mutate(mtdna_factor = factor(.data$mtdna, levels = c(0, 1)))
  }
  return(df)
}

#' @title Add annotates to ggplot Pedigree Plot
#' @inheritParams ggPhenotypeByDegree
#'
#' @return A ggplot object with added labels.
#' @keywords internal
#'
.addAnnotate <- function(p, config, y_var_sym) {
  # the specifics
  if (config$drop_classic_kin == FALSE) {
    p <- p +
      geom_point(data = config$annotation_coords$df_point, aes(x = .data$addRel_center, y = !!y_var_sym), size = config$point_size) + # Add the single point
      annotate("text",
        x = config$annotation_coords$annotation_sib_x, y = config$annotation_coords$annotation_sib_y, label = "Sibling Correlation",
        hjust = 0, vjust = 0, color = "black", size = 4
      ) +
      annotate("text",
        x = config$annotation_coords$annotation_mom_x, y = config$annotation_coords$annotation_mom_y, label = "Mother-child Correlation",
        hjust = 0, vjust = -0, color = "black", size = 4
      ) +
      annotate("text",
        x = config$annotation_coords$annotation_dad_x,
        y = config$annotation_coords$annotation_dad_y,
        label = "Father-child Correlation",
        hjust = 0, vjust = -0, color = "black", size = 4
      )
  } else if (config$drop_classic_kin == TRUE) {
    p <- p +
      geom_point(data = config$annotation_coords$df_point, aes(x = x_value_sib, y = y_value_sib), size = config$point_size) + # Add the single point
      annotate("text",
        x = config$annotation_coords$annotation_sib_x,
        y = config$annotation_coords$annotation_sib_y,
        label = "Sibling Correlation",
        hjust = 0, vjust = -0, color = "black", size = 4
      )
  }
  return(p)
}
