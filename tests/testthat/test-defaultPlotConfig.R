test_that("getDefaultPlotConfig errors as expected", {
  expect_error(
    getDefaultPlotConfig(color_palette_default = "red"),
    "color_palette_default must be a character vector with at least 3 colors."
  )

  expect_error(
    getDefaultPlotConfig(segment_default_color = c("red", "blue")),
    "segment_default_color must be a single character string."
  )

  expect_error(
    getDefaultPlotConfig(function_name = "unknownFunction")
  )
})

test_that("getDefaultPlotConfig returns expected defaults", {
  config <- getDefaultPlotConfig()

  expect_true(is.list(config))
  expect_equal(length(config), 81) # Check number of default parameters

  expect_equal(config$apply_default_scales, TRUE)
  expect_equal(config$apply_default_theme, TRUE)
  expect_equal(config$color_palette_default, c("#440154FF", "#FDE725FF", "#21908CFF"))
  expect_equal(config$segment_self_color, "black")
  expect_equal(config$segment_parent_color, "black")
  expect_equal(config$segment_sibling_color, "black")
  expect_equal(config$segment_spouse_color, "black")
  expect_equal(config$segment_self_linetype, "dotdash")
  expect_equal(config$segment_self_angle, 90)
  expect_equal(config$segment_self_curvature, -0.2)
  expect_equal(config$label_method, "ggrepel")
  expect_equal(config$label_include, TRUE)
  expect_equal(config$tooltip_include, TRUE)
  expect_equal(config$tooltip_columns, c("ID1", "ID2", "value"))
  expect_equal(config$axis_text_angle_x, 90)
  expect_equal(config$axis_text_angle_y, 0)
  expect_equal(config$axis_text_size, 8)
  expect_equal(config$axis_text_color, "black")
  expect_equal(config$generation_height, 1)
  expect_equal(config$generation_width, 1)
  expect_equal(config$sex_color_include, TRUE)
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

  expect_equal(config1$label_method, "ggrepel")
  expect_equal(config2$label_method, "geom_text")
  expect_true(config2$return_widget)
  expect_true(config2$return_interactive)
  expect_false(config2$return_static)
})
