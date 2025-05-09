
test_that("countOffspring returns correct counts", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D"),
    momID = c(NA, "A", "A", "B"),
    dadID = c(NA, "X", "X", "C")
  )

  out <- countOffspring(ped)

  expect_equal(out$offspring[which(out$ID == "A")], 2)  # B and C
  expect_equal(out$offspring[which(out$ID == "B")], 1)  # D
  expect_equal(out$offspring[which(out$ID == "C")], 1)  # D
  expect_equal(out$offspring[which(out$ID == "D")], 0)  # no children
})

test_that("countSiblings returns correct sibling counts and orders", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D"),
    momID = c("M1", "M1", "M2", NA),
    dadID = c("F1", "F1", "F2", NA)
  )

  out <- countSiblings(ped)

  expect_equal(out$siblings[which(out$ID == "A")], 1)
  expect_equal(out$siblings[which(out$ID == "B")], 1)
  expect_equal(out$siblings[which(out$ID == "C")], 0)
  expect_equal(out$siblings[which(out$ID == "D")], 0)

  expect_equal(out$siborder[which(out$ID == "A")], 1)
  expect_equal(out$siborder[which(out$ID == "B")], 2)
})

test_that("generateSpouseList returns correct spouse matrix", {
  ped <- data.frame(
    ID = c("A", "B", "C", "D", "E"),
    sex = c("F", "M", "F", "M", "F"),
    momID = c(NA, "A", "A", "C", "E"),
    dadID = c(NA, "B", "B", "D", "D")
  )

  out <- generateSpouseList(ped, personID = "ID", momID = "momID", dadID = "dadID", spouseID = "spouseID")

  expect_type(out, "character")
  expect_equal(ncol(out), 4)
  expect_equal(colnames(out), c("ID1", "ID2", "sex1", "sex2"))

  # Check a known couple: A and B
  expect_true(any((out[, "ID1"] == "A" & out[, "ID2"] == "B") |
                    (out[, "ID1"] == "B" & out[, "ID2"] == "A")))
})
