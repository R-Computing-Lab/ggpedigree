#' Plot correlation of genetic relatedness by phenotype
#'
#' This function plots the phenotypic correlation as a function of genetic relatedness.
#'
#' @param df Data frame containing pairwise summary statistics. Required columns:
#'   \describe{
#'     \item{addRel_min}{Minimum relatedness per group}
#'     \item{addRel_max}{Maximum relatedness per group}
#'     \item{n_pairs}{Number of pairs at that relatedness}
#'     \item{cnu}{Indicator for shared nuclear environment (1 = yes, 0 = no)}
#'     \item{mtdna}{Indicator for shared mitochondrial DNA (1 = yes, 0 = no)}
#'   }
#' @param y_var Name of the y-axis variable column (e.g., "r_pheno_rho").
#' @param y_se Name of the standard error column (e.g., "r_pheno_se").
#' @param y_stem_se Optional; base stem used to construct SE ribbon bounds. (e.g., "r_pheno")
#' @param config A list of configuration overrides. Valid entries include:
#'   \describe{
#'     \item{filter_n_pairs} Minimum number of pairs to include (default: 500)
#'     \item{filter_degree_min} Minimum degree of relatedness (default: 0)
#'     \item{filter_degree_max} Maximum degree of relatedness (default: 7)
#'     \item{title} Plot title
#'     \item{subtitle} Plot subtitle
#'     \item{color_scale} Paletteer color scale name (e.g., "ggthemes::calc")
#'     \item{only_classic_kin} If TRUE, only classic kin are shown
#'     \item{kin_grouping} If TRUE, use classic kin × mtDNA for grouping
#'     \item{drop_classic_kin} If TRUE, remove classic kin rows
#'     \item{drop_non_classic_sibs}If TRUE, remove non-classic sibs (default: TRUE)
#'     \item{annotate} If TRUE, annotate mother/father/sibling points
#'     \item{annotate_xshift} Relative x-axis shift for annotations
#'     \item{annotate_yshift} Relative y-axis shift for annotations
#'     \item{point_size} Size of geom_point() points (default: 1)
#'     \item{degree_rel} If TRUE, x-axis uses degree-of-relatedness scaling
#'     \item{grouping} Grouping column name (default: "mtdna_factor")
#'     \item{rounding} Number of decimal places for rounding (default: 2)
#'     \item{threshold} Tolerance % for matching known degrees (default: 10)
#'     \item{max_degrees} Maximum number of degrees to consider (default: 12)
#'     }
#'  @param ... Additional arguments passed to `ggplot2` functions.
#'  @param data_prep Logical; if TRUE, performs data preparation steps.
#'  @return A ggplot object containing the correlation plot.
#'  @importFrom dplyr mutate filter pull sym
#'  @importFrom ggplot2 ggplot aes geom_ribbon geom_line geom_point annotate labs theme
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

  if(data_prep == TRUE) {
    # Check if required columns are present
    required_cols <- c("addRel_min", "addRel_max", "n_pairs", "cnu", "mtdna")
    if (!all(required_cols %in% names(df))) {
      stop(paste("Data frame must contain the following columns:", paste(required_cols, collapse = ", ")))
    }

  if(!"addRel_center" %in% names(df)) {
    df <- df |>
      mutate(addRel_center = (.data$addRel_max + .data$addRel_min)/2) # Centering the addRel values
  }
  if(!"classic_kin" %in% names(df)) {
    df <-  df |>
      mutate( classic_kin =
                case_when(
                  .data$addRel_max %in% (2^(0:(-config$max_degrees)) * (1 + config$threshold/100)) ~ 1,
                  .data$addRel_max == 0 ~ 1,
    TRUE ~ 0
  ))
}
    if (!"degree_relative" %in% names(df)) {
      df <- df |>
        mutate(degree_relative = # solve for as a function of addRel_max
                 case_when(
                   .data$addRel_max >= (1 + config$threshold/100) ~ 0,
                   .data$addRel_max < 1 ~ log2(1/(.data$addRel_max)*(1 + config$threshold/100))
                 ))
    }

    if (!paste0(y_stem_se, "_minusse") %in% names(df)) {
      df <- df |>
        mutate(!!sym(paste0(y_stem_se, "_minusse")) :=
                 .data[[y_se]] - 1.96 * (.data[[y_se]]/sqrt(.data$n_pairs)))
    }
    if (!paste0(y_stem_se, "_plusse") %in% names(df)) {
      df <- df |>
        mutate(!!sym(paste0(y_stem_se, "_plusse")) :=
                 .data[[y_se]] + 1.96 * (.data[[y_se]]/sqrt(.data$n_pairs)))
    }
    if (!"mtdna_factor" %in% names(df)) {
      df <- df |>
        mutate(mtdna_factor = factor(.data$mtdna, levels = c(0, 1)))
    }
}

  # Dynamically create ymin and ymax variable names
  y_var_sym <- sym(y_var)
  ymin_var <- sym(paste0(y_stem_se, "_minusse"))
  ymax_var <- sym(paste0(y_stem_se, "_plusse"))
  grouping_sym <- sym(config$grouping)

  # annotation values
  config$xshift <- config$annotate_xshift
  config$yshift <- config$annotate_yshift

  x_value_mom <- x_value_sib <- x_value_dad <- .5

  annotation_mom_x <- x_value_mom + config$xshift * x_value_mom
  annotation_sib_x <- x_value_sib + config$xshift * x_value_sib
  annotation_dad_x <- x_value_dad + config$xshift * x_value_dad

  # Extract specific y-values based on provided positions, using dynamic column names

  y_value_sib <- df |>
    dplyr::filter(
      cnu == 1,
      addRel_center == .5
    ) |>
    pull(!!y_var_sym) |>
    as.numeric()

  annotation_sib_y <- y_value_sib + config$yshift * y_value_sib #- .0055

  y_value_dad <- df |>
    dplyr::filter(cnu == 0, mtdna == 0, addRel_center == .5) |>
    pull(!!y_var_sym) |>
    as.numeric()
  annotation_dad_y <- y_value_dad + config$yshift * y_value_dad

  y_value_mom <- df |>
    dplyr::filter(cnu == 0, mtdna == 1, addRel_center == .5) |>
    pull(!!y_var_sym) |>
    as.numeric()

  annotation_mom_y <- y_value_mom + config$yshift * y_value_mom

  df_point <- df |> dplyr::filter(cnu == 1, addRel_center == .5)

  # drop rows based on filter conditions
  df <- df |>
    tidyr::drop_na(!!y_var_sym) |>
    mutate(classic_kin_factor = factor(paste0(classic_kin, mtdna))) |>
    dplyr::filter(n_pairs > config$filter_n_pairs & addRel_center < 1 & degree_relative < config$filter_degree_max & degree_relative > config$filter_degree_min)

  # drop weird sibs
  if (config$drop_non_classic_sibs) {
    df <- df |>
      mutate(drop = case_when(
        mtdna == 1 & classic_kin == 0 & cnu == 1 ~ 1,
        TRUE ~ 0
      )) |>
      dplyr::filter(drop != 1) |>
      select(-"drop")
  }

  # if only_classic_kin is TRUE, filter out non-classic kinship
  if (config$only_classic_kin) {
    df <- df |> dplyr::filter(classic_kin == 1)
  } else if (config$drop_classic_kin) {
    df <- df |> dplyr::filter(classic_kin == 0)
  }

  # make plot
  core_plot <- df |>
    ggplot(aes(
      x = addRel_center,
      y = !!y_var_sym,
      group = !!grouping_sym,
      color = !!grouping_sym,
      shape = !!grouping_sym
    ))
  if (config$only_classic_kin==TRUE | config$kin_grouping==TRUE) {
    core_plot <- core_plot +
      ggplot2::geom_ribbon(
        aes(
          ymin = !!ymin_var,
          ymax = !!ymax_var, fill = !!grouping_sym
        ),
        alpha = .3, linetype = 0
      ) + # , stat = "smooth", method = "loess") +
      ggplot2::geom_line(aes(linetype = !!grouping_sym))
  } else {
    core_plot <- core_plot +
      ggplot2::geom_ribbon(
        aes(
          ymin = !!ymin_var,
          ymax = !!ymax_var,
          fill = classic_kin_factor,
          color = classic_kin_factor,
          group = classic_kin_factor
        ),
        stat = "smooth", span = .02,
        outline.type = "upper", method = "lm", # group = df$classic_kin,
        alpha = .3, linetype = 0,
        show.legend = FALSE
      ) +
      ggplot2::geom_line(aes(
        group = !!grouping_sym,
        color = !!grouping_sym
      ), linetype = "solid")
  }

  core_plot <- core_plot +
    geom_point(size = config$point_size)

  # annotate if and only if
  if (config$annotate == TRUE) {
    # the specifics
    if (config$filter_degree_min == 0 & config$drop_classic_kin == FALSE) {
      core_plot <- core_plot +
        geom_point(data = df_point, aes(x = x_value_sib, y = y_value_sib), size = config$point_size) + # Add the single point
        annotate("text",
          x = annotation_sib_x, y = annotation_sib_y, label = "Sibling Correlation",
          hjust = 0, vjust = 0, color = "black", size = 4
        ) +
        annotate("text",
          x = annotation_mom_x, y = annotation_mom_y, label = "Mother-child Correlation",
          hjust = 0, vjust = -0, color = "black", size = 4
        ) +
        annotate("text",
          x = annotation_dad_x, y = annotation_dad_y, label = "Father-child Correlation",
          hjust = 0, vjust = -0, color = "black", size = 4
        )
    } else if (config$filter_degree_min == 0 & config$drop_classic_kin == TRUE) {
      core_plot <- core_plot +
        geom_point(data = df_point, aes(x = x_value_sib, y = y_value_sib), size = config$point_size) + # Add the single point
        annotate("text",
          x = annotation_sib_x, y = annotation_sib_y, label = "Sibling Correlation",
          hjust = 0, vjust = -0, color = "black", size = 4
        )
    }
  }
  # naming

  if (config$grouping == "mtdna_factor") {
    config$grouping_name <- "mtDNA"
  } else {
    config$grouping_name <- paste0(config$grouping)
  }

  core_plot <- core_plot +
    theme(axis.text.x = element_text(size = 12, angle = -65, hjust = 0)) # scale_x_reverse() +
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
      ) +
      theme(legend.position = "top")
  } else {
    core_plot <- core_plot + scale_x_continuous(
      trans = compose_trans("log2", "reverse"),
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
        group = paste0(config$grouping_name), fill = paste0(config$grouping_name)
      ) +
      theme(legend.position = "top")
  }

  if (!is.null(config$color_scale)) {
    core_plot <- core_plot + theme_bw() +
      paletteer::scale_color_paletteer_d(config$color_scale) +
      paletteer::scale_fill_paletteer_d(config$color_scale)
  }
  return(core_plot)
}
