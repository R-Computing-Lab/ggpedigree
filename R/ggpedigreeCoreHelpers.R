#' @title Prepare Pedigree Data
#' @description
#' This function checks and prepares the pedigree data frame for use in ggPedigree.
#'
#' @inheritParams ggPedigree
#' @inheritParams transformPed
#' @param fill_group_family A character vector specifying the family fill group names.
#' @keywords internal
#' @return A data frame with the prepared pedigree data.
#'
#'
preparePedigreeData <- function(ped,
                                famID = "famID",
                                personID = "personID",
                                momID = "momID",
                                dadID = "dadID",
                                matID = "matID",
                                patID = "patID",
                                config = list(
                                  focal_fill_include = TRUE,
                                  focal_fill_component = "maternal",
                                  recode_missing_ids = TRUE,
                                  add_phantoms = FALSE,
                                  code_male = "M",
                                  code_female = "F",
                                  code_na = NA
                                ),
                                fill_group_paternal = c(
                                  "paternal",
                                  "patID",
                                  "paternal line",
                                  "paternal lineages",
                                  "paternal lines"
                                ),
                                fill_group_maternal = c(
                                  "maternal",
                                  "matID",
                                  "maternal line",
                                  "maternal lineages",
                                  "maternal lines"
                                ),
                                fill_group_family = c(
                                  "family",
                                  "famID",
                                  "family line",
                                  "family lineages",
                                  "family lines"
                                ),
                                status_column = NULL,
                                focal_fill_column = NULL,
                                sexVar = "sex") {
  # -----
  # STEP 2: Pedigree Data Transformation
  # -----
  if (sexVar != "sex" && !"sex" %in% names(ped)) {
    ped$sex <- ped[[sexVar]]
  }

  # Transform the pedigree data frame to include family, paternal, and maternal IDs
  ds_ped <- transformPed(
    ped = ped,
    famID = famID,
    personID = personID,
    momID = momID,
    dadID = dadID,
    matID = matID,
    patID = patID,
    config = config,
    fill_group_paternal = fill_group_paternal,
    fill_group_maternal = fill_group_maternal
  )

  # ----
  # STEP 3: Data Cleaning and Recoding
  # ----

  # Recode affected status into factor, if applicable

  if (!is.null(status_column)) {
    ds_ped[[status_column]] <- factor(ds_ped[[status_column]],
      levels = config$status_codes,
      labels = config$status_labels
    )
  }


  # Standardize sex variable using code_male convention
  # if (config$recode_sex == TRUE) {
  ds_ped <- BGmisc::recodeSex(ds_ped,
    recode_male = config$code_male,
    recode_na = config$code_na,
    recode_female = config$code_female
  )
  #  }
  if (config$add_phantoms == TRUE) {
    # If phantoms are requested, add phantom parents
    ds_ped <- BGmisc::checkParentIDs(
      ds_ped,
      addphantoms = TRUE,
      repair = TRUE,
      parentswithoutrow = FALSE,
      repairsex = FALSE,
      personID = personID,
      momID = momID,
      dadID = dadID,
      famID = famID
    )
  }

  # Add focal fill column if specified

  ds_ped <- addFocalFillColumn(
    ds_ped = ds_ped,
    config = config,
    focal_fill_column = focal_fill_column,
    famID = famID,
    matID = matID,
    patID = patID,
    personID = personID,
    fill_group_family = fill_group_family,
    fill_group_maternal = fill_group_maternal,
    fill_group_paternal = fill_group_paternal
  )

  return(ds_ped)
}


#' @title Get fill column for ggPedigree
#' @description
#' This function creates a fill column for ggPedigree plots as a function of
#' the focal person relative to everyone else in the tree.
#' @param ped A data frame containing the pedigree data.
#' @param focal_fill_personID Numeric ID of the person to use as the focal point for fill.
#' @param personID Character string specifying the column name for individual IDs.
#' @param component Character string specifying the component type (e.g., "additive").
#' @param config A list of configuration options for customizing the fill column.
#' @return A data frame with two columns: `fill` and `personID`.
#' @keywords internal
createFillColumn <- function(ped,
                             focal_fill_personID = 2,
                             personID = "personID",
                             component = "additive",
                             config = list()) {
  default_config <- getDefaultPlotConfig()

  config <- utils::modifyList(default_config, config)

  # Generate the coefficient of relationship matrix
  com_mat <- BGmisc::ped2com(
    ped = ped,
    component = component,
    personID = personID,
    isChild_method = config$matrix_isChild_method,
    sparse = config$matrix_sparse,
    mz_twins = twinID %in% names(ped)
  )

  if (config$matrix_sparse == TRUE) {
    warning(
      "Sparse matrix detected. Converting to data frame. Currently, sparse matrices are not supported for ggPedigree processing."
    )
    com_mat <- as.matrix(com_mat)
  }
  # find the row index of  ped that matches focal_fill_personID
  row_index <- which(ped[[personID]] == focal_fill_personID)
  if (length(row_index) == 0) {
    stop(paste(
      "focal_fill_personID",
      focal_fill_personID,
      "not found in ped$personID."
    ))
  }
  fill_df <- data.frame(
    focal_fill = round(com_mat[row_index, ], digits = config$value_rounding_digits),
    personID = rownames(com_mat)
  ) # needs to match the same data type

  remove(com_mat) # remove the focal_fill_personID column
  # Ensure fill_df$personID is of the same type as ped$personID
  if (is.numeric(ped$personID)) {
    fill_df$personID <- as.numeric(fill_df$personID)
  }
  if (config$focal_fill_force_zero == TRUE) {
    # If focal_fill_force_zero is TRUE, replace 0 with NA
    fill_df$focal_fill[fill_df$focal_fill == 0] <- NA_real_
  }
  fill_df
}

