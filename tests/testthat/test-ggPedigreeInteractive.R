test_that("ggPedigreeInteractive behaves same as ggPedigree interactive is true without twins", {
  library(BGmisc)

  data("potter") # load example data from BGmisc
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
  p_widget <- ggPedigreeInteractive(potter,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p_widget, "plotly")
  expect_s3_class(p_widget, "htmlwidget")

  # Test with hints
  p <- ggPedigree(potter,
    interactive = TRUE,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p, "plotly")
  expect_s3_class(p, "htmlwidget")


  expect_equal(p_widget$height, p$height)
  expect_equal(p_widget$width, p$width)
  expect_equal(p_widget$x$layout, p$x$layout)
  expect_equal(p_widget$x$data, p$x$data)
  expect_equal(p_widget$x$frames, p$x$frames)
  expect_equal(p_widget$x$source, p$x$source)
  expect_equal(p_widget$x$elementId, p$x$elementId)
  # expect_equal(p_widget$x$attrs, p$x$attrs)
  expect_equal(p_widget$x$config, p$x$config)
  expect_equal(p_widget$sizingPolicy, p$sizingPolicy)
})

test_that("ggPedigreeInteractive behaves same as ggPedigree interactive is true with twins", {
  library(BGmisc)
  library(tidyverse)
  data("potter") # load example data from BGmisc
  if (!"twinID" %in% names(potter) || !"zygosity" %in% names(potter)) {
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

  p_widget <- ggPedigreeInteractive(potter,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p_widget, "plotly")
  expect_s3_class(p_widget, "htmlwidget")


  p <- ggPedigree(potter,
    interactive = TRUE,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p, "plotly")
  expect_s3_class(p, "htmlwidget")


  expect_equal(p_widget$height, p$height)
  expect_equal(p_widget$width, p$width)
  expect_equal(p_widget$x$layout, p$x$layout)
  expect_equal(p_widget$x$data, p$x$data)
  expect_equal(p_widget$x$frames, p$x$frames)
  expect_equal(p_widget$x$source, p$x$source)
  expect_equal(p_widget$x$elementId, p$x$elementId)
  # expect_equal(p_widget$x$attrs, p$x$attrs)
  expect_equal(p_widget$x$config, p$x$config)
  expect_equal(p_widget$sizingPolicy, p$sizingPolicy)

  # without zygosity
  potter_no_zyg <- potter %>%
    select(-zygosity)

  p_widget_nozyg <- ggPedigreeInteractive(potter_no_zyg,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p_widget_nozyg, "plotly")
  expect_s3_class(p_widget_nozyg, "htmlwidget")


  p_nozyg <- ggPedigree(potter_no_zyg,
    interactive = TRUE,
    famID = "famID",
    personID = "personID",
    spouseID = "spouseID",
    return_widget = TRUE
  )

  expect_s3_class(p_nozyg, "plotly")
  expect_s3_class(p_nozyg, "htmlwidget")


  expect_equal(p_widget_nozyg$height, p_nozyg$height)
  expect_equal(p_widget_nozyg$width, p_nozyg$width)
  expect_equal(p_widget_nozyg$x$layout, p_nozyg$x$layout)
  expect_equal(p_widget_nozyg$x$data, p_nozyg$x$data)
  expect_equal(p_widget_nozyg$x$frames, p_nozyg$x$frames)
  expect_equal(p_widget_nozyg$x$source, p_nozyg$x$source)
  expect_equal(p_widget_nozyg$x$elementId, p_nozyg$x$elementId)
  # expect_equal(p_widget_nozyg$x$attrs, p_nozyg$x$attrs)
  expect_equal(p_widget_nozyg$x$config, p_nozyg$x$config)
  expect_equal(p_widget_nozyg$sizingPolicy, p_nozyg$sizingPolicy)
})
test_that("ggPedigreeInteractive returns a gg object", {
  library(BGmisc)
  data("potter") # load example data from BGmisc
  if ("twinID" %in% names(potter) && "zygosity" %in% names(potter)) {
    # Remove twinID and zygosity columns for this test
    potter <- potter %>%
      select(-twinID, -zygosity)
  } else if ("twinID" %in% names(potter) && !"zygosity" %in% names(potter)) {
    # Add twinID and zygosity columns for demonstration purposes
    potter <- potter %>%
      select(-twinID)
  }

  static <- ggPedigreeInteractive(
    potter,
    famID = "famID",
    personID = "personID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    patID = "patID",
    matID = "matID",
    config = list(
      label_nudge_y = -.25,
      label_include = TRUE,
      label_method = "geom_text",
      sex_color_include = TRUE,
      return_static = TRUE
    ),
    tooltip_columns = c("personID", "name")
  )
  expect_s3_class(static, "gg")
})

test_that("ggPedigreeInteractive handles errors", {
  expect_error(
    ggPedigreeInteractive("potter", famID = "famID", personID = "personID", return_widget = TRUE)
  )


  library(BGmisc)
  data("potter") # load example data from BGmisc
  if ("twinID" %in% names(potter) && "zygosity" %in% names(potter)) {
    # Remove twinID and zygosity columns for this test
    potter <- potter %>%
      select(-twinID, -zygosity)
  } else if ("twinID" %in% names(potter) && !"zygosity" %in% names(potter)) {
    # Add twinID and zygosity columns for demonstration purposes
    potter <- potter %>%
      select(-twinID)
  }

  expect_message(
    ggPedigreeInteractive(potter, famID = "famID", personID = "personID", config = list(
      label_method = "geom_text_repel"
    ))
  )

  expect_message(
    ggPedigreeInteractive(potter, famID = "famID", personID = "personID", config = list(
      label_method = "geom_label"
    ))
  )
  if (!"twinID" %in% names(potter) || !"zygosity" %in% names(potter)) {
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

    expect_message(
      ggPedigreeInteractive(potter,
        famID = "famID",
        personID = "personID", config = list(
          label_method = "geom_text_repel"
        )
      )
    )
    expect_message(
      ggPedigreeInteractive(potter, famID = "famID", personID = "personID", config = list(
        label_method = "geom_label"
      ))
    )
  }
})

test_that("ggPedigreeInteractive returns a gg object for consang", {
  library(BGmisc)
  data("inbreeding") # load example data from BGmisc

  static <- ggPedigreeInteractive(
    inbreeding,
    famID = "famID",
    personID = "ID",
    momID = "momID",
    dadID = "dadID",
    spouseID = "spouseID",
    #   patID = "patID",
    #  matID = "matID",
    config = list(
      label_nudge_y = -.25,
      label_include = TRUE,
      override_many2many = TRUE,
      label_method = "geom_text",
      sex_color_include = TRUE,
      return_static = TRUE,
      code_male = 0
    ),
    tooltip_columns = c("momID")
  )
  expect_s3_class(static, "gg")
})

test_that("ggPedigreeInteractive handles inbreeding", {
  library(BGmisc)
  data("inbreeding") # load example data from BGmisc

  p_widget_nozyg <- ggPedigreeInteractive(inbreeding,
    famID = "famID",
    personID = "ID",
    spouseID = "spouseID",
    return_widget = TRUE,
    config = list(
      code_male = 0,
      override_many2many = TRUE
    )
  )

  expect_s3_class(p_widget_nozyg, "plotly")
  expect_s3_class(p_widget_nozyg, "htmlwidget")


  p_nozyg <- ggPedigree(inbreeding,
    interactive = TRUE,
    famID = "famID",
    personID = "ID",
    spouseID = "spouseID",
    return_widget = TRUE,
    config = list(
      code_male = 0,
      override_many2many = TRUE
    )
  )

  expect_s3_class(p_nozyg, "plotly")
  expect_s3_class(p_nozyg, "htmlwidget")


  expect_equal(p_widget_nozyg$height, p_nozyg$height)
  expect_equal(p_widget_nozyg$width, p_nozyg$width)
  expect_equal(p_widget_nozyg$x$layout, p_nozyg$x$layout)
  expect_equal(p_widget_nozyg$x$data, p_nozyg$x$data)
  expect_equal(p_widget_nozyg$x$frames, p_nozyg$x$frames)
  expect_equal(p_widget_nozyg$x$source, p_nozyg$x$source)
  expect_equal(p_widget_nozyg$x$elementId, p_nozyg$x$elementId)
  # expect_equal(p_widget_nozyg$x$attrs, p_nozyg$x$attrs)
  expect_equal(p_widget_nozyg$x$config, p_nozyg$x$config)
  expect_equal(p_widget_nozyg$sizingPolicy, p_nozyg$sizingPolicy)
})

#
test_that("ggPedigreeInteractive optimize_plotly reduces object size", {
  library(BGmisc)
  data("potter") # load example data from BGmisc

plotly_og <- ggPedigreeInteractive(
  potter,
  famID    = "famID",
  personID = "personID",
  momID    = "momID",
  dadID    = "dadID",config = list(optimize_plotly=FALSE, tooltip_include = FALSE)
) |> plotly::hide_legend()

plotly_optimized <- ggPedigreeInteractive(
  potter,
  famID    = "famID",
  personID = "personID",
  momID    = "momID",
  dadID    = "dadID", config = list(optimize_plotly=TRUE, tooltip_include = FALSE)
) |> plotly::hide_legend()

  expect_lt(object.size(plotly_optimized), object.size(plotly_og))
})


