test_that("ggPhenotypeByDegree basic functionality", {
  library(dplyr)
  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, 0.4, 0.5, 0.6),
    y_se = c(0.05, 0.04, 0.03, 0.02, 0.01)
  ) %>%
    mutate(
      addRel_min = addRel_center*.9,
      addRel_max = addRel_center*1.1
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
  library(dplyr)

  # Create a sample data frame with NA values
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, NA, 800, 900, 1000),
    cnu = c(1, 1, NA, 1, 1),
    mtdna = c(0, 1, 0, NA, 0),
    y_var = c(0.2, NA, 0.4, 0.5, NA),
    y_se = c(0.05, NA, 0.03, NA, 0.01)
  ) %>%
    mutate(
      addRel_min = addRel_center*.9,
      addRel_max = addRel_center*1.1
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

test_that("ggPhenotypeByDegree applies custom configurations", {
  library(dplyr)

  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, 0.4, 0.5, 0.6),
    y_se = c(0.05, 0.04, 0.03, 0.02, 0.01)
  ) %>%
    mutate(
      addRel_min = addRel_center*.9,
      addRel_max = addRel_center*1.1
    )

  # Call the function with custom configurations
  p <- ggPhenotypeByDegree(
    df = df,
    y_var = "y_var",
    y_se = "y_se",
    config = list(
      apply_default_theme = FALSE,
      title = "Custom Title",
      subtitle = "Custom Subtitle"
    )
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")

  # Check if the title and subtitle are set correctly
  expect_equal(p$labels$title, "Custom Title")
  expect_equal(p$labels$subtitle, "Custom Subtitle")
})

test_that("ggPhenotypeByDegree handles different thresholds", {

  library(dplyr)

  # Create a sample data frame
  df <- data.frame(
    addRel_center = c(.5^c(1, 0, 2, 3, 4)),
    n_pairs = c(600, 700, 800, 900, 1000),
    cnu = c(1, 1, 1, 1, 1),
    mtdna = c(0, 1, 0, 1, 0),
    y_var = c(0.2, 0.3, 0.4, 0.5, 0.6),
    y_se = c(0.05, 0.04, 0.03, 0.02, 0.01)
  ) %>%
    mutate(
      addRel_min = addRel_center*.8,
      addRel_max = addRel_center*1.2
    )

  # Call the function with different grouping configurations
  p <- ggPhenotypeByDegree(
    df = df,
    y_var = "y_var",
    y_se = "y_se",
    config = list(
      apply_default_theme = FALSE,
      threshold = 20
    )
  )

  # Check if the output is a ggplot object
  expect_s3_class(p, "gg")
})
test_that("ggPhenotypeByDegree handles empty data frames", {
  library(dplyr)
  # Create an empty data frame
  df_empty <- data.frame(
    addRel_center = numeric(0),
    n_pairs = numeric(0),
    cnu = numeric(0),
    mtdna = numeric(0),
    y_var = numeric(0),
    y_se = numeric(0)
  ) %>%
    mutate(
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
