test_that("getDefaultPlotConfig errors as expected", {
  expect_error(
    getDefaultPlotConfig(color_palette_default = "red"),
    "color_palette_default must be a character vector with at least 3 colors."
  )

  expect_error(
    getDefaultPlotConfig(segment_default_color = c("red", "blue")),
    "segment_default_color must be a single character string."
  )

  expect_error(getDefaultPlotConfig(function_name = "unknownFunction"))
})

test_that("getDefaultPlotConfig returns expected defaults", {
  config <- getDefaultPlotConfig()

  expect_true(is.list(config))
  expect_equal(length(config), 159) # Check number of default parameters

  expect_equal(config$apply_default_scales, TRUE)
  expect_equal(config$apply_default_theme, TRUE)
  expect_equal(
    config$color_palette_default,
    c("#440154FF", "#FDE725FF", "#21908CFF")
  )
  expect_equal(config$segment_self_color, "black")
  expect_equal(config$segment_parent_color, "black")
  expect_equal(config$segment_sibling_color, "black")
  expect_equal(config$segment_spouse_color, "black")
  expect_equal(config$segment_self_linetype, "dotdash")
  expect_equal(config$segment_self_angle, 90)
  expect_equal(config$segment_self_curvature, -0.2)
  expect_equal(config$label_method, "geom_text")
  expect_equal(config$label_include, TRUE)
  expect_equal(config$tooltip_include, TRUE)
  expect_equal(config$tooltip_columns, c("ID1", "ID2", "value"))
  expect_equal(config$axis_text_angle_x, 90)
  expect_equal(config$axis_text_angle_y, 0)
  expect_equal(config$axis_text_size, 9)
  expect_equal(config$axis_text_color, "black")
  expect_equal(config$generation_height, 1)
  expect_equal(config$generation_width, 1)
  expect_equal(config$sex_color_include, TRUE)
  expect_equal(config$axis_text_family, "sans")
  expect_equal(config$outline_additional_size, 0)
  expect_equal(config$outline_multiplier, 1.25)
  expect_equal(config$point_size, 4)
  expect_true(is.null(config$hints))
  expect_true(is.null(config$relation))
  expect_equal(config$outline_multiplier * config$point_size, 5)
  expect_equal(
    config$outline_multiplier * config$point_size + config$outline_additional_size,
    5
  )
})
test_that("handles function_name variations", {
  config1 <- getDefaultPlotConfig(function_name = "ggpedigree")
  config2 <- getDefaultPlotConfig(function_name = "ggPedigreeInteractive")
  config3 <- getDefaultPlotConfig(function_name = "ggrelatednessmatrix")


  expect_true(is.list(config1))
  expect_true(is.list(config2))
  expect_true(is.list(config3))
  expect_equal(length(config1), length(config2))
  expect_equal(length(config1), length(config3))

  expect_equal(config1$label_method, "geom_text")
  expect_equal(config2$label_method, "geom_text")
  expect_equal(config2$label_nudge_y_flip, TRUE)
  expect_equal(config3$label_nudge_y_flip, FALSE)
  expect_equal(config1$label_nudge_y, config2$label_nudge_y)
  expect_equal(config1$label_nudge_y, config3$label_nudge_y)
  expect_true(config2$return_widget)
  expect_true(config2$return_interactive)
  expect_false(config2$return_static)
})

test_that("buildPlotConfig warns on unrecognized keys", {
  default_config <- getDefaultPlotConfig(function_name = "ggPedigree")

  expect_warning(buildPlotConfig(default_config, list(bogus_key = 1)), regexp = "not recognized")
})


test_that("buildPlotConfig accepts valid keys without warning", {
  default_config <- getDefaultPlotConfig(function_name = "ggPedigree")

  config <- list(point_size = 3, label_include = FALSE)

  expect_silent(buildPlotConfig(default_config, config))
})

test_that("buildPlotConfig  warns on duplicated keys, honors first value in duplicate", {
  default_config <- getDefaultPlotConfig(function_name = "ggPedigree")

  config <- list(point_size = 1, point_size = 99)

  result <- suppressWarnings(buildPlotConfig(default_config, config))
  expect_equal(result$point_size, 1)

  expect_warning(buildPlotConfig(default_config, config), regexp = "Duplicate config keys detected")

  config <- list(point_size = 99, point_size = 1)

  result <- suppressWarnings(buildPlotConfig(default_config, config))
  expect_equal(result$point_size, 99)
})

test_that("buildPlotConfig merges valid subset overrides correctly", {
  default_config <- getDefaultPlotConfig(function_name = "ggPedigree")

  custom <- list(point_size = 2, label_text_size = 10)

  result <- buildPlotConfig(default_config, custom)
  expect_equal(result$point_size, 2)
  expect_equal(result$label_text_size, 10)
  expect_equal(
    result$segment_linewidth,
    default_config$segment_linewidth
  )
  expect_equal(result$label_nudge_y, -0.15)
  expect_equal(result$label_nudge_y, -1 * default_config$label_nudge_y)
})
test_that("buildPlotConfig returns a list", {
  default_config <- getDefaultPlotConfig(function_name = "ggrelatednessmatrix")
  custom <- list(point_size = 2)

  result <- buildPlotConfig(default_config, custom)
  expect_equal(result$label_nudge_y, 0.15)
  expect_true(is.list(result))
})
