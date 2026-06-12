library(BGmisc)
data("potter", package = "BGmisc", envir = environment())
potter <- potter[, !names(potter) %in% c("twinID", "zygosity")]

make_ds <- function(x = c(1, 2, 3, 4), y = c(0, 0, 1, 1)) {
  data.frame(
    x_pos   = x,
    y_pos   = y,
    x_fam   = x,
    y_fam   = y,
    y_order = as.integer(y)
  )
}

cart_cfg <- list(
  coord_layout         = "cartesian",
  generation_height    = 1,
  generation_width     = 1,
  coord_radial_scale   = 1.5,
  coord_radial_min_radius = 0.75
)

radial_cfg <- list(
  coord_layout              = "radial",
  coord_radial_start_angle  = -90,
  coord_radial_end_angle    = 270,
  coord_radial_scale        = 1.5,
  coord_radial_min_radius   = 0.75,
  spread_out_generations    = TRUE,
  spread_out_generations_factor = 0.5,
  generation_height         = 1,
  generation_width          = 1
)

# ---------------------------------------------------------------------------
# .adjustSpacing — cartesian branches
# ---------------------------------------------------------------------------

test_that(".adjustSpacing shifts positive min_y to zero", {
  ds <- make_ds(y = c(2, 2, 3, 3))
  result <- ggpedigree:::.adjustSpacing(ds, cart_cfg)
  expect_equal(min(result$y_pos, na.rm = TRUE), 0)
  expect_equal(result$y_pos, c(0, 0, 1, 1))
})

test_that(".adjustSpacing with negative min_y does not shift (clamps to 0)", {
  ds <- make_ds(y = c(-1, -1, 0, 0))
  result <- ggpedigree:::.adjustSpacing(ds, cart_cfg)
  # min_y=-1 is clamped to 0; subtraction is ds$y_pos - 0 = unchanged
  expect_equal(result$y_pos, ds$y_pos)
})

test_that(".adjustSpacing scales y_pos by generation_height", {
  ds <- make_ds(y = c(0, 0, 1, 1))
  cfg <- utils::modifyList(cart_cfg, list(generation_height = 2))
  result <- ggpedigree:::.adjustSpacing(ds, cfg)
  expect_equal(result$y_pos, c(0, 0, 2, 2))
  expect_equal(result$y_fam, c(0, 0, 2, 2))
})

test_that(".adjustSpacing scales x_pos by generation_width", {
  ds <- make_ds(x = c(1, 2, 3, 4), y = c(0, 0, 1, 1))
  cfg <- utils::modifyList(cart_cfg, list(generation_width = 3))
  result <- ggpedigree:::.adjustSpacing(ds, cfg)
  expect_equal(result$x_pos, c(3, 6, 9, 12))
  expect_equal(result$x_fam, c(3, 6, 9, 12))
})

# ---------------------------------------------------------------------------
# .adjustSpacing — radial branch
# ---------------------------------------------------------------------------

test_that(".adjustSpacing radial branch applies scale and min_radius to y", {
  ds <- make_ds(y = c(0, 0, 1, 1))
  cfg <- utils::modifyList(cart_cfg, list(coord_layout = "radial"))
  result <- ggpedigree:::.adjustSpacing(ds, cfg)
  expected <- c(0, 0, 1, 1) * cart_cfg$coord_radial_scale + cart_cfg$coord_radial_min_radius
  expect_equal(result$y_pos, expected)
  expect_equal(result$y_fam, expected)
})

test_that(".adjustSpacing radial and cartesian y_pos differ when scale != 1", {
  ds <- make_ds(y = c(0, 0, 1, 1))
  r_cart   <- ggpedigree:::.adjustSpacing(ds, cart_cfg)
  r_radial <- ggpedigree:::.adjustSpacing(
    ds, utils::modifyList(cart_cfg, list(coord_layout = "radial"))
  )
  expect_false(identical(r_cart$y_pos, r_radial$y_pos))
})

# ---------------------------------------------------------------------------
# .applyRadialLayout
# ---------------------------------------------------------------------------

test_that(".applyRadialLayout transforms coordinates for multi-individual layout", {
  ds <- make_ds(x = c(1, 2, 3, 4), y = c(0.75, 0.75, 2.25, 2.25))
  result <- ggpedigree:::.applyRadialLayout(ds, radial_cfg)
  expect_equal(nrow(result), nrow(ds))
  expect_false(identical(result$x_pos, ds$x_pos))
  expect_false(identical(result$y_pos, ds$y_pos))
  expect_false(any(result$x_pos == 0, na.rm = TRUE))
  expect_false(any(result$y_pos == 0, na.rm = TRUE))
})

test_that(".applyRadialLayout edge case: all same x maps to the same angle", {
  ds <- make_ds(x = c(2, 2, 2), y = c(0.75, 0.75, 2.25))
  result <- ggpedigree:::.applyRadialLayout(ds, radial_cfg)
  expect_equal(nrow(result), 3)
  # Same x_range → all points get midpoint angle → same cos → same x_pos
  expect_equal(result$x_pos[1], result$x_pos[2])
  expect_equal(result$x_pos[1], result$x_pos[3])
})

test_that(".applyRadialLayout edge case: all same y maps to the same radius", {
  ds <- make_ds(x = c(1, 2, 3), y = c(1, 1, 1))
  result <- ggpedigree:::.applyRadialLayout(ds, radial_cfg)
  expect_equal(nrow(result), 3)
  # Same y → same radius → sqrt(x^2 + y^2) equal across all points
  r <- sqrt(result$x_pos^2 + result$y_pos^2)
  expect_equal(r[1], r[2], tolerance = 1e-6)
  expect_equal(r[1], r[3], tolerance = 1e-6)
})

test_that(".applyRadialLayout with spread_out_generations=FALSE skips spread factor", {
  ds <- make_ds(x = c(1, 2, 3, 4), y = c(0.75, 0.75, 2.25, 2.25))
  cfg_no_spread <- utils::modifyList(radial_cfg, list(spread_out_generations = FALSE))
  cfg_spread    <- utils::modifyList(radial_cfg, list(spread_out_generations = TRUE))
  r_no_spread <- ggpedigree:::.applyRadialLayout(ds, cfg_no_spread)
  r_spread    <- ggpedigree:::.applyRadialLayout(ds, cfg_spread)
  expect_equal(nrow(r_no_spread), nrow(ds))
  # Outer generation (y_order > 0) gets pushed further with spread=TRUE
  expect_false(identical(r_no_spread$x_pos, r_spread$x_pos))
})

# ---------------------------------------------------------------------------
# Integration: radial layout through ggPedigree
# ---------------------------------------------------------------------------

test_that("ggPedigree with coord_layout='radial' returns a ggplot", {
  p <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(coord_layout = "radial")
  ))
  expect_s3_class(p, "gg")
})

test_that("ggPedigree radial layout with spread_out_generations=FALSE returns a ggplot", {
  p <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(coord_layout = "radial", spread_out_generations = FALSE)
  ))
  expect_s3_class(p, "gg")
})
