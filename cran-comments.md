
# Description
This version eliminates the dependency on the `kinship2` package by folding in its relevant functions directly into `ggpedigree`. The `kinship2` package is now optional and only required for the `plotPedigree` function, which serves as a wrapper around `kinship2` functionality. This change enhances the maintainability of `ggpedigree` and reduces the number of dependencies users need to install.

 
# Test Environments

1. Local OS: Windows 11 x64 (build 26220), R version 4.5.2 (2025-10-31 ucrt)
    - RStudio version 37.6.1, 2025.09.2+418 (desktop)
    - All package dependencies up to date as of 2025-11-29.
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/19786727931)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.


## R CMD check results

── R CMD check results ──────────────── ggpedigree 1.0.0 ────
Duration: 1m 36.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded

## revdepcheck results

revdepcheck::revdep_check() found 2 reverse dependencies to check.
We checked those reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package. 

 * We saw 0 new problems
 * We failed to check 0 packages

── CHECK ──────────────────────────────────────────────────── 2 packages ──
✔ BGmisc 1.5.0                           ── E: 0     | W: 0     | N: 0     
✔ discord 1.2.4.1                        ── E: 0     | W: 0     | N: 0     
OK: 2                                                                    

BROKEN: 0
Total time: 6 min
