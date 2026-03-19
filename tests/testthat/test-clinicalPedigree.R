test_that("affected_fill_column creates filled/unfilled nodes", {
  library(BGmisc)
  library(svglite)
  data("potter")

  # Add an affected fill column
  potter$SEP <- ifelse(potter$personID %% 2 == 0, 1, 0)

  p_unaffected_coded <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    affected_fill_column = "SEP",
    config = list(
      sex_color_include = FALSE,
      affected_fill_code_affected = 1,
      affected_fill_code_unaffected = 0,
      affected_fill_color_affected = "#FF0000",
      affected_fill_color_unaffected = "black"
    )
  )
  p_unaffected_uncoded <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    affected_fill_column = "SEP",
    config = list(
      sex_color_include = FALSE,
      affected_fill_code_affected = 1,
      affected_fill_color_affected = "#FF0000",
      affected_fill_color_unaffected = "black"
    )
  )

  p <- p_unaffected_coded
  expect_s3_class(p, "gg")
  p <- p_unaffected_uncoded
  expect_s3_class(p, "gg")

  # expect to have both affected and unaffected colors in the plot data
  built_coded <- ggplot2::ggplot_build(p_unaffected_coded)
  built_uncoded <- ggplot2::ggplot_build(p_unaffected_uncoded)

  ggplot2::ggsave("built_coded.svg", plot = p_unaffected_coded)
  ggplot2::ggsave("built_uncoded.svg", plot = p_unaffected_uncoded)

  built_coded.svg <- readLines("built_coded.svg")
  built_uncoded.svg <- readLines("built_uncoded.svg")

  # delete svg files after reading

  file.remove("built_coded.svg")
  file.remove("built_uncoded.svg")

  expect_true(any(grepl("fill:\\s*#FF0000", built_coded.svg)))
  expect_true(any(grepl("fill:\\s*#FF0000", built_uncoded.svg)))

  fill_colors_coded <- unique(built_coded$data[[8]]$fill)
  expect_true("red" %in% fill_colors_coded || "#FF0000" %in% fill_colors_coded)

  fill_colors_uncoded <- unique(built_uncoded$data[[8]]$fill)
  expect_true("red" %in% fill_colors_uncoded || "#FF0000" %in% fill_colors_uncoded)

  expect_equal(fill_colors_coded, fill_colors_uncoded)

  # is the data the same for both builds (should be, since unaffected_fill_color is just a default for NA values in the data)
  expect_equal(built_uncoded$data, built_coded$data)


  # Build the plot to check layers
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("overlay_column with shape mode adds cross overlay", {
  library(BGmisc)
  data("potter")

  # Add an overlay column (e.g., deceased status)
  potter$DECES <- ifelse(potter$personID <= 4, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlay_column = "DECES",
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape",
      overlay_shape = "cross",
      overlay_code_affected = 1,
      overlay_color = "black"
    )
  )
  expect_s3_class(p, "gg")

  # The plot should have more layers than a standard plot
  p_standard <- ggPedigree(potter,
    famID = "famID",
    personID = "personID"
  )
  expect_true(length(p$layers) > length(p_standard$layers))
})

test_that("outline_color_column applies per-individual outlines", {
  library(BGmisc)
  data("potter")

  # Add an inclusion column
  potter$INCLUS <- ifelse(potter$personID %% 3 == 0, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    outline_color_column = "INCLUS",
    config = list(
      sex_color_include = FALSE,
      outline_color_code_affected = 1,
      outline_color_affected = "blue",
      outline_color_unaffected = "black"
    )
  )
  expect_s3_class(p, "gg")

  # Build the plot to check scales
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("clinical preset sets correct defaults", {
  library(BGmisc)
  data("potter")

  potter$SEP <- sample(c(0, 1), nrow(potter), replace = TRUE)
  potter$DECES <- sample(c(0, 1), nrow(potter), replace = TRUE)
  potter$INCLUS <- sample(c(0, 1), nrow(potter), replace = TRUE)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    affected_fill_column = "SEP",
    overlay_column = "DECES",
    outline_color_column = "INCLUS",
    config = list(
      preset = "clinical",
      affected_fill_code_affected = 1,
      affected_fill_code_unaffected = 0,
      affected_fill_color_affected = "green",
      affected_fill_color_unaffected = "yellow",
      overlay_code_affected = 1,
      outline_color_code_affected = 1,
      outline_color_affected = "blue"
    )
  )
  expect_s3_class(p, "gg")
})

test_that("all features compose without error", {
  library(BGmisc)
  data("potter")

  potter$SEP <- sample(c(0, 1), nrow(potter), replace = TRUE)
  potter$DECES <- sample(c(0, 1), nrow(potter), replace = TRUE)
  potter$INCLUS <- sample(c(0, 1), nrow(potter), replace = TRUE)

  # All features active simultaneously
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    affected_fill_column = "SEP",
    overlay_column = "DECES",
    outline_color_column = "INCLUS",
    config = list(
      sex_color_include = FALSE,
      affected_fill_code_affected = 1,
      affected_fill_color_affected = "black",
      overlay_include = TRUE,
      overlay_mode = "shape",
      overlay_code_affected = 1,
      overlay_shape = "cross",
      overlay_color = "black",
      outline_color_code_affected = 1,
      outline_color_affected = "blue",
      outline_color_unaffected = "black"
    )
  )
  expect_s3_class(p, "gg")
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("shape overlay only renders for matching values", {
  library(BGmisc)
  data("potter")

  # Only person 1 matches
  potter$STATUS <- ifelse(potter$personID == 1, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlay_column = "STATUS",
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape",
      overlay_code_affected = 1
    )
  )
  expect_s3_class(p, "gg")

  # Build the plot and verify the shape overlay layer has limited points
  built <- ggplot2::ggplot_build(p)
  # Find the overlay layer (uses shape 4)
  overlay_layers <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == "4" | d$shape == 4)
  }, logical(1))
  # Should have at least one layer with shape 4 for the overlay
  expect_true(any(overlay_layers))
})