#' @title Process Pedigree Data
#' @description
#' This function processes the pedigree data frame to ensure it is in the correct format for ggPedigree.
#' It checks for the presence of family, paternal, and maternal IDs, and fills in missing components based on the configuration.
#' @inheritParams ggPedigree
#' @param fill_group_paternal A character vector specifying which paternal components to fill.
#' @param fill_group_maternal A character vector specifying which maternal components to fill.
#' @return A data frame with the processed pedigree data.
#' @keywords internal


transformPed <- function(ped,
                         famID = "famID",
                         personID = "personID",
                         momID = "momID",
                         dadID = "dadID",
                         matID = "matID",
                         patID = "patID",
                         twinID = "twinID",
                         config = list(
                           focal_fill_include = TRUE,
                           focal_fill_component = "maternal",
                           recode_missing_ids = TRUE
                         ),
                         fill_group_paternal = c(
                           "paternal",
                           "patID",
                           "paternal line",
                           "paternal lineages",
                           "paternal lines"
                         ),
                         fill_group_maternal = c(
                           "maternal",
                           "matID",
                           "maternal line",
                           "maternal lineages",
                           "maternal lines"
                         )) {
  if (config$recode_missing_ids == TRUE) {
    # handle 0 as missing IDs
    ped <- recodeMissingIDs(
      ped = ped,
      personID = personID,
      momID = momID,
      dadID = dadID,
      famID = famID,
      matID = matID,
      patID = patID,
      twinID = twinID,
      config = config
    )
  }
  # Check if famID, patID, matID are present; if not, create them
  if (!all(c(famID, patID, matID) %in% names(ped)) &&
    !famID %in% names(ped)) {
    ds_ped <- BGmisc::ped2fam(
      ped,
      famID = famID,
      personID = personID,
      momID = momID,
      dadID = dadID
    )
    if (!class(ped[[personID]]) %in% c("numeric", "integer") &&
      class(ds_ped[[personID]]) %in% c("numeric", "integer")
    ) {
      # fix strange converse of cases
      ds_ped[[personID]] <- as.character(ds_ped[[personID]])
    }
    if (!class(ped[[momID]]) %in% c("numeric", "integer") &&
      class(ds_ped[[momID]]) %in% c("numeric", "integer")
    ) {
      # fix strange converse of cases
      ds_ped[[momID]] <- as.character(ds_ped[[momID]])
    }
    if (!class(ped[[dadID]]) %in% c("numeric", "integer") &&
      class(ds_ped[[dadID]]) %in% c("numeric", "integer")
    ) {
      # fix strange converse of cases
      ds_ped[[dadID]] <- as.character(ds_ped[[dadID]])
    }
  } else {
    ds_ped <- ped
  }


  if (config$focal_fill_include == TRUE) {
    if (!patID %in% names(ds_ped) &&
      config$focal_fill_component %in% fill_group_paternal) {
      ds_ped <- BGmisc::ped2paternal(
        ds_ped,
        patID = patID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
      if (!class(ped[[personID]]) %in% c("numeric", "integer") &&
        class(ds_ped[[personID]]) %in% c("numeric", "integer")
      ) {
        # fix strange converse of cases
        ds_ped[[personID]] <- as.character(ds_ped[[personID]])
      }
    }

    if (!matID %in% names(ds_ped) &&
      config$focal_fill_component %in% fill_group_maternal) {
      ds_ped <- BGmisc::ped2maternal(
        ds_ped,
        matID = matID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
      if (!class(ped[[personID]]) %in% c("numeric", "integer") &&
        class(ds_ped[[personID]]) %in% c("numeric", "integer")
      ) {
        # fix strange converse of cases
        ds_ped[[personID]] <- as.character(ds_ped[[personID]])
      }
    }
  }
  return(ds_ped)
}

#' @title Add Focal Fill Column to Pedigree Data
#' @description
#' Adds a `focal_fill` column to the pedigree data based on configuration input.
#' Supports additive, mitochondrial, and line-based modes. If `focal_fill_column`
#' is specified, it takes priority over inferred modes.
#'
#' @inheritParams ggPedigree
#' @param ds_ped A data frame already processed by `transformPed()`.
#' @param fill_group_family Character vector specifying fill types for family lineage.
#' @param fill_group_maternal Character vector specifying fill types for maternal lineage.
#' @param fill_group_paternal Character vector specifying fill types for paternal lineage.
#' @return A data frame with a `focal_fill` column added if applicable.
#' @keywords internal
addFocalFillColumn <- function(ds_ped,
                               config,
                               focal_fill_column = NULL,
                               famID = "famID",
                               matID = "matID",
                               patID = "patID",
                               personID = "personID",
                               twinID = "twinID",
                               fill_group_family = c(
                                 "famID",
                                 "family",
                                 "family lineages",
                                 "family lines",
                                 "family line"
                               ),
                               fill_group_maternal = c(
                                 "maternal",
                                 "matID",
                                 "maternal line",
                                 "maternal lineages",
                                 "maternal lines"
                               ),
                               fill_group_paternal = c(
                                 "paternal",
                                 "patID",
                                 "paternal line",
                                 "paternal lineages",
                                 "paternal lines"
                               )) {
  # -----
  # STEP 1: Compute inferred fill column from component if no user-specified fill
  # -----
  if (config$focal_fill_include == TRUE &&
    is.null(focal_fill_column)) {
    # -----
    # CASE 1: Component-based fill (e.g., additive, mtDNA)
    # -----
    if (config$focal_fill_component %in% c(
      "additive",
      "common nuclear",
      "mitochondrial",
      "mtdna",
      "mitochondria"
    )) {
      # Use component matrix to generate fill values relative to focal individual
      # The function createFillColumn will handle the logic of creating the fill column
      ds_ped <- ds_ped |>
        dplyr::left_join(
          createFillColumn(
            ped = ds_ped,
            focal_fill_personID = config$focal_fill_personID,
            personID = personID,
            component = config$focal_fill_component,
            config = config
          ),
          by = dplyr::join_by(personID == !!rlang::sym(personID))
        )

      # -----
      # CASE 2: Lineage-based fill (family, maternal, paternal)
      # -----
    } else if (config$focal_fill_component %in% c(
      fill_group_family,
      fill_group_maternal,
      fill_group_paternal,
      matID,
      patID,
      famID
    )) {
      # Maternal fill → use matID
      if (config$focal_fill_component %in% fill_group_maternal) {
        config$focal_fill_component_recode <- matID
        ds_ped <- ds_ped |>
          dplyr::mutate(focal_fill = as.factor(.data[[matID]]))
      }

      # Paternal fill → use patID
      if (config$focal_fill_component %in% fill_group_paternal) {
        config$focal_fill_component_recode <- patID
        ds_ped <- ds_ped |>
          dplyr::mutate(focal_fill = as.factor(.data[[patID]]))
      }

      # Family fill → use famID
      if (config$focal_fill_component %in% fill_group_family) {
        config$focal_fill_component_recode <- famID
        ds_ped <- ds_ped |>
          dplyr::mutate(focal_fill = as.factor(.data[[famID]]))
      }
    }

    # -----
    # STEP 2: Use explicitly supplied fill column
    # -----
  } else if (config$focal_fill_include == TRUE &&
    !is.null(focal_fill_column)) {
    # Use column directly from pedigree data
    ds_ped <- ds_ped |>
      dplyr::mutate(focal_fill = !!rlang::sym(focal_fill_column))
  }

  # -----
  # STEP 3: Return modified data frame with focal_fill (if applicable)
  # -----
  return(ds_ped)
}
#' @title Pick First Matching Rule
#' @description
#' This function evaluates a list of rules and returns the action associated with the first rule that matches.
#' If no rules match, it returns a default value.
#' @param rules A list of rules, where each rule is a list with `when` and `do` elements.
#' @param default The default value to return if no rules match (default is NULL).
#' @return The action associated with the first matching rule, or the default value.
#' @keywords internal
.pick_first <- function(rules, default = NULL) {
  for (r in rules) {
    if (isTRUE(r$when())) {
      return(r$do)
    }
  }
  default
}


.should_add_overlay <- function(config,
                                overlay_column = NULL,
                                status_column = NULL,
                                focal_fill_column = NULL) {
  isTRUE(config$overlay_include) && !is.null(overlay_column) ||
    (isTRUE(config$status_include) && !is.null(status_column) && isTRUE(config$sex_color_include)) ||
    (isTRUE(config$focal_fill_include) && !is.null(focal_fill_column) && !isTRUE(config$sex_color_include))
}

.get_color_mode <- function(config, status_column, focal_fill_column) {
  .pick_first(
    rules = list(
      list(when = function() isTRUE(config$sex_color_include), do = "sex"),
      list(when = function() isTRUE(config$focal_fill_include), do = "focal_fill"),
      list(when = function() !is.null(status_column) && isTRUE(config$status_include), do = "status")
    ),
    default = "none"
  )
}
