library(BGmisc)
data("potter", package = "BGmisc", envir = environment())
potter <- potter[, !names(potter) %in% c("twinID", "zygosity")]

base_plt <- ggplot2::ggplot(
  data.frame(x = 1, y = 1, personID = "A"),
  ggplot2::aes(x = x, y = y)
)


label_cfg <- list(
  label_column        = "personID",
  label_nudge_y       = 0,
  label_nudge_x       = 0,
  label_text_size     = 3,
  label_text_color    = "black",
  label_max_overlaps  = 10,
  segment_linewidth   = 0.5,
  label_text_angle    = 0,
  label_text_family   = "",
  label_segment_color = "black",
  generation_height   = 1,
  generation_width    = 1,
  label_method        = "geom_text"
)

n_layers <- function(p) length(p$layers)

# ---------------------------------------------------------------------------
# geom_text (default)
# ---------------------------------------------------------------------------

test_that(".addLabels geom_text adds a GeomText layer", {
  result <- ggpedigree:::.addLabels(base_plt, label_cfg)
  expect_equal(n_layers(result), n_layers(base_plt) + 1)
  expect_true(inherits(result$layers[[n_layers(result)]]$geom, "GeomText"))
})

# ---------------------------------------------------------------------------
# geom_label
# ---------------------------------------------------------------------------

test_that(".addLabels geom_label adds a GeomLabel layer", {
  cfg <- utils::modifyList(label_cfg, list(label_method = "geom_label"))
  result <- ggpedigree:::.addLabels(base_plt, cfg)
  expect_equal(n_layers(result), n_layers(base_plt) + 1)
  expect_true(inherits(result$layers[[n_layers(result)]]$geom, "GeomLabel"))
})

# ---------------------------------------------------------------------------
# ggrepel methods
# ---------------------------------------------------------------------------

test_that(".addLabels geom_text_repel adds a layer when ggrepel is available", {
  skip_if_not_installed("ggrepel")
  cfg <- utils::modifyList(label_cfg, list(label_method = "geom_text_repel"))
  result <- ggpedigree:::.addLabels(base_plt, cfg)
  expect_equal(n_layers(result), n_layers(base_plt) + 1)
})

test_that(".addLabels 'ggrepel' alias adds a layer when ggrepel is available", {
  skip_if_not_installed("ggrepel")
  cfg <- utils::modifyList(label_cfg, list(label_method = "ggrepel"))
  result <- ggpedigree:::.addLabels(base_plt, cfg)
  expect_equal(n_layers(result), n_layers(base_plt) + 1)
})

test_that(".addLabels warns and falls back to geom_text when ggrepel is unavailable", {
  skip_if_not_installed("mockery")

  cfg <- utils::modifyList(label_cfg, list(label_method = "geom_text_repel"))
  mockery::stub(ggpedigree:::.addLabels, "requireNamespace", function(...) FALSE)

  result <- ggpedigree:::.addLabels(base_plt, cfg)
  # Falls back to geom_text — still adds a layer
  expect_equal(n_layers(result), n_layers(base_plt) + 1)
})

# ---------------------------------------------------------------------------
# invalid label_method
# ---------------------------------------------------------------------------

test_that(".addLabels warns and adds no layer for an invalid label_method", {
  cfg <- utils::modifyList(label_cfg, list(label_method = "unknown_method"))
  expect_warning(
    result <- ggpedigree:::.addLabels(base_plt, cfg),
    regexp = "Invalid label_method"
  )
  expect_equal(n_layers(result), n_layers(base_plt))
})

# ---------------------------------------------------------------------------
# Integration: label methods through ggPedigree
# ---------------------------------------------------------------------------

test_that("ggPedigree with label_method='geom_label' returns a ggplot", {
  p <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(label_include = TRUE, label_method = "geom_label")
  ))
  expect_s3_class(p, "gg")
})

test_that("ggPedigree with label_method='geom_text_repel' returns a ggplot", {
  skip_if_not_installed("ggrepel")
  p <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(label_include = TRUE, label_method = "geom_text_repel")
  ))
  expect_s3_class(p, "gg")
})

test_that("ggPedigree with label_method='geom_label_repel' returns a ggplot", {
  skip_if_not_installed("ggrepel")
  p <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(label_include = TRUE, label_method = "geom_label_repel")
  ))
  expect_s3_class(p, "gg")
})
