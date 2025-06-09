test_that("ggRelatednessMatrix returns a gg object", {
  library(BGmisc)
  data("redsquirrels")

  # Set up the data
  #  sumped <- BGmisc::summarizePedigrees(redsquirrels,
  #    famID = "famID",
  #    personID = "personID",
  #    nbiggest = 5
  #  )


  # Set target family for visualization
  fam_filter <- 160 # sumped$biggest_families$famID[3]

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
      color_scale_midpoint = 0.55,
      tile_cluster = TRUE,
      plot_title = "Additive Genetic Relatedness",
      text_size = 15
    )
  )
  expect_s3_class(p_add, "gg")
  expect_s3_class(p_add, "ggplot")
  expect_true(is_ggplot(p_add))

  # Check if the plot has the expected title
  expect_equal(p_add$labels$title, "Additive Genetic Relatedness")

  expect_equal(paste0(p_add$layers[[1]][["constructor"]][[1]]), c("::", "ggplot2", "geom_tile"))
  expect_true(p_add$theme$axis.text.x$angle == 90)
  expect_true(p_add$theme$axis.text.y$angle == 0)
})

test_that("ggRelatednessMatrix handles triangles", {
  library(BGmisc)
  data("redsquirrels")

  # Set up the data
  #  sumped <- BGmisc::summarizePedigrees(redsquirrels,
  #    famID = "famID",
  #    personID = "personID",
  #    nbiggest = 5
  #  )


  # Set target family for visualization
  fam_filter <- 160 # sumped$biggest_families$famID[3]

  # Filter for reasonably sized family, recode sex if needed
  ped_filtered <- redsquirrels %>%
    BGmisc::recodeSex(code_female = "F") %>%
    dplyr::filter(famID == fam_filter)

  # Calculate relatedness matrices
  add_mat <- BGmisc::ped2add(ped_filtered, isChild_method = "partialparent", sparse = FALSE)

  p_add <- ggRelatednessMatrix(
    add_mat,
    config = list(
      tile_color_palette = c("white", "orange", "red"),
      color_scale_midpoint = 0.55,
      tile_cluster = FALSE,
      plot_title = "Additive Genetic Relatedness",
      axis_text_size = 15,
      matrix_upper_triangle_include = FALSE, # Test upper triangle exclusion
      matrix_lower_triangle_include = TRUE # Test lower triangle inclusion
    )
  )
  expect_s3_class(p_add, "gg")
  expect_s3_class(p_add, "ggplot")
  expect_true(is_ggplot(p_add))
  # Check if the plot has the expected title
  expect_equal(p_add$labels$title, "Additive Genetic Relatedness")
  expect_equal(paste0(p_add$layers[[1]][["constructor"]][[1]]), c("::", "ggplot2", "geom_tile"))
  expect_true(p_add$theme$axis.text.x$angle == 90)
  expect_true(p_add$theme$axis.text.y$angle == 0)
  # Check if the upper triangle is excluded
  expect_true(all(is.na(p_add$data$value[upper.tri(p_add$data$value)])))
  # Check if the lower triangle is included
  expect_true(all(!is.na(p_add$data$value[lower.tri(p_add$data$value)])))
})

test_that("ggRelatednessMatrix handles matrix diagonal", {
  library(BGmisc)
  data("redsquirrels")

  # Set up the data
  #  sumped <- BGmisc::summarizePedigrees(redsquirrels,
  #    famID = "famID",
  #    personID = "personID",
  #    nbiggest = 5
  #  )


  # Set target family for visualization
  fam_filter <- 160 # sumped$biggest_families$famID[3]

  # Filter for reasonably sized family, recode sex if needed
  ped_filtered <- redsquirrels %>%
    BGmisc::recodeSex(code_female = "F") %>%
    dplyr::filter(famID == fam_filter)

  # Calculate relatedness matrices
  add_mat <- BGmisc::ped2add(ped_filtered, isChild_method = "partialparent", sparse = FALSE)

  p_add <- ggRelatednessMatrix(
    add_mat,
    config = list(
      # tile_color_palette = c("white", "orange", "red"),
      color_scale_midpoint = 0.55,
      tile_cluster = FALSE,
      plot_title = "Additive Genetic Relatedness",
      axis_text_size = 15,
      matrix_diagonal_include = FALSE, # Test diagonal exclusion
      matrix_upper_triangle_include = TRUE, # Test upper triangle exclusion
      matrix_lower_triangle_include = FALSE, # Test lower triangle inclusion
      label_include = TRUE,
      tile_geom = "geom_raster"
    )
  )
  expect_s3_class(p_add, "gg")
  expect_s3_class(p_add, "ggplot")
  expect_true(is_ggplot(p_add))
  # Check if the plot has the expected title
  expect_equal(p_add$labels$title, "Additive Genetic Relatedness")
  expect_equal(paste0(p_add$layers[[1]][["constructor"]][[1]]), c("::", "ggplot2", "geom_raster"))
  expect_true(p_add$theme$axis.text.x$angle == 90)
  expect_true(p_add$theme$axis.text.y$angle == 0)
  # Check if the upper triangle is excluded
  expect_true(all(!is.na(p_add$data$value[upper.tri(p_add$data$value)])))
  # Check if the lower triangle is included
  # expect_true(all(is.na(p_add$data$value[lower.tri(p_add$data$value)])))

  expect_error(
    ggRelatednessMatrix(add_mat, config = list(tile_geom = "geom_point"))
  )
})

test_that("ggRelatednessMatrix stops on incorrect input", {
  expect_error(
    ggRelatednessMatrix("not_a_matrix")
  )

  expect_error(
    ggRelatednessMatrix(data.frame(ID = 1:3))
  )
})
