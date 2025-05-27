# ggpedigree 0.5.0
* Added segment_linetype and custom affected labels to the `ggpedigree` function.
* Added usage of color_palette to the `ggpedigree` function.
* Added curvature option to the `ggpedigree` function.
* Add support for custom affected labels for affected individuals in the `ggpedigree` function.
* Add support for removing diagonal, upper triangle, and lower triangle in the `ggRelatednessMatrix` function. 
* Add support for labeling tiles
* Added new tests for the `ggRelatednessMatrix` function.

# ggpedigree 0.4.1
## Status: Submitted to CRAN
* Fixed a bug in the `ggpedigree` function that caused an error when using a custom ID name and requesting the plot to be returned as a ggplot object.

# ggpedigree 0.4.0
* Allows support for character-based IDs
* Added linejoin, lineend, segment_self_linetype, option to the `ggpedigree` functions.
* Added unit tests for calculateConnections, calculateConnections, and ggpedigree functions.
* Refactored ggpedigree function into ggpedigree.core and .addScales and .addLabels functions to improve readability and maintainability.
* Renamed symKey to makeSymmetricKey, extended it to support character-based IDs, and added unit tests.
* Added a new function `ggPedigreeInteractive` to create interactive pedigree plots using `plotly`. Added a vignette to demonstrate its usage.
* Added redsquirrels dataset to the package for testing and examples.
* Added a new function `ggRelatednessMatrix` and subfunction `ggRelatednessMatrix.core` to create heatmaps of relatedness matrices.
* Added new vignette to demonstrate ggRelatednessMatrix
* Added graphic tests for `ggpedigree`, `ggPedigreeInteractive`, and `ggRelatednessMatrix` functions.
* Updated the README and vignettes to reflect the new features and improvements.
* Updated description to comply with CRAN policies.

# ggpedigree 0.3.0
* Expose more labeling options in the `ggpedigree` function to allow for more customization, including nudging labels, and changing the variable used.
* Added option to add an outline to the pedigree plot.
* Made the config options more consistent and user-friendly.
* Enhance the narrative of the plotting vignette to demonstrate the new features and provide clearer examples.
* Added missing examples to the `ggpedigree` function documentation.

# ggpedigree 0.2.0
* Extended functionality to include new plotting features, like handling multiple instances of the same individual in a pedigree.
* Improved documentation and examples for better user guidance.
* Added unit tests for describeHelpers

# ggpedigree 0.1.0
* Implemented pedigree plotting functions for `ggplot2`.
* Added vignette to demonstrate the use of the package in basic plotting.
* Created a `DESCRIPTION` file to define the package and its dependencies.
* Added a `LICENSE` file to specify the terms under which the package can be used.
* Created a `CODE_OF_CONDUCT.md` file to outline the expected behavior of contributors and maintainers.
* Added a `NEWS.md` file to track changes to the package.
* Created a `CONTRIBUTING.md` file to guide contributors on how to contribute to the package.
* Added a `README.Rmd` file to provide an overview of the package and its functions.
* Added a `cran-comments.md` file to document the submission process to CRAN.
* Initial version launched
