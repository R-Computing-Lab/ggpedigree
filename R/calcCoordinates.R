utils::globalVariables(c(":="))

#' Calculate coordinates for plotting individuals in a pedigree
#'
#' Extracts and modifies the x and y positions for each individual in a
#' pedigree data frame using the align.pedigree function from the `kinship2` package.
#' It returns a data.frame with positions for plotting.
#'
#' @param sexVar Character. Name of the column in `ped` for the sex variable.
#' @param spouseID Character. Name of the column in `ped` for the spouse ID variable.
#' @param code_male Value used to indicate male sex. Defaults to NULL.
#' @param config List of configuration options:
#'   \describe{
#'     \item{code_male}{Default is 1. Used by BGmisc::recodeSex().}
#'     \item{ped_packed}{Logical, default TRUE. Passed to `kinship2::align.pedigree`.}
#'     \item{ped_align}{Logical, default TRUE. Align generations.}
#'     \item{ped_width}{Numeric, default 15. Controls spacing.}
#'   }
#' @inheritParams ggPedigree
#'
#' @return A data frame with one or more rows per person, each containing:
#'   \itemize{
#'     \item `x_order`, `y_order`: Grid indices representing layout rows and columns.
#'     \item `x_pos`, `y_pos`: Continuous coordinate positions used for plotting.
#'     \item `nid`: Internal numeric identifier for layout mapping.
#'     \item `extra`: Logical flag indicating whether this row is a secondary appearance.
#'   }
#'
#' @export

calculateCoordinates <- function(ped,
                                 personID = "personID",
                                 momID = "momID",
                                 dadID = "dadID",
                                 spouseID = "spouseID",
                                 sexVar = "sex",
                                 twinID = "twinID",
                                 code_male = NULL,
                                 config = list()) {
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }

  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop(
      "At least one of the required ID variables (personID, momID, dadID) was not found in `ped`"
    )
  }

  # -----
  # Set up
  # -----

  # Fill missing configuration values with defaults
  default_config <- list(
    code_male = 1,
    ped_packed = TRUE,
    ped_align = TRUE,
    ped_width = 15,
    return_midparent = FALSE
  )
  config <- utils::modifyList(default_config, config)

  # Construct a pedigree object to compute layout coordinates

  # use relations if provided, otherwise use default settings
  ped_ped <- alignPedigreeWithRelations(
    ped = ped,
    personID = personID,
    dadID = dadID,
    momID = momID,
    code_male = code_male,
    sexVar = sexVar,
    config = config
  )

  # use hints if provided
  pos <- alignPedigreeWithHints(
    ped_ped = ped_ped,
    config = config
  )

  #  assign("DEBUG_pos", pos, envir = .GlobalEnv)

  # Extract layout information
  nid_vector <- as.vector(pos$nid)
  nid_vector <- nid_vector[nid_vector != 0] # Remove zero entries (empty cells)

  # Initialize coordinate columns in the data frame
  ped$nid <- NA
  ped$x_pos <- NA
  ped$x_order <- NA
  ped$y_order <- NA

  # Determine matrix indices for all non-zero entries
  nid_pos <- which(pos$nid != 0, arr.ind = TRUE)

  # Allocate coordinate vectors
  n_coords <- length(nid_vector)
  base_vector <- rep(NA_real_, n_coords)

  x_pos <- base_vector
  y_coords <- base_vector
  x_coords <- base_vector
  spouse_vector <- base_vector
  parent_fam <- base_vector
  parent_right_vector <- base_vector
  parent_left_vector <- base_vector
  y_fam <- base_vector

  # A matrix with values
  # 1 = subject plotted to the immediate right is a spouse
  # 2 = subject plotted to the immediate right is an inbred spouse
  # 0 = not a spouse

  # Populate coordinates from nid positions
  y_coords <- nid_pos[, "row"]
  x_coords <- nid_pos[, "col"]
  x_pos <- pos$pos[cbind(y_coords, x_coords)]


  # Spouse information
  spouse_vector <- pos$spouse[cbind(y_coords, x_coords)]

  # Parent information
  parent_fam <- pos$fam[cbind(y_coords, x_coords)]
  y_fam <- y_coords - 1

  parent_row <- y_coords - 1
  parent_col_left <- parent_fam
  parent_col_right <- parent_fam + 1

  # Ensure parent columns are within bounds
  valid_parent <- parent_row >= 1 &
    parent_col_left >= 1 &
    parent_col_right <= ncol(pos$pos)

  parent_left_vector[valid_parent] <- pos$pos[cbind(parent_row[valid_parent],
                                                    parent_col_left[valid_parent])]

  parent_right_vector[valid_parent] <- pos$pos[cbind(parent_row[valid_parent],
                                                     parent_col_right[valid_parent])]


  # -----
  # Fill in the data frame with coordinates
  # -----
  # Match each individual to their primary layout position
  tmp <- match(seq_along(ped_ped$id), nid_vector)

  # Fill the nid, pos, x, and y columns in ped_ped based on the mapping
  ped$nid <- nid_vector[tmp]
  ped$x_order <- x_coords[tmp]
  ped$y_order <- y_coords[tmp]
  ped$x_pos <- x_pos[tmp]
  ped$y_pos <- y_coords[tmp]
  ped$parent_fam <- parent_fam[tmp]
  ped$spousehint <- spouse_vector[tmp]
  ped$parent_left <- parent_left_vector[tmp]
  ped$parent_right <- parent_right_vector[tmp]
  ped$y_fam <- y_fam[tmp]


  # Detect multiple layout positions for the same individual
  # This can happen if the same individual appears multiple times in the pedigree

  # For each nid, count how many times it appears
  appearance_counts <- table(nid_vector)

  duplicate_nids <- names(appearance_counts[appearance_counts > 1]) |>
    as.integer()

  # Prepare flat list of (nid_val, idx) for all extra appearances
  extra_info <- list()

  # Create duplicate rows for extra appearances

  # All appearance positions
  appearance_indices <- which(nid_vector %in% duplicate_nids)

  # Find which index was already used in tmp
  # tmp is a mapping from person index to nid_vector position
  used_indices <- tmp[duplicate_nids]

  # Extra indices are the appearances NOT used by match()
  extra_indices <- setdiff(appearance_indices, used_indices)

  # If there are extra indices, we need to create additional rows
  if (length(extra_indices) > 0) {
    extra_df <- data.frame(
      nid = nid_vector[extra_indices],
      idx = extra_indices
    )

    # directly matching each nid to ped_ped$id and then to ped
    matched_personID <- ped_ped$id[extra_df$nid]
    ped_rows_idx <- match(matched_personID, ped[[personID]])

    extra_rows <- ped[ped_rows_idx, , drop = FALSE]

    # Assign coordinates explicitly
    extra_rows$nid <- extra_df$nid
    extra_rows$x_order <- x_coords[extra_df$idx]
    extra_rows$y_order <- y_coords[extra_df$idx]
    extra_rows$x_pos <- x_pos[extra_df$idx]
    extra_rows$y_pos <- y_coords[extra_df$idx]
    extra_rows$spousehint <- spouse_vector[extra_df$idx]
    extra_rows$parent_fam <- parent_fam[extra_df$idx]
    extra_rows$parent_left <- parent_left_vector[extra_df$idx]
    extra_rows$parent_right <- parent_right_vector[extra_df$idx]
    extra_rows$y_fam <- y_fam[extra_df$idx]

    ped$extra <- FALSE
    extra_rows$extra <- TRUE

    ped <- rbind(ped, extra_rows)
  } else {
    ped$extra <- FALSE
  }

  # clean up
  ## assumes that there are two parents
  ped$x_fam <- base::rowMeans(cbind(ped$parent_left,
                                    ped$parent_right), na.rm = FALSE)
  ped$x_fam[ped$parent_fam == 0] <- NA
  ped[[momID]][ped$parent_fam == 0] <- NA
  ped[[dadID]][ped$parent_fam == 0] <- NA
  ped$y_fam[ped$parent_fam == 0] <- NA
  ped$parent_left <- NULL
  ped$parent_right <- NULL
  #  assign("DEBUG_ped_withextras", ped, envir = .GlobalEnv)
  return(ped)
}

