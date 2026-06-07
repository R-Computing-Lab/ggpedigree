# Tests for lineage-colored segments (segment_lineage_* config options)

# Helper: collect distinct, non-NA colors from segment layers of a built plot
.seg_layer_colors <- function(p) {
  obj <- if (inherits(p, "ggplot")) p else p$plot
  b <- ggplot2::ggplot_build(obj)
  cols <- character(0)
  for (ld in b$data) {
    if (all(c("x", "xend", "y", "yend") %in% names(ld))) {
      cols <- c(cols, unique(stats::na.omit(ld$colour)))
    }
  }
  sort(unique(cols))
}

test_that("segment lineage coloring is off by default and preserves fixed colors", {
  library(BGmisc)
  data("inbreeding")

  p <- ggPedigree(
    inbreeding,
    famID = "famID", personID = "ID",
    config = list(code_male = 0,
                  code_female = 1,
                  sex_color_include = FALSE,
                  override_many2many = TRUE)
  )
  expect_s3_class(p, "gg")
  # With no lineage coloring, segments use the single fixed default color
  expect_equal(.seg_layer_colors(p), "black")
})

test_that("group-mode mitochondrial lineage colors segments by maternal line", {
  library(BGmisc)
  data("inbreeding")

  p <- ggPedigree(
    inbreeding,
    famID = "famID", personID = "ID",
    config = list(
      code_male = 0, code_female = 1,
      sex_color_include = FALSE, focal_fill_include = FALSE,
      segment_lineage_include = TRUE,
      segment_lineage_component = "mitochondrial",
      override_many2many = TRUE
    )
  )
  expect_s3_class(p, "gg")
  # Multiple lineage groups -> more than one segment color present
  expect_gt(length(.seg_layer_colors(p)), 1L)
})

test_that("focal continuous mitochondrial lineage builds", {
  library(BGmisc)
  data("inbreeding")

  fid <- inbreeding$ID[5]
  expect_no_error(
    ggPedigree(
      inbreeding,
      famID = "famID", personID = "ID",
      config = list(
        code_male = 0, code_female = 1,
        sex_color_include = FALSE, focal_fill_include = FALSE,
        segment_lineage_include = TRUE,
        segment_lineage_component = "mitochondrial",
        segment_lineage_focal_personID = fid,
        segment_lineage_method = "viridis_c",
        override_many2many = TRUE
      )
    )
  )
})

test_that("focal group-mode restricts coloring to the focal person's line", {
  library(BGmisc)
  data("inbreeding")

  fid <- inbreeding$ID[5]
  p <- ggPedigree(
    inbreeding,
    famID = "famID", personID = "ID",
    config = list(
      code_male = 0, code_female = 1,
      sex_color_include = FALSE, focal_fill_include = FALSE,
      segment_lineage_include = TRUE,
      segment_lineage_component = "paternal",
      segment_lineage_focal_personID = fid,
      override_many2many = TRUE
    )
  )
  expect_s3_class(p, "gg")
})

test_that("node focal_fill and segment lineage combine when ggnewscale is available", {
  skip_if_not_installed("ggnewscale")
  library(BGmisc)
  data("inbreeding")

  expect_no_error(
    ggPedigree(
      inbreeding,
      famID = "famID", personID = "ID",
      config = list(
        code_male = 0, code_female = 1,
        sex_color_include = FALSE,
        focal_fill_include = TRUE,
        focal_fill_component = "additive",
        focal_fill_personID = inbreeding$ID[2],
        segment_lineage_include = TRUE,
        segment_lineage_component = "paternal",
        override_many2many = TRUE
      )
    )
  )
})

test_that("invalid segment_lineage_method raises an informative error", {
  library(BGmisc)
  data("inbreeding")

  expect_error(
    ggPedigree(
      inbreeding,
      famID = "famID", personID = "ID",
      config = list(
        code_male = 0, code_female = 1,
        sex_color_include = FALSE, focal_fill_include = FALSE,
        segment_lineage_include = TRUE,
        segment_lineage_component = "mitochondrial",
        segment_lineage_method = "not_a_method",
        override_many2many = TRUE
      )
    ),
    "segment_lineage_method"
  )
})

test_that("interactive plot supports single-scale lineage segments", {
  skip_if_not_installed("plotly")
  library(BGmisc)
  data("inbreeding")

  p <- ggPedigreeInteractive(
    inbreeding,
    famID = "famID", personID = "ID",
    tooltip_columns = c("ID", "sex"),
    config = list(
      code_male = 0, code_female = 1,
      sex_color_include = FALSE, focal_fill_include = FALSE,
      segment_lineage_include = TRUE,
      segment_lineage_component = "mitochondrial",
      override_many2many = TRUE
    )
  )
  expect_s3_class(p, "plotly")
})

test_that("interactive plot warns and falls back when combining node + lineage color", {
  skip_if_not_installed("plotly")
  library(BGmisc)
  data("inbreeding")

  expect_warning(
    p <- ggPedigreeInteractive(
      inbreeding,
      famID = "famID", personID = "ID",
      tooltip_columns = c("ID", "sex"),
      config = list(
        code_male = 0,
        code_female = 1,
        sex_color_include = TRUE,
        segment_lineage_include = TRUE,
        segment_lineage_component = "paternal",
        override_many2many = TRUE
      )
    ),
    "not supported in interactive"
  )
  expect_s3_class(p, "plotly")
})

test_that("additive component without a focal person colors relative to a default reference", {
  library(BGmisc)
  data("inbreeding")

  expect_message(
    p <- ggPedigree(
      inbreeding,
      famID = "famID", personID = "ID",
      config = list(
        code_male = 0, code_female = 1,
        sex_color_include = FALSE, focal_fill_include = FALSE,
        segment_lineage_include = TRUE,
        segment_lineage_component = "additive",
        segment_lineage_method = "viridis_c",
        override_many2many = TRUE
      )
    ),
    "continuous relatedness"
  )
  expect_s3_class(p, "gg")
  # Additive relatedness varies, so more than one segment color is produced
  expect_gt(length(.seg_layer_colors(p)), 1L)
})

test_that("common nuclear component is supported", {
  library(BGmisc)
  data("inbreeding")

  expect_no_error(
    suppressMessages(ggPedigree(
      inbreeding,
      famID = "famID", personID = "ID",
      config = list(
        code_male = 0, code_female = 1,
        sex_color_include = FALSE, focal_fill_include = FALSE,
        segment_lineage_include = TRUE,
        segment_lineage_component = "common nuclear",
        segment_lineage_method = "viridis_c",
        override_many2many = TRUE
      )
    ))
  )
})

test_that("unrecognized segment_lineage_component warns and skips", {
  library(BGmisc)
  data("inbreeding")

  expect_warning(
    p <- ggPedigree(
      inbreeding,
      famID = "famID", personID = "ID",
      config = list(
        code_male = 0, code_female = 1,
        sex_color_include = FALSE, focal_fill_include = FALSE,
        segment_lineage_include = TRUE,
        segment_lineage_component = "not_a_component",
        override_many2many = TRUE
      )
    ),
    "Unrecognized segment_lineage_component"
  )
  expect_s3_class(p, "gg")
})
