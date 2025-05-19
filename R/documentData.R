#' Kluane Red Squirrel Data
#'
#' A tidy data frame of life‐history and reproductive metrics for 7,799 individual red squirrels
#' from the Kluane Red Squirrel Project (1987–present).
#' Each row corresponds to one squirrel with associated pedigree links and reproductive success summaries.
#' The original data are published under a CC0 1.0 Universal Public Domain Dedication:
#'
#' McFarlane, S. Eryn; Boutin, Stan; Humphries, Murray M. et al. (2015). Data from:
#' Very low levels of direct additive genetic variance in fitness and fitness components in a red squirrel population [Dataset].
#' Dryad. <https://doi.org/10.5061/dryad.n5q05>
#'
#' @format ## `redsquirrels`
#' A data frame with 7799 rows and 16 columns:
#' \describe{
#'   \item{personID}{Unique identifier for each squirrel}
#'   \item{momID, dadID}{Unique identifiers for each squirrel's parents}
#'   \item{sex}{Biological sex of the squirrel}
#'   \item{famID}{Unique identifier for each family. Derived from ped2fam}
#'   \item{byear}{Birth year of the squirrel}
#'   \item{dyear}{Death year of the squirrel}
#'   \item{lrs}{lifetime reproductive success for the squirrel}
#'   \item{ars_mean}{Mean annual reproductive success for the squirrel}
#'   \item{ars_max}{Maximum ARS value for the squirrel}
#'   \item{ars_med}{Median ARS value for the squirrel}
#'   \item{ars_min}{Minimum ARS value for the squirrel}
#'   \item{ars_sd}{Standard deviation of ARS values for the squirrel}
#'   \item{ars_n}{Number of ARS values for the squirrel}
#'   \item{year_first}{First year of ARS data for the squirrel}
#'   \item{year_last}{Last year of ARS data for the squirrel}
#'   ...
#' }
#' @docType data
#' @keywords datasets
#' @name redsquirrels
#' @usage data(redsquirrels)
#' @source <https://doi.org/10.5061/dryad.n5q05>
"redsquirrels"
