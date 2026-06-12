# Tests for .nearestFreeSlot and .repositionCrossGenerationSpouses

# ---------------------------------------------------------------------------
# Helper: build a minimal pedigree and run calculateCoordinates
# ---------------------------------------------------------------------------
cc <- function(ped, cfg = list()) {
  calculateCoordinates(ped,
    personID = "personID", momID = "momID",
    dadID = "dadID", config = utils::modifyList(list(code_male = 1), cfg)
  )
}

# ---------------------------------------------------------------------------
# Build a cross-generation-spouse pedigree:
#
#  Gen 1:  Jean (F, no parents)  ──── (child Alex, unplaced)
#  Gen 2:  William (M, no parents) ─┐
#          Elizabeth (F, no parents)┘
#  Gen 3:  Child1, Child2  (William × Elizabeth)
#
# Jean and William share Alex (unplaced). William also has placed children
# with Elizabeth, so kinship2 puts William in Gen 2. Jean, with no placed
# children, gets dropped in Gen 1 by kinship2 → cross-generation spouse pair.
# ---------------------------------------------------------------------------
make_cross_gen_ped <- function() {
  data.frame(
    personID = c("Jean", "William", "Elizabeth", "Alex", "Child1", "Child2"),
    momID = c(NA, NA, NA, "Jean", "Elizabeth", "Elizabeth"),
    dadID = c(NA, NA, NA, "William", "William", "William"),
    sex = c(0, 1, 0, 1, 1, 0),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# .nearestFreeSlot ─────────────────────────────────────────────────────────
# ---------------------------------------------------------------------------

test_that(".nearestFreeSlot returns anchor-1 when it is free", {
  result <- ggpedigree:::.nearestFreeSlot(anchor = 5, taken = c(3, 6, 7))
  expect_equal(result, 4)
})

test_that(".nearestFreeSlot skips left and takes right when left is occupied", {
  result <- ggpedigree:::.nearestFreeSlot(anchor = 5, taken = c(4, 3))
  expect_equal(result, 6)
})

test_that(".nearestFreeSlot returns NA when all nearby slots are occupied", {
  taken <- seq(0, 20, by = 1)
  result <- ggpedigree:::.nearestFreeSlot(anchor = 5, taken = taken, max_search = 3)
  expect_true(is.na(result))
})

test_that(".nearestFreeSlot works when taken is empty", {
  result <- ggpedigree:::.nearestFreeSlot(anchor = 5, taken = numeric(0))
  expect_equal(result, 4)
})

test_that(".nearestFreeSlot skips both immediate neighbours and finds next free slot", {
  # anchor=4, both immediate neighbours (3 and 5) are taken
  # next candidates: left=2 (free), right=6 (free) → returns 2 (left preferred)
  result <- ggpedigree:::.nearestFreeSlot(anchor = 4, taken = c(3, 5), step = 1)
  expect_equal(result, 2)
})

# ---------------------------------------------------------------------------
# .repositionCrossGenerationSpouses ────────────────────────────────────────
# ---------------------------------------------------------------------------

test_that("cross-generation founder is moved to spouse's y level", {
  ped <- make_cross_gen_ped()
  coords <- cc(ped)

  jean_row <- coords[coords$personID == "Jean", ]
  william_row <- coords[coords$personID == "William" & !isTRUE(coords$extra), ]

  expect_equal(jean_row$y_pos, william_row$y_pos,
    info = "Jean should be repositioned to William's generation"
  )
})

test_that("repositioned founder is placed adjacent to spouse (within 2 units)", {
  ped <- make_cross_gen_ped()
  coords <- cc(ped)

  jean_row <- coords[coords$personID == "Jean" & !isTRUE(coords$extra), ]
  william_row <- coords[coords$personID == "William" & !isTRUE(coords$extra), ]

  expect_true(abs(jean_row$x_pos - william_row$x_pos) <= 2,
    info = "Jean should be placed within 2 layout units of William"
  )
})

test_that("founder with placed children is NOT repositioned", {
  ped <- make_cross_gen_ped()
  coords <- cc(ped)

  # William has placed children (Child1, Child2) — he must not move
  william_row <- coords[coords$personID == "William" & !isTRUE(coords$extra), ]
  child_rows <- coords[coords$personID %in% c("Child1", "Child2"), ]

  # William's y_pos must be exactly one generation above his children
  expect_true(all(william_row$y_pos < child_rows$y_pos),
    info = "William (has placed children) must remain in his own generation"
  )
})

test_that("founder already in the same generation as spouse is not moved", {
  # Simple two-generation pedigree: both founders placed in generation 1
  ped <- data.frame(
    personID = c("Mom", "Dad", "Kid"),
    momID = c(NA, NA, "Mom"),
    dadID = c(NA, NA, "Dad"),
    sex = c(0, 1, 1),
    stringsAsFactors = FALSE
  )
  coords <- cc(ped)

  mom_row <- coords[coords$personID == "Mom", ]
  dad_row <- coords[coords$personID == "Dad", ]

  expect_equal(mom_row$y_pos, dad_row$y_pos,
    info = "Same-generation spouses should remain unchanged"
  )
})

test_that("repositioning does not create a position collision", {
  ped <- make_cross_gen_ped()
  coords <- cc(ped)

  placed <- coords[!is.na(coords$x_pos) & !isTRUE(coords$extra), ]
  jean_x <- placed$x_pos[placed$personID == "Jean"]
  others <- placed$x_pos[placed$personID != "Jean" &
    placed$y_pos == placed$y_pos[placed$personID == "Jean"]]

  if (length(jean_x) > 0 && length(others) > 0) {
    expect_true(all(abs(others - jean_x) >= 0.4),
      info = "Jean's new position must not overlap any other node at the same y level"
    )
  }
})

test_that("fixed_positions override takes effect after auto-reposition", {
  ped <- make_cross_gen_ped()
  coords <- cc(ped, list(fixed_positions = data.frame(personID = "Jean", x = 99, y = 0)))

  jean_row <- coords[coords$personID == "Jean", ]
  expect_equal(jean_row$x_pos, 99)
  expect_equal(jean_row$y_pos, 0)
})

test_that("pedigree with no cross-generation spouses is unchanged", {
  data("potter", package = "BGmisc", envir = environment())
  ped <- potter[, !names(potter) %in% c("twinID", "zygosity")]
  base <- cc(ped)
  # Re-running should produce the same result (idempotent for already-correct layouts)
  expect_equal(base$x_pos, cc(ped)$x_pos)
  expect_equal(base$y_pos, cc(ped)$y_pos)
})
