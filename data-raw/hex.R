library(hexSticker)
library(grid)
#remotes::install_github('coolbutuseless/svgparser')
#library(svgparser)
library(svgtools)
library(xml2)
## read in file
file <- 'data-raw/catlogo.svg'
svg <- svgtools::read_svg(file = file, summary = TRUE)

ls <- grid::grid.ls()
print(head(ls))
names <- ls$name[grepl('pathgrob', ls$name)]
print(head(names))


fills <- sapply(names, function(name) {
  ngrob <- grid.get(gPath(name))
  ngrob$gp$fill
})
ncols <- length(unique(fills))

table(fills)



sticker("data-raw/logo_archie.png", package = "ggpedigree", p_size = 20, s_x = 1, s_y = .75, s_width = .6, h_fill = "#0fa1e0", h_color = "#333333", p_color = "white", filename = "man/figures/hex.png")
