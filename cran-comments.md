# Description

This hotpatch ensures that if internet connectivity is unavailable and thus plot.ly can't be reached, the vignettes will fall back to the larger version of the resource.  https://github.com/R-Computing-Lab/ggpedigree/commit/dfdc489ff510c6690aeda9d9a6a0a0352f28c4be


## Note Comment

There remains one note about how a suggested package (openMX) wasn't available for r-oldrel-windows-x86_64. This is expected behavior due to changes in openmx dependencies. It does not impact the functionality of `ggpedigree`, as `openMX` is not a required dependency.

Therneau and and Schaid are spelled correctly in the DESCRIPTION file.

# Test Environments

1. Local OS: Windows 11 x64 (build 26220), R version 4.5.3 (2026-03-11 ucrt)
    - All package dependencies up to date as of 2026-03-15.
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/23117036735)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.


## R CMD check results

── R CMD check results ─────────────── ggpedigree 1.1.1.1 ────
Duration: 2m 22.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded


## revdepcheck results
> revdepcheck::revdep_check()

── CHECK ─────────────────────────────────────────────────── 2 packages ──
✔ BGmisc 1.6.0.1                         ── E: 0     | W: 0     | N: 0    

✔ discord 1.3                            ── E: 0     | W: 0     | N: 0    

OK: 2                                                                   

BROKEN: 0
Total time: 6 min                                                              


## urlchecker results
> urlchecker::url_check()
✔ All URLs are correct!