#' Align pedigree with additional relations
#'
#' This function aligns a pedigree object using relations if provided, or
#' defaults to the default alignment settings.
#' @inheritParams calculateCoordinates
#' @return A data frame with the aligned positions of individuals in the pedigree.
#' @keywords internal

alignPedigreeWithRelations <- function(ped,
                                       personID,
                                       dadID,
                                       momID,
                                       code_male,
                                       sexVar,
                                       config) {
  # Recode sex values in case non-standard codes are used (e.g., "M"/"F")
  ped_recode <- BGmisc::recodeSex(ped, code_male = code_male)
  if ("relation" %in% names(config) && !is.null(config$relation)) {
    # Construct a pedigree object to compute layout coordinates
    ped_ped <- kinship2::pedigree(
      id = ped[[personID]],
      dadid = ped[[dadID]],
      momid = ped[[momID]],
      sex = ped_recode[[sexVar]],
      relation = config$relation
    )
  } else {
    ped_ped <- kinship2::pedigree(
      id = ped[[personID]],
      dadid = ped[[dadID]],
      momid = ped[[momID]],
      sex = ped_recode[[sexVar]]
    )
  }

  return(ped_ped)
}

#' Align pedigree with hints for plotting
#' This function aligns a pedigree object using hints if provided,
#'  or defaults to  the default alignment settings.
#' @param ped_ped A pedigree object created by `kinship2::pedigree()`.
#' @param config A list of configuration options
#' @return A data frame with the aligned positions of individuals in the pedigree.
#' @keywords internal

alignPedigreeWithHints <- function(ped_ped, config) {
  if ("hints" %in% names(config) && !is.null(config$hints)) {
    # Check if hints are provided
    autohint <- tryCatch(
      kinship2::autohint(
        ped_ped,
        config$hints,
        align = config$ped_align,
        packed = config$ped_packed
      ),
      error = function(e) {
        warning("Your hints caused an error and were not used.
                Using default hints instead.")
        kinship2::autohint(ped_ped,
          align = config$ped_align,
          packed = config$ped_packed
        )
      }
    )
    # Align pedigree for plotting
    pos <- kinship2::align.pedigree(
      ped_ped,
      packed = config$ped_packed,
      align = config$ped_align,
      width = config$ped_width,
      hints = autohint
    )
  } else {
    # -----
    # Extract layout information
    # -----
    # Align pedigree for plotting
    pos <- kinship2::align.pedigree(
      ped_ped,
      packed = config$ped_packed,
      align = config$ped_align,
      width = config$ped_width
    )
  }
  return(pos)
}
