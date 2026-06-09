# Tests for pinning individuals to fixed layout positions (config$fixed_positions)

cc <- function(ped, cfg = list()) {
  calculateCoordinates(ped,
    personID = "personID", momID = "momID",
    dadID = "dadID", config = utils::modifyList(list(code_male = 1), cfg)
  )
}

get_potter <- function() {
  data("potter", package = "BGmisc", envir = environment())
  potter[, !names(potter) %in% c("twinID", "zygosity")]
}

test_that("no fixed_positions leaves coordinates unchanged", {
  potter <- get_potter()
  base <- cc(potter)
  none <- cc(potter, list(fixed_positions = NULL))
  expect_equal(none$x_pos, base$x_pos)
  expect_equal(none$y_pos, base$y_pos)
  expect_equal(none$x_fam, base$x_fam)
})

test_that("pinning a person sets an absolute x position", {
  potter <- get_potter()
  d <- cc(potter, list(fixed_positions = data.frame(personID = 8, x = -3)))
  expect_equal(d$x_pos[d$personID == 8], -3)
})

test_that("pinning works when the ID column is named 'ID'", {
  potter <- get_potter()
  d <- cc(potter, list(fixed_positions = data.frame(ID = 8, x = -3)))
  expect_equal(d$x_pos[d$personID == 8], -3)
})

test_that("pinning controls both x and y", {
  potter <- get_potter()
  d <- cc(potter, list(fixed_positions = data.frame(personID = 8, x = 1.5, y = 4)))
  expect_equal(d$x_pos[d$personID == 8], 1.5)
  expect_equal(d$y_pos[d$personID == 8], 4)
})

test_that("NA axis leaves the computed value unchanged", {
  potter <- get_potter()
  base <- cc(potter)
  d <- cc(potter, list(fixed_positions = data.frame(personID = 8, x = NA, y = 7)))
  expect_equal(d$x_pos[d$personID == 8], base$x_pos[base$personID == 8])
  expect_equal(d$y_pos[d$personID == 8], 7)
})

test_that("pinning a parent updates children's family anchor by default", {
  potter <- get_potter()
  base <- cc(potter)
  kids <- potter$personID[potter$momID == 101 | potter$dadID == 101]
  kids <- kids[!is.na(kids)]

  d <- cc(potter, list(fixed_positions = data.frame(personID = 101, x = 99)))
  # children's x_fam should move toward the pinned parent
  expect_false(isTRUE(all.equal(
    base$x_fam[base$personID %in% kids],
    d$x_fam[d$personID %in% kids]
  )))
})

test_that("fixed_positions_update_family = FALSE leaves family anchors untouched", {
  potter <- get_potter()
  base <- cc(potter)
  kids <- potter$personID[potter$momID == 101 | potter$dadID == 101]
  kids <- kids[!is.na(kids)]

  d <- cc(potter, list(
    fixed_positions = data.frame(personID = 101, x = 99),
    fixed_positions_update_family = FALSE
  ))
  expect_equal(
    d$x_fam[d$personID %in% kids],
    base$x_fam[base$personID %in% kids]
  )
})

test_that("unmatched IDs warn and are ignored", {
  potter <- get_potter()
  expect_warning(
    cc(potter, list(fixed_positions = data.frame(personID = 99999, x = 1))),
    "not found"
  )
})

test_that("non-data-frame fixed_positions raises an error", {
  potter <- get_potter()
  expect_error(
    cc(potter, list(fixed_positions = list(personID = 8, x = 1))),
    "must be a data.frame"
  )
})

test_that("fixed_positions propagates end-to-end through ggPedigree and segments", {
  potter <- get_potter()
  p_base <- suppressWarnings(ggPedigree(potter,
    personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(code_male = 1, return_static = TRUE)
  ))
  p_pin <- suppressWarnings(ggPedigree(potter,
    personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(
      code_male = 1, return_static = TRUE,
      fixed_positions = data.frame(personID = 8, x = -5)
    )
  ))

  expect_equal(p_pin$data$x_pos[p_pin$data$personID == 8], -5)
  expect_false(isTRUE(all.equal(
    p_base$data$x_pos[p_base$data$personID == 8],
    p_pin$data$x_pos[p_pin$data$personID == 8]
  )))
  # plot still builds
  expect_s3_class(p_pin, "gg")
  expect_no_error(ggplot2::ggplot_build(p_pin))
})
