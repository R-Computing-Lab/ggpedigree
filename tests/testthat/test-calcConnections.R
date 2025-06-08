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
    spouseID = "spouseID"
  )

  conn_out <- calculateConnections(ped)
  conns <- conn_out$connections

  expect_true(is.data.frame(conns))
  expect_true(all(c(
    "personID", "x_pos", "y_pos", "momID", "dadID", "spouseID",
    "x_mom", "y_mom", "x_dad", "y_dad", "x_spouse", "y_spouse",
    "x_fam", "y_fam", "x_mid_spouse", "y_mid_spouse",
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
