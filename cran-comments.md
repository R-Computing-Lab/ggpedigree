
# Description
This version adds new features and bug fixes to the `ggpedigree` package, enhancing its functionality for visualizing pedigrees with `ggplot2` and `plotly`. I've done my best to keep the files in this package as small as possible, but plotly makes this difficult.

I am moving the one of the datasets (ASOIAF) from BGmisc to ggpedigree. I maintain both packages. Once this package is on CRAN, I will upload the new version of BGmisc that does not include the ASOIAF dataset. 

## revdepcheck results

We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 2 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

### New problems
(This reports the first line of each new failure)

* `BGmisc` (version 1.4.3.1)
  checking running R code from vignettes ...

* `discord ` (version 1.2.4.1)
  checking running R code from vignettes ...
  

# Test Environments

1. Local OS: Windows 11 x64 (build 26120), R version 4.5.0 (2025-04-11 ucrt)
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/16078267231)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.
3. **win-builder.r-project.org**:
    - [Link](https://win-builder.r-project.org/6PjJHO4x4fYm/00check.log)
    - Windows with the latest R release.

## R CMD check results

── R CMD check results ────────────────────────── ggpedigree 0.8.0 ────
Duration: 2m 21.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded
