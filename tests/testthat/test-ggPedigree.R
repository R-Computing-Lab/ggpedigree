library(BGmisc)
library(tidyverse)
library(mockery)

data("potter")
data("inbreeding")


test_that("ggPedigree repairs a trailing comma in config instead of erroring", {
  expect_message(
    p <- ggPedigree(potter,
      famID = "famID",
      personID = "personID",
      config = list(point_size = 11, label_include = TRUE, )
    ),
    "trailing comma"
  )
  expect_s3_class(p, "gg")
})

test_that("ggPedigree still errors on a genuinely broken config", {
  expect_error(
    ggPedigree(potter,
      famID = "famID",
      personID = "personID",
      config = list(point_size = this_var_does_not_exist)
    ),
    "this_var_does_not_exist"
  )
})

test_that("broken hints doesn't cause a fatal error", {
  if ("twinID" %in% names(potter) && "zygosity" %in% names(potter)) {
    # Remove twinID and zygosity columns for this test
    potter <- potter %>%
      select(-twinID, -zygosity)
  } else if ("twinID" %in% names(potter) && !"zygosity" %in% names(potter)) {
    # Add twinID and zygosity columns for demonstration purposes
    potter <- potter %>%
      select(-twinID)
  }

  # Test with hints
  expect_warning(
    ggPedigree(potter,
      famID = "famID",
      personID = "personID",
      config = list(hints = TRUE)
    )
  ) %>% suppressWarnings()

  if (!"twinID" %in% names(potter)) {
    # Add twinID and zygosity columns for demonstration purposes
    potter <- potter %>%
      mutate(
        twinID = case_when(
          name == "Fred Weasley" ~ 13,
          name == "George Weasley" ~ 12,
          TRUE ~ NA_real_
        ),
        zygosity = case_when(
          name == "Fred Weasley" ~ "mz",
          name == "George Weasley" ~ "mz",
          TRUE ~ NA_character_
        )
      )
  }
  potter <- potter %>%
    mutate(
      status = sample(c("alive", "deceased"), nrow(potter), replace = TRUE),
    )
  expect_warning(
    ggPedigree(potter,
      famID = "famID",
      #  phantoms = TRUE, # not  in CRAN version
      personID = "personID",
      config = list(
        hints = TRUE,
        generation_width = 2,
        generation_height = 2,
        status_code_affected = "deceased",
        status_code_unaffected = "alive",
        status_include = TRUE
      ),
      status_column = "status"
    )
  ) %>% suppressWarnings()
})

test_that("ggPedigree returns a ggplot object", {
  if ("twinID" %in% names(potter) && "zygosity" %in% names(potter)) {
    # Remove twinID and zygosity columns for this test
    potter <- potter %>%
      select(-twinID, -zygosity)
  } else if ("twinID" %in% names(potter) && !"zygosity" %in% names(potter)) {
    # Add twinID and zygosity columns for demonstration purposes
    potter <- potter %>%
      select(-twinID)
  }

  # Test with hints
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID"
  )
  expect_s3_class(p, "gg")

  expect_true(all(p$data$personID %in% potter$personID)) # ID retention
  expect_equal(nrow(p$data), nrow(potter)) # no duplicates yet
  expect_true(all(c("x_pos", "y_pos", "nid") %in% names(p$data))) # coordinate columns present
})

test_that("ggPedigree errors when ped not df", {
  expect_error(
    ggPedigree("potter_missing"),
    "ped should be a data.frame or inherit to a data.frame"
  )
  expect_error(
    ggPedigree.core(1:10),
    "ped should be a data.frame or inherit to a data.frame"
  )
})


test_that("give static plot when plotly fails", {
  # Stub requireNamespace inside ggPedigree to simulate plotly not installed
  stub(ggPedigree, "requireNamespace", FALSE)

  p <- ggPedigree(potter, interactive = TRUE)

  expect_s3_class(p, "gg") # Should return a ggplot object
})

