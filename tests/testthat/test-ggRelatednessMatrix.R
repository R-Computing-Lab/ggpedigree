test_that("ggRelatednessMatrix returns a gg object", {
  library(BGmisc)
  data("redsquirrels")

  # Set up the data
  sumped <- BGmisc::summarizePedigrees(redsquirrels,
    famID = "famID",
    personID = "personID",
    nbiggest = 5
  )


  # Set target family for visualization
  fam_filter <- sumped$biggest_families$famID[3]

  # Filter for reasonably sized family, recode sex if needed
  ped_filtered <- redsquirrels %>%
    BGmisc::recodeSex(code_female = "F") %>%
    dplyr::filter(famID == fam_filter)

  # Calculate relatedness matrices
  add_mat <- BGmisc::ped2add(ped_filtered, isChild_method = "partialparent", sparse = FALSE)

  p_add <- ggRelatednessMatrix(
    add_mat,
    config = list(
      color_palette = c("white", "orange", "red"),
      scale_midpoint = 0.55,
      cluster = TRUE,
      title = "Additive Genetic Relatedness",
      text_size = 15
    )
  )
  expect_s3_class(p_add, "gg")
})
