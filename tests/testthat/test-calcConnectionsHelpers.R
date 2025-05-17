test_that("makeSymmetricKey handles numeric inputs correctly", {
id1 <- c(1, 2, 3, 50)
id2 <- c(2, 1, 3, 3)
  expect_equal(makeSymmetricKey(1, 2), "1.2")
  expect_equal(makeSymmetricKey(1, 2, sep = "_"), "1_2")
  expect_equal(makeSymmetricKey(c(2,5), c(1,5)), c("1.2","5.5"))
  expect_equal(makeSymmetricKey(id1, id2), c("1.2", "1.2","3.3", "3.50"))
  expect_equal(makeSymmetricKey(id1, id2, sep = "_"), c("1_2", "1_2","3_3", "3_50"))
  expect_equal(makeSymmetricKey(as.character(id1), as.character(id2), sep = "-"), c("1-2", "1-2","3-3", "3-50"))
  expect_equal(makeSymmetricKey(as.character(id1), as.character(id2)), c("1.2", "1.2","3.3", "3.50"))
})

test_that("makeSymmetricKey handles character inputs correctly", {
  id1 <- c("A", "B", "C", "D","abc")
  id2 <- c("B", "A", "C", "C","abd")
  expect_equal(makeSymmetricKey("abc", "abd"), "abc.abd")
  expect_equal(makeSymmetricKey("abd", "abc"), "abc.abd")
  expect_equal(makeSymmetricKey("same", "same"), "same.same")
  expect_equal(makeSymmetricKey(id1, id2), c("A.B", "A.B", "C.C", "C.D","abc.abd"))
})

test_that("makeSymmetricKey differentiates character ordering", {
  expect_equal(makeSymmetricKey("abc", "cab"), "abc.cab")
  expect_equal(makeSymmetricKey("cab", "abc"), "abc.cab")
})

test_that("makeSymmetricKey throws error on missing arguments", {
  expect_error(makeSymmetricKey(1), "Both id1 and id2 must be provided")
  expect_error(makeSymmetricKey(), "Both id1 and id2 must be provided")
})

test_that("makeSymmetricKey throws error on mixed types", {
  expect_error(makeSymmetricKey(1, "a"), "must be of the same type")
  expect_error(makeSymmetricKey("a", 1), "must be of the same type")
})

test_that("makeSymmetricKey handles special characters consistently", {
  expect_equal(makeSymmetricKey("a#", "a$"), "a#.a$")
  expect_equal(makeSymmetricKey("💡", "💬"), "💡.💬")
  expect_equal(makeSymmetricKey("💬", "💡"), "💡.💬")
})
