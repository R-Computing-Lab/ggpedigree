# Description

This version includes minor quality of life improvments to the code base and a few new features, but no major changes to the underlying functionality.


## Note Comment

There was one note about how a suggested package (openMX) wasn't available for r-oldrel-windows-x86_64. This is expected behavior due to changes in openmx dependencies. It does not impact the functionality of `ggpedigree`, as `openMX` is not a required dependency.

Therneau and and Schaid are spelled correctly in the DESCRIPTION file.

# Test Environments

1. Local OS: Windows 11 x64 (build 26220), R version 4.5.3 (2026-03-11 ucrt)
    - All package dependencies up to date as of 2026-03-13.
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/20753857768)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.


## R CMD check results

── R CMD check results ─────────────────────────── ggpedigree 1.1.0.3 ────
Duration: 2m 30.3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded


## revdepcheck results
> revdepcheck::revdep_check()

We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 1 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

### New problems
(This reports the first line of each new failure)

* BGmisc
  checking running R code from vignettes ...

This error was the consequence of moving verbose into the config options, resulting in "Error: unused argument (verbose = FALSE)". This error occurs in some vignettes, and has already been resolved in the development version of BGmisc. Version 1.5.2 has already been submitted to CRAN for review and should be processed by cran after they return from the holiday break.

── CHECK ────────────────────────────────────────────────────────────────────────────── 2 packages ──
✖ BGmisc 1.5.0                           ── E: 0  +1 | W: 0     | N: 0                               
✔ discord 1.2.4.1                        ── E: 0     | W: 0     | N: 0                               
OK: 1                                                                                              

BROKEN: 1
Total time: 6 min                                                                  


## urlchecker results
> urlchecker::url_check()
✔ All URLs are correct!