#  Apply vertical spacing factor if generation_height ≠ 1

test_that("vertical spacing factor if generation_height ≠ 1", {
  p <- ggPedigree(potter, config = list(generation_width = 1))
  p_2 <- ggPedigree(potter, config = list(generation_width = 2))
  p_3 <- ggPedigree(potter, config = list(generation_height = 2))
  p_4 <- ggPedigree(potter, config = list(generation_height = 3, generation_width = 3))

  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_s3_class(p_2, "gg") # Should return a ggplot object
  expect_s3_class(p_3, "gg") # Should return a ggplot object
  expect_true(all(p$data$x_pos * 2 == p_2$data$x_pos)) # y_pos should be scaled by generation_width
  expect_true(all(p$data$y_pos * 2 == p_3$data$y_pos)) # y_pos should be scaled by generation_height
  expect_true(all(p$data$x_pos * 3 == p_4$data$x_pos)) # x_pos should be scaled by generation_width
  expect_true(all(p$data$y_pos * 3 == p_4$data$y_pos)) # y_pos should be scaled by generation_height
})

test_that("config$outline_include works", {
  p <- ggPedigree(potter, config = list(outline_include = TRUE))
  expect_s3_class(p, "gg") # Should return a ggplot object
})

# handle non-standard names
test_that("ggPedigree handles non-standard names", {
  # Rename columns to non-standard names
  potter <- potter %>%
    rename(
      family_id = famID,
      individual_id = personID,
      mother_id = momID,
      father_id = dadID,
      spouse_id = spouseID
    )

  p <- ggPedigree(potter,
    famID = "family_id",
    personID = "individual_id",
    momID = "mother_id",
    dadID = "father_id",
    spouseID = "spouse_id"
  )
  expect_s3_class(p, "gg")
  expect_true(all(p$data$individual_id %in% potter$individual_id)) # ID retention
  expect_true(all(p$data$family_id %in% potter$family_id)) # ID retention
  expect_true(all(p$data$father_id %in% potter$father_id)) # ID retention
  expect_true(all(p$data$mother_id %in% potter$mother_id)) # ID retention
  expect_true(all(p$data$spouse_id %in% potter$spouse_id)) # ID retention
})

#  # Self-segment (for duplicate layout appearances of same person)
test_that("ggPedigree handles self-segment", {
  # Add a duplicate appearance for a person
  df <- inbreeding

  p <- ggPedigree(
    df,
    famID = "famID",
    personID = "ID",
    status_column = "proband",
    #  debug = TRUE,
    config = list(
      code_male = 0,
      code_female = 1,
      override_many2many = TRUE,
      sex_color_include = FALSE,
      status_code_affected = TRUE,
      status_code_unaffected = FALSE,
      generation_height = 4,
      point_size = 2,
      generation_width = 2,
      status_shape_affected = 4,
      segment_self_color = "purple"
    )
  )
  expect_s3_class(p, "gg") # Should return a ggplot object

  p_debug <- ggPedigree(
    df,
    famID = "famID",
    personID = "ID",
    status_column = "proband",
    #  debug = TRUE,
    config = list(
      code_male = 0,
      code_female = 1,
      debug = TRUE,
      override_many2many = TRUE,
      sex_color_include = FALSE,
      status_code_affected = TRUE,
      status_code_unaffected = FALSE,
      generation_height = 4,
      point_size = 2,
      generation_width = 2,
      status_shape_affected = 4,
      segment_self_color = "purple"
    )
  )
  expect_type(p_debug, "list") # Should return a list with plot and data


  p <- p_debug$plot
  expect_s3_class(p, "gg") # Should return a ggplot object
})

