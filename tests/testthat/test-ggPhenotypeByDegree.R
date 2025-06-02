test_that("ggPhenotypeByDegree basic functionality", {
  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, 0.4, 0.5, 0.6),
    y_se = c(0.05, 0.04, 0.03, 0.02, 0.01)
  ) %>%
    dplyr::mutate(
      addRel_min = addRel_center * .9,
      addRel_max = addRel_center * 1.1
    )

  # Call the function with basic parameters
  p <- ggPhenotypeByDegree(
    df = df,
    y_var = "y_var",
    y_se = "y_se",
    config = list(apply_default_theme = FALSE)
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")
})

test_that("ggPhenotypeByDegree handles missing values", {
  # Create a sample data frame with NA values
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, NA, 800, 900, 1000),
    cnu = c(1, 1, NA, 1, 1),
    mtdna = c(0, 1, 0, NA, 0),
    y_var = c(0.2, NA, 0.4, 0.5, NA),
    y_se = c(0.05, NA, 0.03, NA, 0.01)
  ) %>%
    dplyr::mutate(
      addRel_min = addRel_center * .9,
      addRel_max = addRel_center * 1.1
    )

  # Call the function and expect it to handle NAs gracefully
  p <- ggPhenotypeByDegree(
    df = df,
    y_var = "y_var",
    y_se = "y_se",
    config = list(apply_default_theme = FALSE)
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")
})

test_that("ggPhenotypeByDegree applies custom  drops correctly", {
  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, NA, 0.5, NA),
    y_se = c(0.05, NA, 0.03, NA, 0.01)
  ) %>%
    dplyr::mutate(
      addRel_min = addRel_center * .9,
      addRel_max = addRel_center * 1.1
    )

  # Call the function with drop_non_classic_sibs set to TRUE
  p <- ggPhenotypeByDegree(
    df = df %>%
      dplyr::select(-addRel_center),
    y_var = "y_var",
    y_se = "y_se",
    config = list(
      drop_classic_kin = TRUE,
      default_scales = FALSE,
      use_relative_degree = FALSE,
      annotate_include = FALSE
    )
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")
  # Check if the data has been filtered correctly
  expect_true(all(is.na(p$data$y_var) | p$data$y_var != 0.3))
  expect_true("addRel_center" %in% names(p$data) == TRUE)
})
test_that("ggPhenotypeByDegree applies custom configurations", {
  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, 0.4, 0.5, 0.6),
    y_se = c(0.05, 0.04, 0.03, 0.02, 0.01)
  ) %>%
    dplyr::mutate(
      addRel_min = addRel_center * .9,
      addRel_max = addRel_center * 1.1
    )

  # Call the function with custom configurations
  p <- ggPhenotypeByDegree(
    df = df,
    y_var = "y_var",
    y_se = "y_se",
    config = list(
      apply_default_theme = FALSE,
      plot_title = "Custom Title",
      plot_subtitle = "Custom Subtitle"
    )
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")

  # Check if the title and subtitle are set correctly
  expect_equal(p$labels$title, "Custom Title")
  expect_equal(p$labels$subtitle, "Custom Subtitle")
})

test_that("ggPhenotypeByDegree handles different thresholds", {
  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, 0.4, 0.5, 0.6),
    y_se = c(0.05, 0.04, 0.03, 0.02, 0.01)
  ) %>%
    dplyr::mutate(
      addRel_min = addRel_center * .8,
      addRel_max = addRel_center * 1.2
    )

  # Call the function with different grouping configurations
  p <- ggPhenotypeByDegree(
    df = df,
    y_var = "y_var",
    y_se = "y_se",
    config = list(
      apply_default_theme = FALSE,
      match_threshold_percent  = 20
    )
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")
  # Check if the threshold is applied correctly
  expect_true(all(p$data$n_pairs >= 20))
  expect_true(all(p$data$addRel_center >= 0))
})
test_that("ggPhenotypeByDegree handles empty data frames", {
  # Create an empty data frame
  df_empty <- data.frame(
    addRel_center = numeric(0),
    n_pairs = numeric(0),
    cnu = numeric(0),
    mtdna = numeric(0),
    y_var = numeric(0),
    y_se = numeric(0),
    addRel_min = numeric(0),
    addRel_max = numeric(0)
  )

  # Call the function with the empty data frame
  p <- ggPhenotypeByDegree(
    df = df_empty,
    y_var = "y_var",
    y_se = "y_se",
    config = list(apply_default_theme = FALSE)
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")
})
