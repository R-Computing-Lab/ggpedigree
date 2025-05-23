% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggpedigree.R
\name{ggPedigree.core}
\alias{ggPedigree.core}
\title{Core Function for ggPedigree}
\usage{
ggPedigree.core(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  status_col = NULL,
  config = list(),
  debug = FALSE,
  hints = NULL,
  ...
)
}
\arguments{
\item{ped}{A data frame containing the pedigree data. Needs personID, momID, and dadID columns}

\item{famID}{Character string specifying the column name for family IDs.}

\item{personID}{Character string specifying the column name for individual IDs.}

\item{momID}{Character string specifying the column name for mother IDs. Defaults to "momID".}

\item{dadID}{Character string specifying the column name for father IDs. Defaults to "dadID".}

\item{status_col}{Character string specifying the column name for affected status. Defaults to NULL.}

\item{config}{A list of configuration options for customizing the plot. The list can include:
\describe{
   \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
   \item{segment_spouse_color, segment_self_color, segment_sibling_color, segment_parent_color, segment_offspring_color}{Character. Line colors for respective connection types.}
   \item{label_text_size, point_size, line_width}{Numeric. Controls text size, point size, and line thickness.}
   \item{generation_height}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
   \item{shape_unknown, shape_female, shape_male, affected_shape}{Integers. Shape codes for plotting each group.}
   \item{sex_shape_labs}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown")}
   \item{unaffected, affected}{Values indicating unaffected/affected status.}
   \item{sex_color}{Logical. If TRUE, uses color to differentiate sex.}
   \item{label_max_overlaps}{Maximum number of overlaps allowed in repelled labels.}
   \item{label_segment_color}{Color used for label connector lines.}
 }}

\item{debug}{Logical. If TRUE, prints debugging information. Default: FALSE.}

\item{hints}{Data frame with hints for layout adjustments. Default: NULL.}

\item{...}{Additional arguments passed to `ggplot2` functions.}
}
\description{
This function is the core implementation of the ggPedigree function.
It handles the data preparation, layout calculation,
and plotting of the pedigree diagram.
It is not intended to be called directly by users.
}
\keyword{internal}
