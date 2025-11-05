test_that("calculateConnections returns expected columns and structure", {
  ped <- data.frame(
    personID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  ped <- calculateCoordinates(ped,
    code_male = "M",
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    config = list(
      ped_align = TRUE,
      ped_packed = TRUE,
      return_midparent = TRUE
    )
  )

  conn_out <- calculateConnections(ped, config = list(return_midparent = TRUE))
  conns <- conn_out$connections

  expect_true(is.data.frame(conns))
  expect_true(all(c(
    "personID", "x_pos", "y_pos", "momID", "dadID", "spouseID",
    "x_mom", "y_mom", "x_dad", "y_dad", "x_spouse", "y_spouse",
    "x_fam", "y_fam", "x_midparent", "y_midparent", "x_mid_spouse", "y_mid_spouse",
    "x_mid_sib", "y_mid_sib"
  ) %in% names(conns)))
})

test_that("calculateConnections returns correct parent coordinates", {
  # A is mother of C and D; X is father of C and D
  ped <- data.frame(
    personID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "A", NA),
    dadID = c(NA, "X", "X", "X", NA),
    spouseID = c("X", NA, NA, NA, "A"),
    sex = c("F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )

  ped <- calculateCoordinates(ped,
    code_male = "M",
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID"
  )
  conn_out <- calculateConnections(ped)
  conns <- conn_out$connections

  # Get A and X's coordinates
  A_coords <- ped[ped$personID == "A", c("x_pos", "y_pos")]
  X_coords <- ped[ped$personID == "X", c("x_pos", "y_pos")]

  C_row <- conns[conns$personID == "C", ]
  expect_equal(C_row$x_mom, A_coords$x_pos)
  expect_equal(C_row$y_mom, A_coords$y_pos)
  expect_equal(C_row$x_dad, X_coords$x_pos)
  expect_equal(C_row$y_dad, X_coords$y_pos)
})

test_that("midparent coordinates are correct", {
  ped <- data.frame(
    personID = c("A", "B", "C"),
    momID = c(NA, NA, "A"),
    dadID = c(NA, NA, "B"),
    spouseID = c("B", "A", NA),
    sex = c("F", "M", "F")
  )

  ped <- calculateCoordinates(ped,
    code_male = "M",
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID"
  )
  conn_out <- calculateConnections(ped)
  conns <- conn_out$connections

  mid_x <- mean(c(
    ped[ped$personID == "A", "x_pos"],
    ped[ped$personID == "B", "x_pos"]
  ))
  mid_y <- mean(c(
    ped[ped$personID == "A", "y_pos"],
    ped[ped$personID == "B", "y_pos"]
  ))

  C_row <- conns[conns$personID == "C", ]
  expect_equal(C_row$x_fam, mid_x)
  expect_equal(C_row$y_fam, mid_y)
})

test_that("spouse midpoint is correctly calculated", {
  ped <- data.frame(
    personID = c("A", "B"),
    momID = c(NA_character_, NA_character_),
    dadID = c(NA_character_, NA_character_),
    spouseID = c("B", "A"),
    sex = c("F", "M")
  )

  ped <- calculateCoordinates(ped,
    code_male = "M",
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID"
  )
  conn_out <- calculateConnections(ped, config = list(debug = TRUE))
  conns <- conn_out$connections

  A_coords <- ped[ped$personID == "A", ]
  B_coords <- ped[ped$personID == "B", ]

  mid_x <- mean(c(A_coords$x_pos, B_coords$x_pos))
  mid_y <- mean(c(A_coords$y_pos, B_coords$y_pos))

  A_row <- conns[conns$personID == "A", ]
  expect_equal(A_row$x_mid_spouse, mid_x)
  expect_equal(A_row$y_mid_spouse, mid_y)
})

test_that("calculateConnections respects duplicated appearances (extra)", {
  ped <- data.frame(
    personID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  ped <- calculateCoordinates(ped,
    code_male = "M", personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID"
  )

  # Simulate duplicate appearance
  ped$extra <- FALSE
  duplicate_row <- ped[ped$personID == "A", ]
  duplicate_row$x_pos <- duplicate_row$x_pos + 1
  duplicate_row$extra <- TRUE
  ped <- rbind(ped, duplicate_row)

  # creates a many-to-many relationship
  # expect_warning(calculateConnections(ped))
  conn_out <- calculateConnections(ped) %>% suppressWarnings()
  conns <- conn_out$connections

  expect_true(any(conns$personID == "A"))
  expect_true(any(conns$extra == TRUE))
})

test_that("calculateConnections computes parental coordinates correctly", {
  # Minimal working data with known layout
  ped <- data.frame(
    personID = c("A", "B", "C"),
    momID = c(NA, NA, "A"),
    dadID = c(NA, NA, "B"),
    spouseID = c(NA_character_, NA_character_, NA_character_),
    x_pos = c(1, 3, 2), # layout positions
    y_pos = c(1, 1, 2),
    x_fam = c(NA, NA, 2),
    y_fam = c(NA, NA, 1),
    extra = FALSE
  )

  result <- calculateConnections(ped)
  conns <- result$connections

  C <- conns[conns$personID == "C", ]
  expect_equal(C$x_mom, 1)
  expect_equal(C$y_mom, 1)
  expect_equal(C$x_dad, 3)
  expect_equal(C$y_dad, 1)
})

test_that("calculateConnections computes midparent as average of mom/dad", {
  ped <- data.frame(
    personID = c("A", "B", "C"),
    momID = c(NA, NA, "A"),
    dadID = c(NA, NA, "B"),
    spouseID = c("B", "A", NA),
    x_pos = c(1, 3, 2),
    y_pos = c(1, 1, 2),
    x_fam = c(NA, NA, 2),
    y_fam = c(NA, NA, 1),
    extra = FALSE
  )

  result <- calculateConnections(ped)
  conns <- result$connections
  mid <- conns[conns$personID == "C", ]

  expect_equal(mid$x_fam, 2)
  expect_equal(mid$y_fam, 1)
})

test_that("calculateConnections computes spouse midpoints", {
  ped <- data.frame(
    personID = c("A", "B"),
    momID = c(NA_character_, NA_character_),
    dadID = c(NA_character_, NA_character_),
    spouseID = c("B", "A"),
    x_pos = c(1, 3),
    y_pos = c(1, 1),
    x_fam = c(NA, NA),
    y_fam = c(NA, NA),
    extra = FALSE
  )

  result <- calculateConnections(ped)
  conns <- result$connections
  A <- conns[conns$personID == "A", ]

  expect_equal(A$x_mid_spouse, 2)
  expect_equal(A$y_mid_spouse, 1)
})

test_that("calculateConnections computes sibling midpoints", {
  ped <- data.frame(
    personID = c("M", "F", "C1", "C2"),
    momID = c(NA, NA, "M", "M"),
    dadID = c(NA, NA, "F", "F"),
    spouseID = c("F", "M", NA, NA),
    x_pos = c(2, 4, 1, 5),
    y_pos = c(1, 1, 2, 2),
    x_fam = c(NA, NA, 3, 3),
    y_fam = c(NA, NA, 1, 1),
    extra = FALSE
  )

  result <- calculateConnections(ped)
  conns <- result$connections
  sibs <- conns[conns$personID %in% c("C1", "C2"), ]

  expect_equal(unique(sibs$y_mid_sib), 2)
  expect_equal(round(unique(sibs$x_mid_sib), 2), 3) # midpoint of x_pos = 1 and 5
})

test_that("calculateConnections resolves 'extra' rows properly", {
  ped <- data.frame(
    personID = c("A", "A"),
    momID = c(NA_character_, NA_character_),
    dadID = c(NA_character_, NA_character_),
    spouseID = c(NA_character_, NA_character_),
    x_pos = c(1, 4),
    y_pos = c(1, 1),
    x_fam = c(NA, NA),
    y_fam = c(NA, NA),
    extra = c(FALSE, TRUE)
  )
  # expect_warning(calculateConnections(ped))
  result <- calculateConnections(ped) %>% suppressWarnings()
  conns <- result$connections
  # at the connections stage its flagged as extra true
  expect_true(all(conns$extra == TRUE))

  # expect A to be the start of the string for the personID
  expect_true(all(grepl("^A", conns$personID)))

  expect_true(any(conns$personID == "A"))
  expect_equal(sum(conns$personID == "A"), 1)
  expect_equal(sum(conns$personID == "A_2"), 1)
})

# Tests for buildSpouseSegments function
test_that("buildSpouseSegments with use_hash=TRUE creates correct segments", {
  # Create test data with parent_hash
  ped <- data.frame(
    personID = c("A", "B", "C"),
    parent_hash = c("A.B", "A.B", NA),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B", "C"),
    x_pos = c(1, 3, 2),
    y_pos = c(1, 1, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE)

  expect_true(is.data.frame(result))
  expect_true("x_start" %in% names(result))
  expect_true("y_start" %in% names(result))
  expect_true("x_end" %in% names(result))
  expect_true("y_end" %in% names(result))

  # Check that segments were created for parent_hash entries
  result_with_coords <- result[!is.na(result$x_start) & !is.na(result$x_end), ]
  expect_true(nrow(result_with_coords) > 0)
})

test_that("buildSpouseSegments with use_hash=FALSE creates correct segments", {
  # Create test data with spouseID
  ped <- data.frame(
    personID = c("A", "B", "C"),
    spouseID = c("B", "A", NA),
    x_pos = c(1, 3, 2),
    y_pos = c(1, 1, 2),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B", "C"),
    spouseID = c("B", "A", NA),
    x_pos = c(1, 3, 2),
    y_pos = c(1, 1, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = FALSE)

  expect_true(is.data.frame(result))
  expect_true("x_start" %in% names(result))
  expect_true("y_start" %in% names(result))
  expect_true("x_end" %in% names(result))
  expect_true("y_end" %in% names(result))

  # Check that segments were created for spouses
  expect_equal(nrow(result), 2) # Only A and B have spouses
})

test_that("buildSpouseSegments with use_hash=FALSE filters out NA spouseID", {
  # Create test data where some have NA spouseID
  ped <- data.frame(
    personID = c("A", "B", "C", "D"),
    spouseID = c("B", "A", NA, NA),
    x_pos = c(1, 3, 2, 4),
    y_pos = c(1, 1, 2, 2),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B", "C", "D"),
    spouseID = c("B", "A", NA, NA),
    x_pos = c(1, 3, 2, 4),
    y_pos = c(1, 1, 2, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = FALSE)

  # Only A and B should have segments (they're each other's spouses)
  expect_equal(nrow(result), 2)
  expect_true(all(result$personID %in% c("A", "B")))
})

test_that("buildSpouseSegments with use_hash=TRUE handles NA parent_hash", {
  # Create test data with some NA parent_hash
  ped <- data.frame(
    personID = c("A", "B", "C", "D"),
    parent_hash = c("A.B", "A.B", NA, NA),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B", "C", "D"),
    x_pos = c(1, 3, 2, 4),
    y_pos = c(1, 1, 2, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE)

  expect_true(is.data.frame(result))
  # Should still process all rows but some will have NA coordinates
  expect_equal(nrow(result), 4)
})

test_that("buildSpouseSegments with use_hash=FALSE correctly maps spouse coordinates", {
  # Create test data with clear spouse relationships
  ped <- data.frame(
    personID = c("A", "B"),
    spouseID = c("B", "A"),
    x_pos = c(1, 5),
    y_pos = c(2, 3),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B"),
    spouseID = c("B", "A"),
    x_pos = c(1, 5),
    y_pos = c(2, 3),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = FALSE)

  # Check A's row: should connect from B (spouse) to A
  A_row <- result[result$personID == "A", ]
  expect_equal(A_row$x_start, 5) # B's x position
  expect_equal(A_row$y_start, 3) # B's y position
  expect_equal(A_row$x_end, 1) # A's x position
  expect_equal(A_row$y_end, 2) # A's y position

  # Check B's row: should connect from A (spouse) to B
  B_row <- result[result$personID == "B", ]
  expect_equal(B_row$x_start, 1) # A's x position
  expect_equal(B_row$y_start, 2) # A's y position
  expect_equal(B_row$x_end, 5) # B's x position
  expect_equal(B_row$y_end, 3) # B's y position
})

test_that("buildSpouseSegments with use_hash=TRUE extracts parent IDs correctly", {
  # Create test data with multiple parent pairs
  ped <- data.frame(
    personID = c("C1", "C2", "C3", "C4"),
    parent_hash = c("Mom1.Dad1", "Mom1.Dad1", "Mom2.Dad2", "Mom2.Dad2"),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("Mom1", "Dad1", "Mom2", "Dad2", "C1", "C2", "C3", "C4"),
    x_pos = c(1, 2, 4, 5, 1.5, 1.8, 4.5, 4.8),
    y_pos = c(1, 1, 1, 1, 2, 2, 2, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE)

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 4)

  # Check that coordinates were extracted from parent hash
  # For children with same parent_hash, they should have same start/end coords
  C1_row <- result[1, ]
  C2_row <- result[2, ]
  expect_equal(C1_row$x_start, C2_row$x_start)
  expect_equal(C1_row$y_start, C2_row$y_start)
})

test_that("buildSpouseSegments removes intermediate columns correctly", {
  # Test that function doesn't leak intermediate columns
  ped <- data.frame(
    personID = c("A", "B"),
    spouseID = c("B", "A"),
    x_pos = c(1, 3),
    y_pos = c(1, 1),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B"),
    spouseID = c("B", "A"),
    x_pos = c(1, 3),
    y_pos = c(1, 1),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = FALSE)

  # Check that spouseID_spouse was removed
  expect_false("spouseID_spouse" %in% names(result))
})

test_that("buildSpouseSegments with use_hash=TRUE removes intermediate columns", {
  # Test that function doesn't leak intermediate columns when using hash
  ped <- data.frame(
    personID = c("C1", "C2"),
    parent_hash = c("Mom.Dad", "Mom.Dad"),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("Mom", "Dad", "C1", "C2"),
    x_pos = c(1, 2, 1.3, 1.7),
    y_pos = c(1, 1, 2, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE)

  # Check that intermediate columns were removed
  expect_false("parent_hash" %in% names(result))
  expect_false("parent1" %in% names(result))
  expect_false("parent2" %in% names(result))
  expect_false("x_pos" %in% names(result))
  expect_false("y_pos" %in% names(result))
  expect_false("x_pos_parent2" %in% names(result))
  expect_false("y_pos_parent2" %in% names(result))
})

test_that("buildSpouseSegments with use_hash=FALSE handles unmatched spouseID", {
  # Test case where spouse is not in connections_for_FOO
  ped <- data.frame(
    personID = c("A", "B"),
    spouseID = c("Z", "A"), # Z doesn't exist in connections
    x_pos = c(1, 3),
    y_pos = c(1, 1),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("A", "B"), # No Z
    spouseID = c("B", "A"),
    x_pos = c(1, 3),
    y_pos = c(1, 1),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = FALSE)

  # A's spouse (Z) doesn't exist, so coordinates should be NA
  A_row <- result[result$personID == "A", ]
  expect_true(is.na(A_row$x_start))
  expect_true(is.na(A_row$y_start))

  # B's spouse (A) exists, so coordinates should be present
  B_row <- result[result$personID == "B", ]
  expect_false(is.na(B_row$x_start))
  expect_false(is.na(B_row$y_start))
})

test_that("buildSpouseSegments with use_hash=TRUE handles unmatched parent IDs", {
  # Test case where parent IDs extracted from hash don't exist in connections
  ped <- data.frame(
    personID = c("C1", "C2"),
    parent_hash = c("UnknownMom.UnknownDad", "Mom.Dad"),
    stringsAsFactors = FALSE
  )

  connections_for_FOO <- data.frame(
    personID = c("Mom", "Dad", "C1", "C2"), # No UnknownMom or UnknownDad
    x_pos = c(1, 2, 1.5, 1.8),
    y_pos = c(1, 1, 2, 2),
    stringsAsFactors = FALSE
  )

  result <- buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE)

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)

  # C1's parents don't exist, so some coordinates might be NA
  C1_row <- result[1, ]
  # The function should still return a row even if coordinates are NA
  expect_true("x_start" %in% names(result))
  expect_true("x_end" %in% names(result))
})
