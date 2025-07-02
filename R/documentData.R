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

#' A pedigree of ice and fire
#'
#' A structured dataset of fictional characters derived from the Song of Ice and Fire universe by George R. R. Martin.
#' The character relationships were partially based on a GEDCOM file publicly posted in the [Westeros.org forum](https://asoiaf.westeros.org/index.php?/topic/88863-all-the-family-trees/), and were updated based on publicly available summaries from [A Wiki of Ice and Fire](https://awoiaf.westeros.org/index.php/Main_Page).
#' This dataset was created for educational and illustrative purposes, such as demonstrating pedigree construction, relationship tracing, and algorithmic logic in family-based data.
#' It includes no narrative content or protected expression from the original works.
#' No rights to the characters, names, or intellectual property of George R. R. Martin or HBO are claimed, and the dataset is not intended to represent any real individuals or families.
#'
#'
#'
#' The variables are as follows:
#' \itemize{
#'   \item \code{id}:  Person identification variable
#'   \item \code{momID}:  ID of the mother
#'   \item \code{dadID}:  ID of the father
#'   \item \code{name}:  Name of the person
#'   \item \code{sex}: Biological sex
#'   \item \code{twinID}:  ID of the twin, if applicable
#'   \item \code{zygosity}: Zygosity of the twin, if applicable. mz is monozygotic; dz is dizygotic
#'   }
#'
#' @docType data
#' @keywords datasets
#' @name ASOIAF
#' @usage data(ASOIAF)
#' @format A data frame with 503 observations
NULL
