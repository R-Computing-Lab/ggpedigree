## ----warning=FALSE, message=FALSE---------------------------------------------
library(ggBGmisc)
library(BGmisc)

## -----------------------------------------------------------------------------
data("potter")
ggPedigree(potter, famID_col = "famID", personID_col = "personID", code_male = 1)

data("hazard")
ggPedigree(hazard, famID_col = "famID", personID_col = "ID", code_male = 0)