test_that("config defaults for overlay and affected_fill params follow naming conventions", {
  config <- getDefaultPlotConfig()

  # affected_fill uses _code_affected/_code_unaffected pattern
  expect_equal(config$affected_fill_include, FALSE)
  expect_equal(config$affected_fill_code_affected, 1)
  expect_equal(config$affected_fill_code_unaffected, 0)
  expect_equal(config$affected_fill_label_affected, "Affected")
  expect_equal(config$affected_fill_label_unaffected, "Unaffected")
  expect_equal(config$affected_fill_color_affected, "black")
  expect_true(is.na(config$affected_fill_color_unaffected))
  expect_equal(config$affected_fill_shape_female, 21)
  expect_equal(config$affected_fill_shape_male, 22)
  expect_equal(config$affected_fill_shape_unknown, 23)

  # overlay now includes mode/size/stroke params
  expect_equal(config$overlay_include, FALSE)
  expect_equal(config$overlay_mode, "alpha")
  expect_true(is.null(config$overlay_size))
  expect_equal(config$overlay_stroke, 1.5)
  expect_equal(config$overlay_shape, 4)
  expect_equal(config$overlay_color, "black")
  expect_equal(config$overlay_code_affected, 1)
  expect_equal(config$overlay_code_unaffected, 0)

  # outline_color uses _code_affected/_code_unaffected pattern
  expect_equal(config$outline_color_include, FALSE)
  expect_equal(config$outline_color_code_affected, 1)
  expect_equal(config$outline_color_code_unaffected, 0)
  expect_equal(config$outline_color_label_affected, "Highlighted")
  expect_equal(config$outline_color_label_unaffected, "Default")
  expect_equal(config$outline_color_affected, "blue")
  expect_equal(config$outline_color_unaffected, "black")

  # preset
  expect_equal(config$preset, "none")
})

test_that("existing behavior unaffected by new params", {
  library(BGmisc)
  data("potter")

  # Standard usage without new params should be unaffected
  p <- ggPedigree(potter, famID = "famID", personID = "personID")
  expect_s3_class(p, "gg")
  expect_true(all(p$data$personID %in% potter$personID))
  expect_equal(nrow(p$data), nrow(potter))
})

test_that("overlay shape mode supports numeric shape codes", {
  library(BGmisc)
  data("potter")

  potter$DECES <- ifelse(potter$personID <= 4, 1, 0)

  # Use numeric shape code directly instead of named string
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlay_column = "DECES",
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape",
      overlay_shape = 4,
      overlay_code_affected = 1
    )
  )
  expect_s3_class(p, "gg")
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
  # Check that the overlay layer uses shape mode with the specified numeric code
  overlay_layers <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == 4)
  }, logical(1))
})

