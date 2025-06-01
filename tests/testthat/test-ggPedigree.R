
test_that("broken hints doesn't cause a fatal error", {
  library(BGmisc)
  data("potter") # load example data from BGmisc

  if ("twinID" %in% names(potter)) {
    # Remove twinID and zygosity columns for this test
    potter <- potter %>%
      select(-twinID, -zygosity)
  }

  # Test with hints
  expect_warning(
    ggPedigree(potter,
               famID = "famID",
               personID = "personID",
               config = list(hints = TRUE)
    )
  )

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
               personID = "personID",
               config = list(hints = TRUE),
               status_column = "status"
    )
  )

})

test_that("ggPedigree returns a ggplot object", {
  library(BGmisc)
  data("potter") # load example data from BGmisc
  if ("twinID" %in% names(potter)) {
    # Remove twinID and zygosity columns for this test
    potter <- potter %>%
      select(-twinID, -zygosity)
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
  library(BGmisc)
  library(mockery)
  data("potter") # load example data from BGmisc
  # Stub requireNamespace inside ggPedigree to simulate plotly not installed
  stub(ggPedigree, "requireNamespace", FALSE)

  p <- ggPedigree(potter, interactive = TRUE)

  expect_s3_class(p, "gg") # Should return a ggplot object
})

#  Apply vertical spacing factor if generation_height ≠ 1

test_that("vertical spacing factor if generation_height ≠ 1", {
  library(BGmisc)

  data("potter") # load example data from BGmisc
  # Stub requireNamespace inside ggPedigree to simulate plotly not installed

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
  library(BGmisc)

  data("potter") # load example data from BGmisc
  p <- ggPedigree(potter, config = list(outline_include = TRUE))
  expect_s3_class(p, "gg") # Should return a ggplot object
}
)

# handle non-standard names
test_that("ggPedigree handles non-standard names", {
  library(BGmisc)
  data("potter") # load example data from BGmisc

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
  library(BGmisc)
  data("inbreeding") # load example data from BGmisc

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
      override_many2many = TRUE,
      sex_color_include = FALSE,
      status_code_affected = TRUE,
      status_code_unaffected = FALSE,
      generation_height = 4,
      point_size = 2,
      generation_width = 2,
      status_affected_shape = 4,
      segment_self_color = "purple"
    )
  )
  expect_s3_class(p, "gg") # Should return a ggplot object
})

test_that("focal fill works with ID", {
  library(BGmisc)
  data("potter") # load example data from BGmisc

  p <- ggPedigree(potter,
    famID = "famID",
    personID = "personID",
    config = list(
      focal_fill_include = TRUE,
      sex_color_include=FALSE,
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
                    sex_color_include=FALSE,
                    focal_fill_force_zero = TRUE,
                    focal_fill_personID = 1
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
                    sex_color_include=FALSE,
                    focal_fill_personID = 8
                  )
  )
  expect_s3_class(p3, "gg") # Should return a ggplot object
  expect_true("focal_fill" %in% names(p3$data)) # focal_fill column should be present
  expect_true(all(p3$data$focal_fill >= 0 & p3$data$focal_fill <= 1)) # focal_fill values should be between 0 and 1
  expect_true(all(p3$data$focal_fill[p3$data$personID == 8] == 1)) # focal_fill for personID 8 should be 1
})

test_that("fill works with column",{
    library(BGmisc)
    data("potter")

    p <- ggPedigree(potter,
                    famID = "famID",
                    personID = "personID",
                    focal_fill_column = "sex",
                    config = list(
                     focal_fill_method = "steps",
                     focal_fill_include = TRUE,
                    sex_color_include=FALSE
                    )
    )
    expect_s3_class(p, "gg") # Should return a ggplot object
    expect_true("focal_fill" %in% names(p$data)) # focal_fill column should be present
    expect_true(all(p$data$focal_fill== p$data$sex)) # focal_fill values should be between 0 and 1
    expect_true(all(p$data$focal_fill %in% c(1, 0))) # focal_fill values should be either "M" or "F"
  }
  )
