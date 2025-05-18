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

test_that("ggPedigree returns a ggplot object", {
  library(BGmisc)
  data("potter")

  # Test with hints
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID"
  )
  expect_s3_class(p, "gg")
})
