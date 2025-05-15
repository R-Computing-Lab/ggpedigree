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
    spouseID = c(NA, NA, NA, NA, NA),
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
    spouseID = c(NA, NA, NA, NA, NA),
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


test_that("broken hints doesn't cause a fatal error", {
  library(BGmisc)
  data("potter")

  # Test with hints
  expect_warning(
    ggPedigree(potter,
      famID = "famID",
      personID = "personID",
      config = list(hints = TRUE)
    )
  )
})