test_that("clinical preset enables shape-mode overlay", {
  config <- getDefaultPlotConfig()

  # Before preset, overlay_mode should be "alpha"
  expect_equal(config$overlay_mode, "alpha")
  expect_equal(config$overlay_include, FALSE)

  # The clinical preset is applied in ggPedigree(), not in getDefaultPlotConfig()
  # So we test it via ggPedigree with the preset
  library(BGmisc)
  data("potter")

  potter$DECES <- sample(c(0, 1), nrow(potter), replace = TRUE)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlay_column = "DECES",
    config = list(
      preset = "clinical",
      overlay_code_affected = 1
    )
  )
  expect_s3_class(p, "gg")

  # Build the plot to check that overlay layer is present
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
  # Check that the overlay layer uses shape mode (should have shape aesthetic)
  overlay_layers <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == "4")
  }, logical(1))
  expect_true(any(overlay_layers))
})


test_that("overlays parameter adds multiple independent shape overlays", {
  library(BGmisc)
  data("potter")

  potter$DECES <- ifelse(potter$personID <= 4, 1, 0)
  potter$PROBAND <- ifelse(potter$personID == 1, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlays = list(
      list(column = "DECES", code_affected = 1, shape = "cross", color = "black"),
      list(column = "PROBAND", code_affected = 1, shape = 8, color = "red")
    ),
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape"
    )
  )
  expect_s3_class(p, "gg")


  # Should have more layers than a standard plot (two extra overlay layers)
  p_standard <- ggPedigree(potter,
    famID = "famID",
    personID = "personID"
  )
  expect_true(length(p$layers) >= length(p_standard$layers) + 2)
})

test_that("overlays specs override config defaults per-overlay", {
  library(BGmisc)
  data("potter")

  potter$STATUS_A <- ifelse(potter$personID %% 2 == 0, 1, 0)
  potter$STATUS_B <- ifelse(potter$personID %% 3 == 0, 1, 0)

  # Each overlay has different shape and color
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlays = list(
      list(column = "STATUS_A", code_affected = 1, shape = "cross", color = "blue"),
      list(column = "STATUS_B", code_affected = 1, shape = "slash", color = "red", stroke = 2)
    ),
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape"
    )
  )
  expect_s3_class(p, "gg")
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")

  # right now both are being applied to status B for some reason

  # Check that both overlay layers have the specified shapes and colors
  overlay_a <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == "4") && any(d$colour == "blue")
  }, logical(1))
  overlay_b <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == 47) && any(d$colour == "red") && any(d$stroke == 2)
  }, logical(1))
  expect_true(any(overlay_a))
  expect_true(any(overlay_b))
})

test_that("overlays parameter takes precedence over overlay_column", {
  library(BGmisc)
  data("potter")

  potter$STATUS_A <- ifelse(potter$personID %% 2 == 0, 1, 0)
  potter$STATUS_B <- rep(0, nrow(potter))

  # When both overlays and overlay_column are provided, overlays wins
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlay_column = "STATUS_B",
    overlays = list(
      list(column = "STATUS_A", code_affected = 1, shape = "cross")
    ),
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape"
    )
  )
  expect_s3_class(p, "gg")

  # Build and verify the shape overlay matches STATUS_A not STATUS_B
  built <- ggplot2::ggplot_build(p)
  overlay_layers <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == "4" | d$shape == 4)
  }, logical(1))
  expect_true(any(overlay_layers))
})

test_that("single overlay_column still works (backward compat)", {
  library(BGmisc)
  data("potter")

  potter$DECES <- ifelse(potter$personID <= 4, 1, 0)

  # Old single-column API should still work
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    overlay_column = "DECES",
    config = list(
      overlay_include = TRUE,
      overlay_mode = "shape",
      overlay_shape = "cross",
      overlay_code_affected = 1
    )
  )
  expect_s3_class(p, "gg")

  p_standard <- ggPedigree(potter,
    famID = "famID",
    personID = "personID"
  )
  expect_true(length(p$layers) > length(p_standard$layers))
})

test_that("affected_fill_color_unaffected is applied in rendered plot", {
  library(BGmisc)
  data("potter")

  potter$SEP <- ifelse(potter$personID %% 2 == 0, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    affected_fill_column = "SEP",
    config = list(
      sex_color_include = FALSE,
      affected_fill_code_affected = 1,
      affected_fill_color_affected = "green",
      affected_fill_color_unaffected = "yellow"
    )
  )
  expect_s3_class(p, "gg")

  built <- ggplot2::ggplot_build(p)
  # Find the layer that has 'fill' in its data
  fill_layer <- NULL
  for (i in seq_along(built$data)) {
    if ("fill" %in% names(built$data[[i]])) {
      fill_layer <- built$data[[i]]
      break
    }
  }
  expect_false(is.null(fill_layer))
  # Unaffected individuals should have yellow fill, not NA
  expect_true("yellow" %in% fill_layer$fill)
  # Affected individuals should have green fill
  expect_true("green" %in% fill_layer$fill)
})
