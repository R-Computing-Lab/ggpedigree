test_that("ggPedigreeInteractive behaves same as ggPedigree interactive is true", {
  library(BGmisc)
  data("potter")

  # Test with hints
  p_widget <- ggPedigreeInteractive(potter,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p_widget, "plotly")
  expect_s3_class(p_widget, "htmlwidget")

  # Test with hints
  p <- ggPedigree(potter,
    interactive = TRUE,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p, "plotly")
  expect_s3_class(p, "htmlwidget")


  expect_equal(p_widget$height, p$height)
  expect_equal(p_widget$width, p$width)
  expect_equal(p_widget$x$layout, p$x$layout)
  expect_equal(p_widget$x$data, p$x$data)
  expect_equal(p_widget$x$frames, p$x$frames)
  expect_equal(p_widget$x$source, p$x$source)
  expect_equal(p_widget$x$elementId, p$x$elementId)
  # expect_equal(p_widget$x$attrs, p$x$attrs)
  expect_equal(p_widget$x$config, p$x$config)
  expect_equal(p_widget$sizingPolicy, p$sizingPolicy)
})
test_that("ggPedigreeInteractive returns a gg object", {
  library(BGmisc)
  data("potter")

  static <- ggPedigreeInteractive(
    potter,
    famID = "famID",
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    patID = "patID",
    matID = "matID",
    config = list(
      label_nudge_y = -.25,
      labels_include = TRUE,
      label_method = "geom_text",
      sex_color_include = TRUE,
      return_static = TRUE
    ),
    tooltip_columns = c("personID", "name")
  )
  expect_s3_class(static, "gg")
})