test_that("focal fill works with ID", {
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_personID = 1
    )
  )
  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p$data)) # focal_fill column should be present
  expect_true(all(p$data$focal_fill >= 0 & p$data$focal_fill <= 1)) # focal_fill values should be between 0 and 1

  p2 <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_force_zero = TRUE,
      focal_fill_personID = 1
    )
  )

  # Should return a ggplot object
  expect_s3_class(p2, "gg")

  # focal_fill column should be present
  expect_true("focal_fill" %in% names(p2$data))

  # focal_fill values should be ge 0 and 1
  expect_true(any(is.na(p2$data$focal_fill)))

  # focal_fill values should be greater than 0 and less than or equal to 1
  expect_true(all(p2$data$focal_fill[!is.na(p2$data$focal_fill)] > 0 & p2$data$focal_fill[!is.na(p2$data$focal_fill)] <= 1))

  # test focal_fill with a different personID

  p3 <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_personID = 8
    )
  )
  expect_s3_class(p3, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p3$data)) # focal_fill column should be present
  expect_true(all(p3$data$focal_fill >= 0 & p3$data$focal_fill <= 1)) # focal_fill values should be between 0 and 1

  # focal_fill for personID 8 should be 1
  expect_true(all(p3$data$focal_fill[p3$data$personID == 8] == 1))
})

test_that("focal fill works with non-standard personID column name", {
  # Rename personID column to a non-standard name
  potter_renamed <- potter
  names(potter_renamed)[names(potter_renamed) == "personID"] <- "ID"

  p <- ggPedigree(potter_renamed,
    famID = "famID",
    personID = "ID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_personID = 8
    )
  )
  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p$data)) # focal_fill column should be present
  expect_true(all(p$data$focal_fill >= 0 & p$data$focal_fill <= 1)) # focal_fill values should be between 0 and 1

  # focal_fill for ID 8 should be 1
  expect_true(all(p$data$focal_fill[p$data$ID == 8] == 1))
})

test_that("focal fill works with ID and different methods", {
  # Test with greyscale theme
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_personID = 1,
      focal_fill_method = "steps",
      color_theme = "greyscale"
    )
  )
  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p$data)) # focal_fill column should be present
  expect_true(all(p$data$focal_fill >= 0 & p$data$focal_fill <= 1)) # focal_fill values should be between 0 and 1

  # Test that greyscale color scale is applied
  # The plot should have a colour scale for the focal fill
  colour_scales <- p$scales$find("colour")
  expect_true(length(colour_scales) > 0, "Plot should have a colour scale for focal fill")

  # Build the plot to verify greyscale colors are used
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")

  # Verify that the scale uses greyscale by checking the scale aesthetics
  if (length(colour_scales) > 0) {
    scale <- p$scales$scales
    expect_true("colour" %in% scale[[3]]$aesthetics)
    # The scale should be a Binned scale (used for gradient/steps methods)
    expect_true(inherits(scale[[3]], "ScaleBinned"))
  }

  p2 <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_force_zero = TRUE,
      focal_fill_personID = 1,
      focal_fill_method = "gradient2"
    )
  )
  expect_s3_class(p2, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p2$data)) # focal_fill column should be present
  expect_true(any(is.na(p2$data$focal_fill))) # focal_fill values should be ge 0 and 1
  expect_true(all(p2$data$focal_fill[!is.na(p2$data$focal_fill)] > 0 & p2$data$focal_fill[!is.na(p2$data$focal_fill)] <= 1)) # focal_fill values should be greater than 0 and less than or equal to 1

  # test focal_fill with a different personID

  p3 <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_personID = 8,
      focal_fill_method = "viridis_b"
    )
  )
  expect_s3_class(p3, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p3$data)) # focal_fill column should be present
  expect_true(all(p3$data$focal_fill >= 0 & p3$data$focal_fill <= 1)) # focal_fill values should be between 0 and 1
  expect_true(all(p3$data$focal_fill[p3$data$personID == 8] == 1)) # focal_fill for personID 8 should be 1
})

