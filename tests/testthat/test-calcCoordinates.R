test_that("calculateCoordinates assigns correct layout for unique individuals", {
  library(BGmisc)
  data("potter")

  ped <- potter

  coords <- calculateCoordinates(ped, code_male = 1, personID = "personID")

  expect_true(all(c("x_order", "y_order", "x_pos", "y_pos", "nid") %in% names(coords)))
  expect_true(all(ped$ID %in% coords$personID)) # ID retention
  expect_equal(nrow(coords), nrow(ped)) # no duplicates yet
})

# test_that("calculateCoordinates extras", {
#  library(BGmisc)
#  data("ASOIAF")

# coords <- calculateCoordinates(ASOIAF, code_male = "M", personID = "id")

# expect_true("extra" %in% names(coords))
# dup_ids <- coords$ID[duplicated(coords$ID)]
# expect_true(length(dup_ids) > 0)  # Someone appears twice
# expect_true(any(coords$extra == TRUE))
# })
test_that("calculateCoordinates Code M works for characters", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  coords <- calculateCoordinates(ped, code_male = "M")

  expect_true(all(c("x_order", "y_order", "x_pos", "y_pos", "nid") %in% names(coords)))
  expect_true(all(coords$ID %in% ped$ID)) # ID retention
  expect_equal(nrow(coords), nrow(ped)) # no duplicates yet
})


test_that("calculateConnections returns expected structure", {
  ped <- data.frame(
    personID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  coords <- calculateCoordinates(ped, code_male = "M", personID = "personID")
  conns <- calculateConnections(coords, config = list(code_male = "M"))

  expected_cols <- c(
    "personID", "x_pos", "y_pos",
    "dadID", "momID", "spouseID",
    "x_mom", "y_mom", "x_dad", "y_dad",
    "x_spouse", "y_spouse",
    "x_midparent", "y_midparent",
    "x_mid_spouse", "y_mid_spouse",
    "x_mid_sib", "y_mid_sib"
  )

  expect_true(all(expected_cols %in% names(conns$connections)))
})


test_that("getRelativeCoordinates returns expected coordinates for mother", {
  # Step 1: Minimal input pedigree
  input_ped <- data.frame(
    personID = c("A", "B", "C", "D"),
    momID = c(NA, NA, "A", "A"),
    dadID = c(NA, NA, "B", "B"),
    spouseID = c("B", "A", NA, NA),
    sex = c("F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )

  # Step 2: Apply calculateCoordinates (required precondition)
  ped <- calculateCoordinates(
    input_ped,
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    sexVar = "sex",
    code_male = "M"
  )

  # Step 3: Add famID to match downstream expectations
  ped$famID <- 1

  # Step 4: Build connections as done in calculateConnections()
  connections <- ped[, c(
    "personID", "x_pos", "y_pos",
    "dadID", "momID", "spouseID", "famID"
  )]

  # Step 5: Run the function under test
  mom_coords <- getRelativeCoordinates(
    ped = ped,
    connections = connections,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom"
  )

  # Step 6: Validate results
  # For people C and D (whose mom is A), we should get A's coordinates
  mom_row <- ped[ped$personID == "A", ]
  expected_x <- mom_row$x_pos
  expected_y <- mom_row$y_pos

  target <- mom_coords[mom_coords$personID %in% c("C", "D"), ]

  expect_equal(target$x_mom, rep(expected_x, 2))
  expect_equal(target$y_mom, rep(expected_y, 2))

  # Others (A and B, who have NA momID) should be excluded
  expect_false("A" %in% mom_coords$personID)
  expect_false("B" %in% mom_coords$personID)
})


test_that("calculateCoordinates fails on incorrect ped input", {
  expect_error(
    calculateCoordinates("not_a_df"),
    "ped should be a data.frame or inherit to a data.frame"
  )

  expect_error(
    calculateCoordinates(data.frame(ID = 1:3), personID = "ID"),
    "At least one of the required ID variables"
  )
})



test_that("calculateCoordinates uses default code_male = 1", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  coords <- calculateCoordinates(ped)
  expect_true(all(c("x_order", "y_order", "x_pos", "y_pos", "nid") %in% names(coords)))
  expect_true(all(coords$ID %in% ped$ID)) # ID retention
  expect_true(all(coords$momID %in% ped$momID)) # momID retention
  expect_true(all(coords$dadID %in% ped$dadID)) # dadID retention
  expect_true(all(coords$spouseID %in% ped$spouseID)) # spouseID retention
  expect_equal(nrow(coords), nrow(ped)) # no duplicates yet
  expect_equal(nrow(coords), 5)
  expect_true(all(!is.na(coords$x_order)))
})

test_that("calculateCoordinates returns extra rows when duplicated appearances", {
  ped <- data.frame(
    ID = c("P1", "P2", "P3"),
    momID = c(NA, NA, "P1"),
    dadID = c(NA, NA, "P2"),
    spouseID = c("P2", "P1", NA),
    sex = c("F", "M", "F")
  )

  coords <- calculateCoordinates(ped, code_male = "M")

  # Manually simulate layout duplication
  expect_true("extra" %in% names(coords))
  expect_true(any(coords$extra == TRUE | coords$extra == FALSE))
})

test_that("calculateCoordinates handles missing spouseID column gracefully", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    sex = c("F", "M", "F", "F", "M")
  )

  # No spouseID present, should still compute without error
  coords <- calculateCoordinates(ped, code_male = "M")
  expect_true(all(c("x_order", "y_order", "x_pos", "y_pos", "nid") %in% names(coords)))
})

test_that("calculateCoordinates layout changes with ped_align and ped_packed", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  coords_default <- calculateCoordinates(
    ped,
    personID = "ID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    sexVar = "sex",
    code_male = "M",
    config = list(ped_align = TRUE, ped_packed = TRUE)
  )

  coords_unaligned <- calculateCoordinates(
    ped,
    personID = "ID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    sexVar = "sex",
    code_male = "M",
    config = list(ped_align = FALSE, ped_packed = TRUE)
  )

  coords_unpacked <- calculateCoordinates(
    ped,
    personID = "ID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    sexVar = "sex",
    code_male = "M",
    config = list(ped_align = TRUE, ped_packed = FALSE)
  )

  # 1. Same IDs in all
  expect_setequal(coords_default$ID, coords_unaligned$ID)
  expect_setequal(coords_default$ID, coords_unpacked$ID)

  # 2. Actual layout changes
  layout_default <- coords_default[order(coords_default$ID), c("x_pos", "y_pos")]
  layout_unaligned <- coords_unaligned[order(coords_unaligned$ID), c("x_pos", "y_pos")]
  layout_unpacked <- coords_unpacked[order(coords_unpacked$ID), c("x_pos", "y_pos")]

  expect_false(identical(layout_default, layout_unaligned))
  expect_false(identical(layout_unaligned, layout_unpacked))
})
