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
      tile_color_palette = c("white", "orange", "red"),
      color_scale_midpoint = 0.55,
      tile_cluster = TRUE,
      plot_title = "Additive Genetic Relatedness",
      label_text_size = 15
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

test_that("ggRelatednessMatrix supports scale transformations", {
  library(BGmisc)
  data("redsquirrels")

  # Set target family for visualization
  fam_filter <- 160

  # Filter for reasonably sized family, recode sex if needed
  ped_filtered <- redsquirrels %>%
    BGmisc::recodeSex(code_female = "F") %>%
    dplyr::filter(famID == fam_filter)

  # Calculate relatedness matrices
  add_mat <- BGmisc::ped2add(ped_filtered, isChild_method = "partialparent", sparse = FALSE)

  # Test with sqrt transformation (default for relatedness matrix)
  p_sqrt <- ggRelatednessMatrix(
    add_mat,
    config = list(
      tile_color_palette = c("white", "orange", "red"),
      color_scale_midpoint = 0.25,
      tile_cluster = FALSE,
      plot_title = "Sqrt Transform"
    )
  )
  expect_s3_class(p_sqrt, "gg")
  # Check that the scale has sqrt transformation
  expect_equal(p_sqrt$scales$scales[[1]]$trans$name, "sqrt")

  # Test with identity (linear) transformation
  p_identity <- ggRelatednessMatrix(
    add_mat,
    config = list(
      tile_color_palette = c("white", "orange", "red"),
      color_scale_midpoint = 0.25,
      tile_cluster = FALSE,
      color_scale_trans = "identity",
      plot_title = "Linear Transform"
    )
  )
  expect_s3_class(p_identity, "gg")
  # Check that the scale has identity transformation
  expect_equal(p_identity$scales$scales[[1]]$trans$name, "identity")

  # Test with log transformation
  p_log <- ggRelatednessMatrix(
    add_mat,
    config = list(
      tile_color_palette = c("white", "orange", "red"),
      color_scale_midpoint = 0.25,
      tile_cluster = FALSE,
      color_scale_trans = "log",
      plot_title = "Log Transform"
    )
  )
  expect_s3_class(p_log, "gg")
  # Check that the scale has log transformation
  expect_equal(p_log$scales$scales[[1]]$trans$name, "log-10")
})

