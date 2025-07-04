# BGmisc

<details>

* Version: 1.4.3.1
* GitHub: https://github.com/R-Computing-Lab/BGmisc
* Source code: https://github.com/cran/BGmisc
* Date/Publication: 2025-06-10 18:10:02 UTC
* Number of recursive dependencies: 138

Run `revdepcheck::revdep_details(, "BGmisc")` for more info

</details>

## Newly broken

*   checking running R code from vignettes ...
    ```
      'v0_network.Rmd' using 'UTF-8'... failed
      'v1_modelingvariancecomponents.Rmd' using 'UTF-8'... OK
      'v2_pedigree.Rmd' using 'UTF-8'... failed
      'v3_analyticrelatedness.Rmd' using 'UTF-8'... failed
      'v4_validation.Rmd' using 'UTF-8'... OK
      'v5_ASOIAF.Rmd' using 'UTF-8'... failed
     WARNING
    Errors in running code in vignettes:
    when running code in 'v0_network.Rmd'
      ...
    ...
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
    
    > library(ggpedigree)
    
      When sourcing 'v5_ASOIAF.R':
    Error: there is no package called 'ggpedigree'
    Execution halted
    ```

# discord

<details>

* Version: 1.2.4.1
* GitHub: https://github.com/R-Computing-Lab/discord
* Source code: https://github.com/cran/discord
* Date/Publication: 2025-06-10 16:30:02 UTC
* Number of recursive dependencies: 140

Run `revdepcheck::revdep_details(, "discord")` for more info

</details>

## Newly broken

*   checking running R code from vignettes ...
    ```
      'Power.Rmd' using 'UTF-8'... OK
      'categorical_predictors.Rmd' using 'UTF-8'... OK
      'links.Rmd' using 'UTF-8'... failed
      'plots.Rmd' using 'UTF-8'... OK
      'regression.Rmd' using 'UTF-8'... OK
     WARNING
    Errors in running code in vignettes:
    when running code in 'links.Rmd'
      ...
    
    > options(rmarkdown.html_vignette.check_title = FALSE)
    
    > library(BGmisc)
    
    > library(ggpedigree)
    
      When sourcing 'links.R':
    Error: there is no package called 'ggpedigree'
    Execution halted
    ```

