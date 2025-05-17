#' Kluane Red Squirrel Data
#'
#' These data are from the Kluane Red Squirrel Project, which has been running since 1987. The data are available on Dryad at https://doi.org/10.5061/dryad.2z34tmpr3. The pedigree data are in the file `Pedigree_dryadcopy.xlsx` and the phenotype data are in the file `LRS_fordryad.xlsx`.
#'
#' @format ## `redsquirrels`
#' A data frame with 7799 rows and 5 columns:
#' \describe{
#'   \item{personID}{Unique identifier for each squirrel}
#'   \item{famID}{Unique identifier for each family. Derived from ped2fam}
#'   \item{momID, dadID}{Unique identifiers for each squirrel's parents}
#'   \item{sex}{Biological sex of the squirrel}
#'   ...
#' }
#' @docType data
#' @keywords datasets
#' @name redsquirrels
#' @usage data(redsquirrels)
#' @source <https://doi.org/10.5061/dryad.2z34tmpr3>
"redsquirrels"