test_that("fill works with fill_column", {
  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    focal_fill_column = "sex",
    config = list(
      focal_fill_method = "viridis_c",
      focal_fill_include = TRUE,
      sex_color_include = FALSE
    )
  )
  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p$data)) # focal_fill column should be present

  expect_true(all(p$data$focal_fill == p$data$sex)) # focal_fill values should match column values
  expect_true(all(p$data$focal_fill %in% c(1, 0))) # focal_fill values should be either 0 or 1
  expect_true(all(p$data$focal_fill[p$data$sex == 1] == 1)) # focal_fill for males should be 1
  expect_true(all(p$data$focal_fill[p$data$sex == 0] == 0)) # focal_fill for females should be 0
})

test_that("debug", {
  expect_message(ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    focal_fill_column = "sex",
    config = list(
      focal_fill_method = "hue",
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      focal_fill_use_log = TRUE,
      add_phantoms = TRUE,
      debug = TRUE
    )
  ))

  p_debug <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    focal_fill_column = "sex",
    config = list(
      focal_fill_method = "steps",
      focal_fill_include = TRUE,
      sex_color_include = FALSE,
      debug = TRUE,
      add_phantoms = TRUE,
      focal_fill_use_log = FALSE
    )
  )

  expect_type(p_debug, "list") # Should return a list with plot and data


  p <- p_debug$plot
  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p$data)) # focal_fill column should be present
  expect_true(all(p$data$focal_fill == p$data$sex)) # focal_fill values should match column values
  expect_true(all(p$data$focal_fill %in% c(1, 0))) # focal_fill values should be either 0 or 1
})


test_that("behaves with kinship 2 pedigree object", {
  # follow how kinship sets up the pedigree object
  library(kinship2)
  data(minnbreast)
  minnbreast_skinny <- minnbreast[minnbreast$famid %in% c(4), ] # take only one family
  breastped <- with(
    minnbreast_skinny,
    kinship2::pedigree(id, fatherid, motherid, sex,
      status = (cancer & !is.na(cancer)),
      affected = proband,
      famid = famid
    )
  )
  breastped$sex <- as.numeric(breastped$sex) # convert to numeric

  expect_no_error(
    ggpedigree(breastped,
      famID = "famid",
      personID = "id",
      momID = "mindex",
      sexVar = "sex",
      config = list(
        code_male = 1,
        code_female = 0,
        code_na = NA
      ),
      dadID = "findex",
      overlay_column = "affected",
      status_column = "status"
    )
  )

  expect_error(
    ggpedigree(breastped,
      famID = "famid",
      personID = "id",
      momID = "mindex",
      sexVar = "sex",
      config = list(
        code_male = 1,
        code_female = 0,
        focal_fill_include = TRUE,
        focal_fill_method = "zhue"
      ),
      dadID = "findex",
      overlay_column = "affected",
      status_column = "status"
    )
  )
})


test_that("reduce_variables reduces object size", {
  p_reduced <- ggPedigree(potter, config = list(reduce_variables = FALSE))
  p <- ggPedigree(potter, config = list(reduce_variables = TRUE))

  expect_s3_class(p, "gg") # Should return a ggplot object
  expect_s3_class(p_reduced, "gg") # Should return a ggplot object


  p_build <- ggplot2::ggplot_build(p)
  p_reduced_build <- ggplot2::ggplot_build(p_reduced)
  # get file size of ggplot objects
  expect_true(object.size(p_build) < object.size(p_reduced_build)) # reduced plot should be smaller in size
})


# Tests for renumberPedigreeIDs


make_renumber_df <- function(person_ids,
                             mom_ids,
                             dad_ids,
                             twin_ids = NULL,
                             spouse_ids = NULL,
                             sex = NULL) {
  df <- data.frame(
    personID = person_ids,
    momID = mom_ids,
    dadID = dad_ids
  )

  if (!is.null(twin_ids)) {
    df$twinID <- twin_ids
  }

  if (!is.null(spouse_ids)) {
    df$spouseID <- spouse_ids
  }

  if (!is.null(sex)) {
    df$sex <- sex
  }

  df
}

