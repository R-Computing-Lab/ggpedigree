#' plotPedigree
#' A wrapped function to plot simulated pedigree from function \code{simulatePedigree}. This function require the installation of package \code{kinship2}.

#' @param ped The simulated pedigree data.frame from function \code{simulatePedigree}. Or a pedigree dataframe with the same colnames as the dataframe simulated from function \code{simulatePedigree}.
#' @param cex The font size of the IDs for each individual in the plot.
#' @param verbose logical  If TRUE, prints additional information. Default is FALSE.
#' @param code_male This optional input allows you to indicate what value in the sex variable codes for male. Will be recoded as "M" (Male). If \code{NULL}, no recoding is performed.
#' @param affected This optional parameter can either be a string specifying the column name that indicates affected status or a numeric/logical vector of the same length as the number of rows in 'ped'. If \code{NULL}, no affected status is assigned.
#' @inheritParams kinship2::plot.pedigree
#' @return A plot of the provided pedigree
#' @export

plotPedigree <- function(ped,
                         # optional data management
                         code_male = NULL,
                         verbose = FALSE,
                         affected = NULL,
                         # optional inputs for the pedigree plot
                         cex = .5,
                         col = 1,
                         symbolsize = 1, branch = 0.6,
                         packed = TRUE, align = c(1.5, 2), width = 8,
                         density = c(-1, 35, 65, 20), mar = c(2.1, 1, 2.1, 1),
                         angle = c(90, 65, 40, 0), keep.par = FALSE,
                         pconnect = .5,
                         ...) {
  # Standardize column names in the input dataframe
  ped <- BGmisc:::standardizeColnames(ped, verbose = verbose)

  # Define required columns
  simulated_vars <- c("famID", "ID", "dadID", "momID", "sex")

  # Check if dataframe contains the required columns
  if (all(simulated_vars %in% names(ped))) {
    p <- ped[, c("famID", "ID", "dadID", "momID", "sex")]
    colnames(p) <- c("ped", "id", "father", "mother", "sex")

    # data conversation
    p[is.na(p)] <- 0

    # adds affected status if present
    if (is.null(affected)) {
      p$affected <- 0
    } else {
      # Check if 'affected' is a character (indicating a column name)
      if (is.character(affected)) {
        # Check if the DataFrame contains a column that matches the 'affected' string
        if (affected %in% names(ped)) {
          p$affected <- ped[[affected]]
        } else {
          stop(paste("Column", affected, "does not exist in the DataFrame"))
        }

        # Check if 'affected' is a numeric or logical vector
      } else if (is.numeric(affected) || is.logical(affected)) {
        # Check if the length of the vector matches the number of rows in the DataFrame
        if (length(affected) == nrow(p)) {
          p$affected <- affected
        } else {
          stop("Length of the 'affected' vector does not match the number of rows in the DataFrame")
        }
        # If 'affected' is neither a string nor a numeric/logical vector
      } else {
        stop("The 'affected' parameter must be either a string (column name) or a numeric/logical vector")
      }
    }

    p$avail <- 0
    # recode sex values
    p <- BGmisc::recodeSex(p, code_male = code_male)

    # family id
    if (length(unique(p$ped)) == 1) { # only one family
      p$ped <- 1
    } else {
      # Assign a unique string pattern "ped #" for each unique family
      unique_families <- unique(p$ped)
      named_families <- seq_along(unique_families)
      p$ped <- named_families[match(p$ped, unique_families)]
    }
    p2 <- kinship2::pedigree(
      id = p$id,
      dadid = p$father,
      momid = p$mother,
      sex = p$sex,
      famid = p$ped,
      affected = p$affected
    )
    p3 <- p2["1"]
    if (verbose) {
      message(p3)
      return(kinship2::plot.pedigree(p3,
        cex = cex,
        col = col,
        symbolsize = symbolsize,
        branch = branch,
        packed = packed, align = align,
        width = width,
        density = density,
        angle = angle, keep.par = keep.par,
        pconnect = pconnect,
        mar = mar
      ))
    } else { # TODO: consistently suppress the printing of the pedigree comments
      # Determine the null device based on the OS
      #     null_device <- ifelse(.Platform$OS.type == "windows", "nul", "/dev/null")

      # Start redirecting the standard output to suppress messages
      #     sink(file = null_device, type = "output")

      # Ensure the output is reverted back to console when function exits
      #     on.exit(if (sink.number() > 0) sink(), add = TRUE)
      if (verbose==TRUE) {
        plot_picture <- kinship2::plot.pedigree(p3,
          cex = cex,
          col = col,
          symbolsize = symbolsize,
          branch = branch,
          packed = packed, align = align,
          width = width,
          density = density,
          angle = angle, keep.par = keep.par,
          pconnect = pconnect,
          mar = mar,
          ...
        )

        # Explicitly revert the standard output back to the console
        #      if (sink.number() > 0) {
        #        sink()
        #      }
        return(plot_picture)
      } else {
        plot_picture <- suppressMessages(kinship2::plot.pedigree(p3,
          cex = cex,
          col = col,
          symbolsize = symbolsize,
          branch = branch,
          packed = packed, align = align,
          width = width,
          density = density,
          angle = angle, keep.par = keep.par,
          pconnect = pconnect,
          mar = mar,
          ...
        ))

        plot_picture[c("plist", "x", "y", "boxw", "boxh", "call")] <- NULL
        class(plot_picture) <- NULL
        return(plot_picture)
      }
    }
  } else {
    stop("The structure of the provided pedigree data does not match the expected structure.")
  }
}
