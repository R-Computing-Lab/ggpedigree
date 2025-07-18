% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggpedigree.R
\name{transformPed}
\alias{transformPed}
\title{Process Pedigree Data}
\usage{
transformPed(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  matID = "matID",
  patID = "patID",
  config = list(focal_fill_include = TRUE, focal_fill_component = "maternal"),
  fill_group_paternal = c("paternal", "patID", "paternal line", "paternal lineages",
    "paternal lines"),
  fill_group_maternal = c("maternal", "matID", "maternal line", "maternal lineages",
    "maternal lines")
)
}
\arguments{
\item{ped}{A data frame containing the pedigree data. Needs personID, momID, and dadID columns}

\item{famID}{Character string specifying the column name for family IDs. Defaults to "famID".}

\item{personID}{Character string specifying the column name for individual IDs. Defaults to "personID".}

\item{momID}{Character string specifying the column name for mother IDs. Defaults to "momID".}

\item{dadID}{Character string specifying the column name for father IDs. Defaults to "dadID".}

\item{matID}{Character string specifying the column name for maternal lines Defaults to "matID".}

\item{patID}{Character string specifying the column name for paternal lines Defaults to "patID".}

\item{config}{A list of configuration options for customizing the plot.
      See getDefaultPlotConfig for details. The list can include:
\describe{
   \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
   \item{segment_spouse_color, segment_self_color}{Character. Line colors for respective connection types.}
   \item{segment_sibling_color, segment_parent_color, segment_offspring_color}{Character. Line colors for respective connection types.}
   \item{label_text_size, point_size, segment_linewidth}{Numeric. Controls text size, point size, and line thickness.}
   \item{generation_height}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
   \item{shape_unknown, shape_female, shape_male, status_shape_affected}{Integers. Shape codes for plotting each group.}
   \item{sex_shape_labels}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown"))}
   \item{unaffected, affected}{Values indicating unaffected/affected status.}
   \item{sex_color_include}{Logical. If TRUE, uses color to differentiate sex.}
   \item{label_max_overlaps}{Maximum number of overlaps allowed in repelled labels.}
   \item{label_segment_color}{Color used for label connector lines.}
 }}

\item{fill_group_paternal}{A character vector specifying which paternal components to fill.}

\item{fill_group_maternal}{A character vector specifying which maternal components to fill.}
}
\value{
A data frame with the processed pedigree data.
}
\description{
This function processes the pedigree data frame to ensure it is in the correct format for ggPedigree.
It checks for the presence of family, paternal, and maternal IDs, and fills in missing components based on the configuration.
}
\keyword{internal}