expect_ids_consistent <- function(original,
                                  renumbered,
                                  personID = "personID",
                                  momID = "momID",
                                  dadID = "dadID",
                                  twinID = "twinID",
                                  spouseID = "spouseID",
                                  sort_ids = TRUE,
                                  info = NULL) {
  old_ids <- unique(original[[personID]])
  old_ids <- old_ids[!is.na(old_ids)]

  if (sort_ids) {
    old_ids <- sort(old_ids)
  }

  id_key <- data.frame(
    oldID = old_ids,
    newID = seq_along(old_ids),
    stringsAsFactors = FALSE
  )

  lookup <- stats::setNames(id_key$newID, as.character(id_key$oldID))

  expected <- original
  expected[[personID]] <- as.integer(unname(lookup[as.character(original[[personID]])]))
  expected[[momID]] <- as.integer(unname(lookup[as.character(original[[momID]])]))
  expected[[dadID]] <- as.integer(unname(lookup[as.character(original[[dadID]])]))

  cols_to_check <- c(personID, momID, dadID)

  if (twinID %in% names(original)) {
    expected[[twinID]] <- as.integer(unname(lookup[as.character(original[[twinID]])]))
    cols_to_check <- c(cols_to_check, twinID)
  }

  if (spouseID %in% names(original)) {
    expected[[spouseID]] <- as.integer(unname(lookup[as.character(original[[spouseID]])]))
    cols_to_check <- c(cols_to_check, spouseID)
  }

  expect_equal(
    renumbered[, cols_to_check, drop = FALSE],
    expected[, cols_to_check, drop = FALSE],
    ignore_attr = TRUE,
    info = info
  )

  expect_equal(nrow(renumbered), nrow(original), info = info)
  expect_equal(names(renumbered), names(original), info = info)

  expect_true(is.numeric(renumbered[[personID]]), info = info)
  expect_true(is.numeric(renumbered[[momID]]), info = info)
  expect_true(is.numeric(renumbered[[dadID]]), info = info)

  if (twinID %in% names(renumbered)) {
    expect_true(is.numeric(renumbered[[twinID]]), info = info)
  }

  if (spouseID %in% names(renumbered)) {
    expect_true(is.numeric(renumbered[[spouseID]]), info = info)
  }

  invisible(NULL)
}

