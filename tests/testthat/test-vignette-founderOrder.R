test_that("vignette section 12 code runs without error", {
  library(BGmisc)
  data("potter", envir = environment())

  # Default layout
  p_default <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(label_include = TRUE, label_text_size = 2.5)
  ))
  expect_s3_class(p_default, "gg")

  # Seed 7
  p_seed7 <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(founder_order_seed = 7L, label_include = TRUE, label_text_size = 2.5)
  ))
  expect_s3_class(p_seed7, "gg")

  # Seed 42
  p_seed42 <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(founder_order_seed = 42L, label_include = TRUE, label_text_size = 2.5)
  ))
  expect_s3_class(p_seed42, "gg")

  # Score table
  scores <- sapply(0:4, function(s) {
    coords <- calculateCoordinates(potter,
      personID = "personID", momID = "momID", dadID = "dadID",
      config = list(founder_order_seed = s)
    )
    ggpedigree:::.layoutScore(coords)
  })
  expect_length(scores, 5)
  expect_true(all(is.finite(scores)))
  expect_true(all(scores >= 0))

  # Auto-search
  p_best <- suppressWarnings(ggPedigree(potter,
    famID = "famID", personID = "personID",
    momID = "momID", dadID = "dadID",
    config = list(
      founder_order_seed = 1L, founder_order_tries = 5L,
      label_include = TRUE, label_text_size = 2.5
    )
  ))
  expect_s3_class(p_best, "gg")
})
