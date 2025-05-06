#' Plot a custom pedigree diagram
#'
#' This function takes a pedigree dataset and generates a custom ggplot2-based pedigree diagram.
#' It processes the data using `ped2fam()`, calculates coordinates and family connections, and
#' returns a ggplot object with customized styling.
#'
#' @param pedigree A data frame containing the pedigree data.
#' @param famID_col Character string specifying the column name for family IDs.
#' @param personID_col Character string specifying the column name for individual IDs.
#' @param momID_col Character string specifying the column name for mother IDs. Defaults to "momID".
#' @param dadID_col Character string specifying the column name for father IDs. Defaults to "dadID".
#' @param code_male Numeric value specifying the male code (typically 0 or 1). Defaults to 1.
#'
#' @return A ggplot object representing the pedigree diagram.
#'
#' @examples
#' data("potter")
#' plot_custom_pedigree(potter, famID_col = "famID", personID_col = "personID", code_male = 1)
#'
#' data("hazard")
#' plot_custom_pedigree(hazard, famID_col = "famID", personID_col = "ID", code_male = 0)
#'
#' @export

plot_custom_pedigree <- function(ped, famID_col = "famID",
                                 personID_col = "personID" ,
                                 momID_col = "momID", dadID_col = "dadID", code_male = 1) {

  # STEP 1: Convert to pedigree format

  ds <-

    BGmisc::ped2fam(ped, famID = famID_col,
                    personID = personID_col,
                    momID = momID_col,
                    dadID = dadID_col
                    )

  if ("famID.y" %in% names(ds)) {
    ds <-  ds  %>%
      dplyr::select(-famID.y)
    }


  if ("famID.x" %in% names(ds)) {
    ds <-  ds  %>%
    dplyr::rename(famID = famID.x)
  }

  # If the input personID_col was not "personID", rename to "personID" for downstream functions

  if (personID_col != "personID") {
    ds <- dplyr::rename(ds, personID = !!personID_col)
  }

  # If the input personID_col was not "personID", rename to "personID" for downstream functions
  # STEP 2: Recode sex


    ds <- BGmisc::recodeSex(ds, recode_male = code_male)

    # STEP 3: Calculate coordinates
  ds <- calculateCoordinates(ds, personID = "personID",
                                     momID = momID_col,
                                     dadID = dadID_col,
                                     code_male = code_male)


  # STEP 4: Calculate connections

  connections <- calculateConnections(ds)

  # STEP 5: Create the plot
  p <- ggplot2::ggplot(ds, ggplot2::aes(x = x_pos, y = y_pos)) +
    ggplot2::geom_segment(data = connections,
                          ggplot2::aes(x = x_spouse, xend = x_pos,
                                       y = y_spouse, yend = y_pos),
                          linewidth = 0.5, color = "pink",
                          na.rm = TRUE) +
    ggplot2::geom_segment(data = connections,
                          ggplot2::aes(x = x_mid_sib, xend = x_midparent,
                                       y = y_mid_sib - .5, yend = y_midparent),
                          linewidth = 0.5, color = "green",
                          na.rm = TRUE) +
    ggplot2::geom_segment(data = connections,
                          ggplot2::aes(x = x_pos, xend = x_mid_sib,
                                       y = y_pos - .5, yend = y_mid_sib - .5),
                          linewidth = 0.5, color = "black",
                          na.rm = TRUE) +
    ggplot2::geom_segment(data = connections,
                          ggplot2::aes(x = x_pos, xend = x_pos,
                                       y = y_mid_sib - .5, yend = y_pos),
                          linewidth = 0.5, color = "blue",
                          na.rm = TRUE) +
    ggplot2::geom_point(ggplot2::aes(color = as.factor(sex),
                                     shape = as.factor(sex)), size = 4,
                        na.rm = TRUE) +
    ggrepel::geom_text_repel(ggplot2::aes(label = personID),
                             nudge_y = - .15,
                             size = 3) +
    ggplot2::scale_shape_manual(values = c(16, 15),
                                labels = c("Female", "Male")) +
    ggplot2::scale_y_reverse() +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.title.y = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_blank(),
                   axis.ticks.y = ggplot2::element_blank()) +
    ggplot2::scale_color_discrete(labels = c("Female", "Male")) +
    ggplot2::labs(color = "Sex", shape = "Sex")

  return(p)
}