test_that("renumberPedigreeIDs renumbers numeric IDs consistently", {
  df <- make_renumber_df(
    person_ids = c(100, 200, 300),
    mom_ids = c(NA, NA, 100),
    dad_ids = c(NA, NA, 200),
    sex = c(2, 1, 2)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3),
    momID = c(NA_real_, NA_real_, 1),
    dadID = c(NA_real_, NA_real_, 2),
    sex = c(2, 1, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs renumbers character IDs consistently", {
  df <- make_renumber_df(
    person_ids = c("alpha", "beta", "gamma"),
    mom_ids = c(NA, NA, "alpha"),
    dad_ids = c(NA, NA, "beta"),
    sex = c(2, 1, 2)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3),
    momID = c(NA_real_, NA_real_, 1),
    dadID = c(NA_real_, NA_real_, 2),
    sex = c(2, 1, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs renumbers twin IDs consistently when present", {
  df <- make_renumber_df(
    person_ids = c(100, 200, 300, 400),
    mom_ids = c(NA, NA, 100, 100),
    dad_ids = c(NA, NA, 200, 200),
    twin_ids = c(NA, NA, 400, 300),
    sex = c(2, 1, 2, 2)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3, 4),
    momID = c(NA_real_, NA_real_, 1, 1),
    dadID = c(NA_real_, NA_real_, 2, 2),
    twinID = c(NA_real_, NA_real_, 4, 3),
    sex = c(2, 1, 2, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs renumbers spouse IDs consistently when present", {
  df <- make_renumber_df(
    person_ids = c(100, 200, 300),
    mom_ids = c(NA, NA, 100),
    dad_ids = c(NA, NA, 200),
    spouse_ids = c(200, 100, NA),
    sex = c(2, 1, 2)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3),
    momID = c(NA_real_, NA_real_, 1),
    dadID = c(NA_real_, NA_real_, 2),
    spouseID = c(2, 1, NA_real_),
    sex = c(2, 1, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs renumbers twin and spouse IDs together", {
  df <- make_renumber_df(
    person_ids = c("a", "b", "c", "d"),
    mom_ids = c(NA, NA, "a", "a"),
    dad_ids = c(NA, NA, "b", "b"),
    twin_ids = c(NA, NA, "d", "c"),
    spouse_ids = c("b", "a", NA, NA),
    sex = c(2, 1, 2, 2)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3, 4),
    momID = c(NA_real_, NA_real_, 1, 1),
    dadID = c(NA_real_, NA_real_, 2, 2),
    twinID = c(NA_real_, NA_real_, 4, 3),
    spouseID = c(2, 1, NA_real_, NA_real_),
    sex = c(2, 1, 2, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs recodes unknown twin and spouse references to NA", {
  df <- make_renumber_df(
    person_ids = c(10, 20, 30),
    mom_ids = c(NA, NA, 10),
    dad_ids = c(NA, NA, 20),
    twin_ids = c(NA, NA, 999),
    spouse_ids = c(20, 999, NA)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3),
    momID = c(NA_real_, NA_real_, 1),
    dadID = c(NA_real_, NA_real_, 2),
    twinID = c(NA_real_, NA_real_, NA_real_),
    spouseID = c(2, NA_real_, NA_real_)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs preserves non-ID columns", {
  df <- data.frame(
    personID = c(10, 20, 30),
    momID = c(NA, NA, 10),
    dadID = c(NA, NA, 20),
    twinID = c(NA, NA, NA),
    spouseID = c(20, 10, NA),
    sex = c(2, 1, 2),
    name = c("mother", "father", "child"),
    birth_year = c(1950, 1948, 1980)
  )

  out <- renumberPedigreeIDs(df)

  expect_equal(out$sex, df$sex)
  expect_equal(out$name, df$name)
  expect_equal(out$birth_year, df$birth_year)

  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs can use order of first appearance", {
  df <- make_renumber_df(
    person_ids = c(300, 100, 200),
    mom_ids = c(NA, NA, 100),
    dad_ids = c(NA, NA, 300),
    spouse_ids = c(100, 300, NA)
  )

  out <- renumberPedigreeIDs(df, sort_ids = FALSE)

  expected <- data.frame(
    personID = c(1, 2, 3),
    momID = c(NA_real_, NA_real_, 2),
    dadID = c(NA_real_, NA_real_, 1),
    spouseID = c(2, 1, NA_real_)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out, sort_ids = FALSE)
})

test_that("renumberPedigreeIDs sorts IDs by default", {
  df <- make_renumber_df(
    person_ids = c(300, 100, 200),
    mom_ids = c(NA, NA, 100),
    dad_ids = c(NA, NA, 300),
    spouse_ids = c(100, 300, NA)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(3, 1, 2),
    momID = c(NA_real_, NA_real_, 1),
    dadID = c(NA_real_, NA_real_, 3),
    spouseID = c(1, 3, NA_real_)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out, sort_ids = TRUE)
})

test_that("renumberPedigreeIDs returns key when requested", {
  df <- make_renumber_df(
    person_ids = c(10, 20, 30),
    mom_ids = c(NA, NA, 10),
    dad_ids = c(NA, NA, 20),
    spouse_ids = c(20, 10, NA)
  )

  out <- renumberPedigreeIDs(df, return_key = TRUE)

  expect_type(out, "list")
  expect_named(out, c("ped", "id_key"))

  expected_key <- data.frame(
    oldID = c(10, 20, 30),
    newID = c(1, 2, 3),
    stringsAsFactors = FALSE
  )

  expect_equal(out$id_key, expected_key, ignore_attr = TRUE)
  expect_ids_consistent(df, out$ped)
})

test_that("renumberPedigreeIDs recodes unknown parent references to NA", {
  df <- make_renumber_df(
    person_ids = c(10, 20, 30),
    mom_ids = c(NA, NA, 999),
    dad_ids = c(NA, NA, 20)
  )

  out <- renumberPedigreeIDs(df)

  expected <- data.frame(
    personID = c(1, 2, 3),
    momID = c(NA_real_, NA_real_, NA_real_),
    dadID = c(NA_real_, NA_real_, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)
  expect_ids_consistent(df, out)
})

test_that("renumberPedigreeIDs supports user-specified parent ID column names", {
  df <- data.frame(
    id = c("p3", "p1", "p2"),
    mother = c(NA, NA, "p1"),
    father = c(NA, NA, "p3"),
    sex = c(2, 1, 2)
  )

  out <- renumberPedigreeIDs(
    df,
    personID = "id",
    momID = "mother",
    dadID = "father",
    sort_ids = FALSE
  )

  expected <- data.frame(
    id = c(1, 2, 3),
    mother = c(NA_real_, NA_real_, 2),
    father = c(NA_real_, NA_real_, 1),
    sex = c(2, 1, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)

  expect_ids_consistent(
    df,
    out,
    personID = "id",
    momID = "mother",
    dadID = "father",
    sort_ids = FALSE
  )
})

test_that("renumberPedigreeIDs supports user-specified twin and spouse ID column names", {
  df <- data.frame(
    id = c("p1", "p2", "p3", "p4"),
    mother = c(NA, NA, "p1", "p1"),
    father = c(NA, NA, "p2", "p2"),
    co_twin = c(NA, NA, "p4", "p3"),
    partner = c("p2", "p1", NA, NA),
    sex = c(2, 1, 2, 2)
  )

  out <- renumberPedigreeIDs(
    df,
    personID = "id",
    momID = "mother",
    dadID = "father",
    twinID = "co_twin",
    spouseID = "partner",
    sort_ids = FALSE
  )

  expected <- data.frame(
    id = c(1, 2, 3, 4),
    mother = c(NA_real_, NA_real_, 1, 1),
    father = c(NA_real_, NA_real_, 2, 2),
    co_twin = c(NA_real_, NA_real_, 4, 3),
    partner = c(2, 1, NA_real_, NA_real_),
    sex = c(2, 1, 2, 2)
  )

  expect_equal(out, expected, ignore_attr = TRUE)

  expect_ids_consistent(
    df,
    out,
    personID = "id",
    momID = "mother",
    dadID = "father",
    twinID = "co_twin",
    spouseID = "partner",
    sort_ids = FALSE
  )
})

test_that("renumberPedigreeIDs errors on invalid inputs", {
  expect_error(
    renumberPedigreeIDs(list(personID = 1:3)),
    regexp = "ped must be a data frame"
  )

  df <- data.frame(
    personID = 1:3,
    momID = c(NA, NA, 1),
    dadID = c(NA, NA, 2)
  )

  expect_error(
    renumberPedigreeIDs(df, personID = c("personID", "id")),
    regexp = "personID must be a character scalar"
  )

  expect_error(
    renumberPedigreeIDs(df, momID = c("momID", "mother")),
    regexp = "momID must be a character scalar"
  )

  expect_error(
    renumberPedigreeIDs(df, dadID = c("dadID", "father")),
    regexp = "dadID must be a character scalar"
  )

  expect_error(
    renumberPedigreeIDs(df[, c("personID", "momID")]),
    regexp = "ped is missing required column"
  )
})
