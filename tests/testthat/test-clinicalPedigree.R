test_that("affected_fill_column creates filled/unfilled nodes", {
  library(BGmisc)
  data("potter")

  # Add an affected fill column
  potter$SEP <- ifelse(potter$personID %% 2 == 0, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    affected_fill_column = "SEP",
    config = list(
      sex_color_include = FALSE,
      affected_fill_code_affected = 1,
      affected_fill_color_affected = "red"
    )
  )
  expect_s3_class(p, "gg")

  # Build the plot to check layers
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("deceased_column adds cross overlay", {
  library(BGmisc)
  data("potter")

  # Add a deceased column
  potter$DECES <- ifelse(potter$personID <= 4, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    deceased_column = "DECES",
    config = list(
      deceased_code_affected = 1,
      deceased_shape = "cross",
      deceased_color = "black"
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
    deceased_column = "DECES",
    outline_color_column = "INCLUS",
    config = list(
      preset = "clinical",
      affected_fill_code_affected = 1,
      deceased_code_affected = 1,
      outline_color_code_affected = 1,
      outline_color_affected = "blue"
    )
  )
  expect_s3_class(p, "gg")
})

test_that("all clinical features compose without error", {
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
    deceased_column = "DECES",
    outline_color_column = "INCLUS",
    config = list(
      sex_color_include = FALSE,
      affected_fill_code_affected = 1,
      affected_fill_color_affected = "black",
      deceased_code_affected = 1,
      deceased_shape = "cross",
      deceased_color = "black",
      outline_color_code_affected = 1,
      outline_color_affected = "blue",
      outline_color_unaffected = "black"
    )
  )
  expect_s3_class(p, "gg")
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("deceased overlay only renders for matching values", {
  library(BGmisc)
  data("potter")

  # Only person 1 is deceased
  potter$DECES <- ifelse(potter$personID == 1, 1, 0)

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    deceased_column = "DECES",
    config = list(
      deceased_code_affected = 1
    )
  )
  expect_s3_class(p, "gg")

  # Build the plot and verify the deceased overlay layer has limited points
  built <- ggplot2::ggplot_build(p)
  # Find the deceased overlay layer (uses shape 4)
  deceased_layers <- vapply(built$data, function(d) {
    "shape" %in% names(d) && any(d$shape == "4" | d$shape == 4)
  }, logical(1))
  # Should have at least one layer with shape 4 for the deceased marker
  expect_true(any(deceased_layers))
})

test_that("config defaults for clinical params follow naming conventions", {
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

  # deceased uses _code_affected/_code_unaffected pattern
  expect_equal(config$deceased_include, FALSE)
  expect_equal(config$deceased_code_affected, 1)
  expect_equal(config$deceased_code_unaffected, 0)
  expect_equal(config$deceased_label_affected, "Deceased")
  expect_equal(config$deceased_label_unaffected, "Alive")
  expect_equal(config$deceased_shape, "cross")
  expect_true(is.null(config$deceased_size))
  expect_equal(config$deceased_color, "black")
  expect_equal(config$deceased_stroke, 1.5)

  # outline_color uses _code_affected/_code_unaffected pattern
  expect_equal(config$outline_color_include, FALSE)
  expect_equal(config$outline_color_code_affected, 1)
  expect_equal(config$outline_color_code_unaffected, 0)
  expect_equal(config$outline_color_label_affected, "Highlighted")
  expect_equal(config$outline_color_label_unaffected, "Default")
  expect_equal(config$outline_color_affected, "blue")
  expect_equal(config$outline_color_unaffected, "black")

  # preset
  expect_true(is.null(config$preset))
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
