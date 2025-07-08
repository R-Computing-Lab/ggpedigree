library(hexSticker)
library(stringr)
library(rsvg)
library(magick)
library(ggpedigree)
library(BGmisc)
library(ggplot2)
# Step 1 create the cat
## read in file
file <- "data-raw/catlogo.svg"
# Render with rsvg into png
svgdata <- readLines(file)
svg_string <- paste(svgdata, collapse = "\n")


nold_colors <- c(
  "#CCE4ED", # st0_color
  "#5f1905", # st1_color
  "#D9EBF4", # st2_color
  "#ce370b", # st3_color
  "#F45F34", # st4_color
  #  "#C15B65", # st6_color
  #  "#A54653", # st7_color
  "#842307" # st9_color
)

new_colors <- c(
  "#E4E5E7", # st0_color
  "#4A4A4A", # st1_color
  "#F0F0F2", # st2_color
  "#888C94", # st3_color
  "#B0B3B8", # st4_color
  #  "#A3A8AC", # st6_color
  #  "#6C7077", # st7_color
  "#30333A" # st9_color
)

color_replacements <- setNames(new_colors, nold_colors)

# Use str_replace_all to replace all occurrences of the old color
modified_svg_string <- str_replace_all(svg_string, color_replacements)

# Save the modified SVG string to a new file
writeLines(modified_svg_string, "data-raw/recoloredcat.svg")
# Render the modified SVG to PNG
rsvg::rsvg_png("data-raw/recoloredcat.svg", "data-raw/recoloredcat.png", width = 300)

## Step 2: Generate the background graph
data(potter)
p <- ggpedigree(potter,
                config=
                  list(label_include=FALSE,
                       point_size=10,
                       segment_linewidth=2)) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA)
  )  + ggplot2::guides(shape = "none",
                       color = "none",
                       fill = "none")

ggsave("data-raw/bgplot.png", p, width = 8, height = 8.5, bg = "transparent", dpi = 300)

## Step 3: Combine background and logo
logo_img <- image_read("data-raw/recoloredcat.png")
graph_img <- image_read("data-raw/bgplot.png")

# Match sizes
graph_img <- image_resize(graph_img, geometry_size_pixels(width = 800, height = 800))


combined_img <- image_composite(graph_img,logo_img, operator = "Over",gravity = "South",offset="+10-20")

# Save combined image
image_write(combined_img, path = "data-raw/combined.png", format = "png")



sticker("data-raw/combined.png", package = "ggpedigree", p_size = 20, s_x = 1-.05, s_y = .900, s_width = .6, h_fill = "#0fa1e0", h_color = "#333333", p_color = "white", filename = "man/figures/hex.png")
