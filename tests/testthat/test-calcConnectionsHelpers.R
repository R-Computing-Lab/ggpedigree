test_that(".makeSymmetricKey handles numeric inputs correctly", {
  id1 <- c(1, 2, 3, 50)
  id2 <- c(2, 1, 3, 3)
  expect_equal(.makeSymmetricKey(1, 2), "1.2")
  expect_equal(.makeSymmetricKey(1, 2, sep = "_"), "1_2")
  expect_equal(.makeSymmetricKey(c(2, 5), c(1, 5)), c("1.2", "5.5"))
  expect_equal(.makeSymmetricKey(id1, id2), c("1.2", "1.2", "3.3", "3.50"))
  expect_equal(.makeSymmetricKey(id1, id2, sep = "_"), c("1_2", "1_2", "3_3", "3_50"))
  expect_equal(.makeSymmetricKey(as.character(id1), as.character(id2), sep = "-"), c("1-2", "1-2", "3-3", "3-50"))
  expect_equal(.makeSymmetricKey(as.character(id1), as.character(id2)), c("1.2", "1.2", "3.3", "3.50"))
})

test_that(".makeSymmetricKey handles character inputs correctly", {
  id1 <- c("A", "B", "C", "D", "abc")
  id2 <- c("B", "A", "C", "C", "abd")
  expect_equal(.makeSymmetricKey("abc", "abd"), "abc.abd")
  expect_equal(.makeSymmetricKey("abd", "abc"), "abc.abd")
  expect_equal(.makeSymmetricKey("same", "same"), "same.same")
  expect_equal(.makeSymmetricKey(id1, id2), c("A.B", "A.B", "C.C", "C.D", "abc.abd"))
})

test_that(".makeSymmetricKey differentiates character ordering", {
  expect_equal(.makeSymmetricKey("abc", "cab"), "abc.cab")
  expect_equal(.makeSymmetricKey("cab", "abc"), "abc.cab")
})

test_that(".makeSymmetricKey throws error on missing arguments", {
  expect_error(.makeSymmetricKey(1), "Both id1 and id2 must be provided")
  expect_error(.makeSymmetricKey(), "Both id1 and id2 must be provided")
})

test_that(".makeSymmetricKey throws error on mixed types", {
  expect_error(.makeSymmetricKey(1, "a"))
  expect_error(.makeSymmetricKey("a", 1))
})

test_that(".makeSymmetricKey handles special characters consistently", {
  expect_equal(.makeSymmetricKey("a#", "a$"), "a#.a$")
  expect_equal(.makeSymmetricKey("💡", "💬"), "💡.💬")
  expect_equal(.makeSymmetricKey("💬", "💡"), "💡.💬")
})


test_that("calculateCoordinates respects ped_align and ped_packed flags", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  coords1 <- calculateCoordinates(ped,
    config = list(ped_align = TRUE, ped_packed = TRUE),
    personID = "ID", spouseID = "spID"
  )


  midsbydadid <- getMidpoints(
    data = coords1, group_vars = c("dadID"), x_vars = "x_pos", y_vars = "y_pos",
    x_out = "x_midpoint", y_out = "y_midpoint"
  )
  expect_equal(
    length(unique(ped$dadID[!is.na(ped$dadID)])), # all non-missing dadIDs
    length(midsbydadid$dadID)
  )

  midsbyspid <- getMidpoints(
    data = coords1, group_vars = c("spID"), x_vars = "x_pos", y_vars = "y_pos",
    x_out = "x_midpoint", y_out = "y_midpoint", method = "median"
  )
  expect_equal(
    length(unique(ped$spID[!is.na(ped$spID)])), # all non-missing spouseIDs
    length(midsbyspid$spID)
  )

  midsbymomid <- getMidpoints(
    data = coords1, group_vars = c("momID"), x_vars = "x_pos", y_vars = "y_pos",
    x_out = "x_midpoint", y_out = "y_midpoint", method = "weighted_mean"
  )
  expect_equal(
    length(unique(ped$momID[!is.na(ped$momID)])), # all non-missing momids
    length(midsbymomid$momID)
  )
  #
  # first_pairbymomid <- getMidpoints(
  #   data = coords1, group_vars = c("momID"), x_vars = "x_pos", y_vars = "y_pos",
  #   x_out = "x_midpoint", y_out = "y_midpoint", method = "first_pair"
  # )
  # expect_equal(
  #   length(unique(ped$momID[!is.na(ped$momID)])), # all non-missing momids
  #   length(first_pairbymomid$momID)
  # )
  # # meanxfirst
  # meanxfirstbydadid <- getMidpoints(
  #   data = coords1, group_vars = c("dadID"), x_vars = "x_pos", y_vars = "y_pos",
  #   x_out = "x_midpoint", y_out = "y_midpoint", method = "meanxfirst"
  # )
  # expect_equal(
  #   length(unique(ped$dadID[!is.na(ped$dadID)])), # all non-missing dadIDs
  #   length(meanxfirstbydadid$dadID)
  # )
  #
  # # meanyfirst
  # meanyfirstbyspid <- getMidpoints(
  #   data = coords1, group_vars = c("spID"), x_vars = "x_pos", y_vars = "y_pos",
  #   x_out = "x_midpoint", y_out = "y_midpoint", method = "meanyfirst"
  # )
  # expect_equal(
  #   length(unique(ped$spID[!is.na(ped$spID)])), # all non-missing spouseIDs
  #   length(meanyfirstbyspid$spID)
  # )

  expect_error(
    getMidpoints(
      data = coords1, group_vars = c("spID"), x_vars = "x_pos", y_vars = "y_pos",
      x_out = "x_midpoint", y_out = "y_midpoint", method = "unsupported "
    ),
    "Unsupported method."
  )
})

test_that("computeDistances behaves in small data", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "X"),
    momID = c(NA, "A", "A", "C", NA),
    dadID = c(NA, "X", "X", "B", NA),
    spouseID = c("X", "C", "B", NA, "A"),
    sex = c("F", "M", "F", "F", "M")
  )

  coords1 <- calculateCoordinates(ped,
    config = list(ped_align = TRUE, ped_packed = TRUE),
    personID = "ID", spouseID = "spouseID"
  )

  # Test with euclidean distance
  dist_euclidean <- computeDistance(
    method = "euclidean",
    x1 = coords1$x_pos,
    y1 = coords1$y_pos,
    x2 = coords1$x_pos,
    y2 = coords1$y_pos
  )
  expect_equal(length(dist_euclidean), nrow(coords1))

  # Test with manhattan/cityblock distance
  # Note: The method "manhattan" is equivalent to "cityblock"
  dist_cityblock <- computeDistance(
    method = "cityblock",
    x1 = coords1$x_pos,
    y1 = coords1$y_pos,
    x2 = coords1$x_pos,
    y2 = coords1$y_pos
  )
  dist_manhattan <- computeDistance(
    method = "manhattan",
    x1 = coords1$x_pos,
    y1 = coords1$y_pos,
    x2 = coords1$x_pos,
    y2 = coords1$y_pos
  )
  expect_equal(length(dist_manhattan), nrow(coords1))
  expect_equal(length(dist_cityblock), nrow(coords1))
  expect_equal(dist_manhattan, dist_cityblock)

  # p parameter
  # Test with p = 1 (manhattan distance)
  dist_manhattan_p1 <- computeDistance(
    p = 1,
    x1 = coords1$x_pos,
    y1 = coords1$y_pos,
    x2 = coords1$x_pos,
    y2 = coords1$y_pos
  )
  expect_equal(length(dist_manhattan_p1), nrow(coords1))
  expect_equal(dist_manhattan, dist_manhattan_p1)
  # Test with p = 2 (euclidean distance)
  dist_euclidean_p2 <- computeDistance(
    p = 2,
    x1 = coords1$x_pos,
    y1 = coords1$y_pos,
    x2 = coords1$x_pos,
    y2 = coords1$y_pos
  )
  expect_equal(length(dist_euclidean_p2), nrow(coords1))
  expect_equal(dist_euclidean, dist_euclidean_p2)
  # Test with p = 0.5 (fractional distance)

  dist_fractional <- computeDistance(
    p = 0.5,
    x1 = coords1$x_pos,
    y1 = coords1$y_pos,
    x2 = coords1$x_pos,
    y2 = coords1$y_pos
  )
  expect_equal(length(dist_fractional), nrow(coords1))
  expect_equal(dist_fractional, dist_euclidean)
})


# test_that("computeDistances behaves in big data", {
#   data("redsquirrels")
#   ped <- redsquirrels %>%
#     dplyr::rename(ID = personID) # needs phatnom parents
#
#   coords1 <- calculateCoordinates(ped, config = list(ped_align = FALSE, ped_packed = FALSE))
#
#   # Test with euclidean distance
#   dist_euclidean <- computeDistance( method = "euclidean",
#                                      x1 = coords1$x_pos,
#                                      y1 = coords1$y_pos,
#                                      x2 = coords1$x_pos,
#                                      y2 = coords1$y_pos)
#   expect_equal(length(dist_euclidean), nrow(coords1))
#
#   # Test with manhattan/cityblock distance
#   # Note: The method "manhattan" is equivalent to "cityblock"
#   dist_cityblock <- computeDistance( method = "cityblock",
#                                      x1 = coords1$x_pos,
#                                      y1 = coords1$y_pos,
#                                      x2 = coords1$x_pos,
#                                      y2 = coords1$y_pos)
#   dist_manhattan <- computeDistance( method = "manhattan",
#                                      x1 = coords1$x_pos,
#                                      y1 = coords1$y_pos,
#                                      x2 = coords1$x_pos,
#                                      y2 = coords1$y_pos)
#   expect_equal(length(dist_manhattan), nrow(coords1))
#   expect_equal(length(dist_cityblock), nrow(coords1))
#   expect_equal(dist_manhattan, dist_cityblock)
#
#   # p parameter
#   # Test with p = 1 (manhattan distance)
#   dist_manhattan_p1 <- computeDistance( p = 1,
#                                         x1 = coords1$x_pos,
#                                         y1 = coords1$y_pos,
#                                         x2 = coords1$x_pos,
#                                         y2 = coords1$y_pos)
#   expect_equal(length(dist_manhattan_p1), nrow(coords1))
#   expect_equal(dist_manhattan, dist_manhattan_p1)
#   # Test with p = 2 (euclidean distance)
#   dist_euclidean_p2 <- computeDistance( p = 2,
#                                         x1 = coords1$x_pos,
#                                         y1 = coords1$y_pos,
#                                         x2 = coords1$x_pos,
#                                         y2 = coords1$y_pos)
#   expect_equal(length(dist_euclidean_p2), nrow(coords1))
#   expect_equal(dist_euclidean, dist_euclidean_p2)
#   # Test with p = 0.5 (fractional distance)
#
#   dist_fractional <- computeDistance( p = 0.5,
#                                       x1 = coords1$x_pos,
#                                       y1 = coords1$y_pos,
#                                       x2 = coords1$x_pos,
#                                       y2 = coords1$y_pos)
#   expect_equal(length(dist_fractional), nrow(coords1))
#   expect_equal(dist_fractional, dist_euclidean)
#
#
# })
