# Interactive pedigree plot (Plotly wrapper around ggPedigree)

Generates an interactive HTML widget built on top of the static
ggPedigree output. All layout, styling, and connection logic are
inherited from ggPedigree(); this function simply augments the plot with
Plotly hover, zoom, and pan functionality.

## Usage

``` r
ggPedigreeInteractive(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  patID = "patID",
  matID = "matID",
  twinID = "twinID",
  status_column = NULL,
  tooltip_columns = NULL,
  focal_fill_column = NULL,
  overlay_column = NULL,
  config = list(optimize_plotly = TRUE),
  debug = FALSE,
  return_widget = TRUE,
  phantoms = FALSE,
  ...
)

ggpedigreeInteractive(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  patID = "patID",
  matID = "matID",
  twinID = "twinID",
  status_column = NULL,
  tooltip_columns = NULL,
  focal_fill_column = NULL,
  overlay_column = NULL,
  config = list(optimize_plotly = TRUE),
  debug = FALSE,
  return_widget = TRUE,
  phantoms = FALSE,
  ...
)

ggpedigreeinteractive(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  patID = "patID",
  matID = "matID",
  twinID = "twinID",
  status_column = NULL,
  tooltip_columns = NULL,
  focal_fill_column = NULL,
  overlay_column = NULL,
  config = list(optimize_plotly = TRUE),
  debug = FALSE,
  return_widget = TRUE,
  phantoms = FALSE,
  ...
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

- patID:

  Character string specifying the column name for paternal lines
  Defaults to "patID".

- matID:

  Character string specifying the column name for maternal lines
  Defaults to "matID".

- twinID:

  Character string specifying the column name for twin IDs. Defaults to
  "twinID".

- status_column:

  Character string specifying the column name for affected status.
  Defaults to NULL.

- tooltip_columns:

  Character vector of column names to show when hovering. Defaults to
  c("personID", "sex"). Additional columns present in \`ped\` can be
  supplied – they will be added to the Plotly tooltip text. Defaults to
  NULL, which uses the default tooltip columns.

- focal_fill_column:

  Character string specifying the column name for focal fill color.

- overlay_column:

  Character string specifying the column name for overlay alpha values.

- config:

  A list of configuration options for customizing the plot. See
  getDefaultPlotConfig for details. The list can include:

  code_male

  :   Integer or string. Value identifying males in the sex column.
      (typically 0 or 1) Default: 1.

  segment_spouse_color, segment_self_color

  :   Character. Line colors for respective connection types.

  segment_sibling_color, segment_parent_color, segment_offspring_color

  :   Character. Line colors for respective connection types.

  label_text_size, point_size, segment_linewidth

  :   Numeric. Controls text size, point size, and line thickness.

  generation_height

  :   Numeric. Vertical spacing multiplier between generations. Default:
      1.

  shape_unknown, shape_female, shape_male, status_shape_affected

  :   Integers. Shape codes for plotting each group.

  sex_shape_labels

  :   Character vector of labels for the sex variable. (default:
      c("Female", "Male", "Unknown"))

  unaffected, affected

  :   Values indicating unaffected/affected status.

  sex_color_include

  :   Logical. If TRUE, uses color to differentiate sex.

  label_max_overlaps

  :   Maximum number of overlaps allowed in repelled labels.

  label_segment_color

  :   Color used for label connector lines.

- debug:

  Logical. If TRUE, prints debugging information. Default: FALSE.

- return_widget:

  Logical; if TRUE (default) returns a plotly htmlwidget. If FALSE,
  returns the underlying plotly object (useful for further customization
  before printing).

- phantoms:

  Logical. If TRUE, adds phantom parents for individuals without
  parents.

- ...:

  Additional arguments passed to \`ggplot2\` functions.

## Value

A plotly htmlwidget (or plotly object if \`return_widget = FALSE\`)

## Examples

``` r
library(BGmisc)
data("potter")
ggPedigreeInteractive(potter, famID = "famID", personID = "personID")

{"x":{"data":[{"x":[2,1,null,null,0,null,1,2,null,3,4,null,4,3,null,null,1.5,null,4,3,null,3,4,null,8.5,7.5,null,7.5,8.5,null,6,5,null,null,7,null,null,8,null,10,9,null,null,11,null,13,12,null,5,6,null,12,13,null,null,14,null,9,10,null,null,2.2250000000000001,null,null,3.2250000000000001,null,null,4.2249999999999996,null,null,5.2249999999999996,null,null,6.2249999999999996,null,null,11.5,null,null,12.5,null,null,13.5,null,null,9,null,null,10,null,-0,1,null,1,-0,null,3.5,2.5,null,2.5,3.5,null,14,13,null,13,14],"y":[-2,-2,null,null,-2,null,-2,-2,null,-2,-2,null,-2,-2,null,null,-3,null,-3,-3,null,-3,-3,null,-2,-2,null,-2,-2,null,-3,-3,null,null,-3,null,null,-3,null,-3,-3,null,null,-3,null,-3,-3,null,-3,-3,null,-3,-3,null,null,-3,null,-3,-3,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,null,-4,null,-1,-1,null,-1,-1,null,-1,-1,null,-1,-1,null,-2,-2,null,-2,-2],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[0.5,0.5,null,0.5,0.5,null,3,3,null,3,3,null,null,null,null,1.5,1.5,null,3,3.5,null,8,8,null,null,null,null,null,null,null,8,8,null,8,8,null,8,8,null,8,8,null,8,8,null,8,8,null,null,null,null,13.5,13.5,null,13.5,13.5,null,null,null,null,3.2250000000000001,3.5,null,3.2250000000000001,3.5,null,3.2250000000000001,3.5,null,5.7249999999999996,5.5,null,5.7249999999999996,5.5,null,12.5,12.5,null,12.5,12.5,null,12.5,12.5,null,9.5,9.5,null,9.5,9.5,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"y":[-1.5,-1,null,-1.5,-1,null,-1.5,-1,null,-1.5,-1,null,null,null,null,-2.5,-2,null,-2.5,-2,null,-2.5,-2,null,null,null,null,null,null,null,-2.5,-2,null,-2.5,-2,null,-2.5,-2,null,-2.5,-2,null,-2.5,-2,null,-2.5,-2,null,null,null,null,-2.5,-2,null,-2.5,-2,null,null,null,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,-3.5,-3,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[1,0.5,null,0,0.5,null,2,3,null,4,3,null,3,null,null,1.5,1.5,null,3,3,null,4,8,null,7.5,null,null,8.5,null,null,5,8,null,9,8,null,11,8,null,12,8,null,6,null,null,13,13.5,null,14,13.5,null,10,null,null,2.2250000000000001,3.2250000000000001,null,3.2250000000000001,3.2250000000000001,null,4.2249999999999996,3.2250000000000001,null,5.2249999999999996,5.7249999999999996,null,6.2249999999999996,5.7249999999999996,null,11.5,12.5,null,12.5,12.5,null,13.5,12.5,null,9,9.5,null,10,9.5,null,1,null,null,-0,null,null,2.5,null,null,3.5,null,null,13,null,null,14,null],"y":[-1.5,-1.5,null,-1.5,-1.5,null,-1.5,-1.5,null,-1.5,-1.5,null,-1.5,null,null,-2.5,-2.5,null,-2.5,-2.5,null,-2.5,-2.5,null,-1.5,null,null,-1.5,null,null,-2.5,-2.5,null,-2.5,-2.5,null,-2.5,-2.5,null,-2.5,-2.5,null,-2.5,null,null,-2.5,-2.5,null,-2.5,-2.5,null,-2.5,null,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-3.5,-3.5,null,-0.5,null,null,-0.5,null,null,-0.5,null,null,-0.5,null,null,-1.5,null,null,-1.5,null],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[7.5,8,null,7.5,8],"y":[-2.5,-2.5,null,-2.5,-2.5],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[7,7.5,null,8,7.5],"y":[-3,-2.5,null,-3,-2.5],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[7.2999999999999998,7.7000000000000002,null,7.7000000000000002,7.2999999999999998],"y":[-2.7000000000000002,-2.7000000000000002,null,-2.7000000000000002,-2.7000000000000002],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[1,1,null,0,0,null,2,2,null,4,4,null,3,3,null,1.5,1.5,null,3,3,null,4,4,null,7.5,7.5,null,8.5,8.5,null,5,5,null,9,9,null,11,11,null,12,12,null,6,6,null,13,13,null,14,14,null,10,10,null,2.2250000000000001,2.2250000000000001,null,3.2250000000000001,3.2250000000000001,null,4.2249999999999996,4.2249999999999996,null,5.2249999999999996,5.2249999999999996,null,6.2249999999999996,6.2249999999999996,null,11.5,11.5,null,12.5,12.5,null,13.5,13.5,null,9,9,null,10,10,null,1,1,null,-0,-0,null,2.5,2.5,null,3.5,3.5,null,13,13,null,14,14],"y":[-1.5,-2,null,-1.5,-2,null,-1.5,-2,null,-1.5,-2,null,null,-2,null,-2.5,-3,null,-2.5,-3,null,-2.5,-3,null,null,-2,null,null,-2,null,-2.5,-3,null,-2.5,-3,null,-2.5,-3,null,-2.5,-3,null,null,-3,null,-2.5,-3,null,-2.5,-3,null,null,-3,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,-3.5,-4,null,null,-1,null,null,-1,null,null,-1,null,null,-1,null,null,-2,null,null,-2],"text":"","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[0,2,4,4,8.5,6,13,14,10,4.2249999999999996,5.2249999999999996,11.5,12.5,9,10,1,3.5,14],"y":[-2,-2,-2,-3,-2,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-1,-1,-2],"text":["personID: 2<br>sex: 0","personID: 3<br>sex: 0","personID: 4<br>sex: 0","personID: 8<br>sex: 0","personID: 10<br>sex: 0","personID: 17<br>sex: 0","personID: 18<br>sex: 0","personID: 19<br>sex: 0","personID: 20<br>sex: 0","personID: 23<br>sex: 0","personID: 24<br>sex: 0","personID: 26<br>sex: 0","personID: 27<br>sex: 0","personID: 29<br>sex: 0","personID: 30<br>sex: 0","personID: 101<br>sex: 0","personID: 103<br>sex: 0","personID: 105<br>sex: 0"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(68,1,84,1)","opacity":1,"size":15.118110236220474,"symbol":"circle","line":{"width":1.8897637795275593,"color":"rgba(68,1,84,1)"}},"hoveron":"points","name":"0","legendgroup":"0","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[1,3,1.5,3,7.5,5,7,8,9,11,12,2.2250000000000001,3.2250000000000001,6.2249999999999996,13.5,-0,2.5,13],"y":[-2,-2,-3,-3,-2,-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-1,-1,-2],"text":["personID: 1<br>sex: 1","personID: 5<br>sex: 1","personID: 6<br>sex: 1","personID: 7<br>sex: 1","personID: 9<br>sex: 1","personID: 11<br>sex: 1","personID: 12<br>sex: 1","personID: 13<br>sex: 1","personID: 14<br>sex: 1","personID: 15<br>sex: 1","personID: 16<br>sex: 1","personID: 21<br>sex: 1","personID: 22<br>sex: 1","personID: 25<br>sex: 1","personID: 28<br>sex: 1","personID: 102<br>sex: 1","personID: 104<br>sex: 1","personID: 106<br>sex: 1"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(253,231,37,1)","opacity":1,"size":15.118110236220474,"symbol":"square","line":{"width":1.8897637795275593,"color":"rgba(253,231,37,1)"}},"hoveron":"points","name":"1","legendgroup":"1","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":23.305936073059364,"r":7.3059360730593621,"b":10.958904109589042,"l":10.958904109589042},"paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.70000000647490612,14.700000000308329],"tickmode":"array","ticktext":["0","5","10"],"tickvals":[0,5,10],"categoryorder":"array","categoryarray":["0","5","10"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":false,"tickfont":{"color":null,"family":null,"size":0},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":false,"gridcolor":null,"gridwidth":0,"zeroline":false,"anchor":"y","title":{"text":"","font":{"color":null,"family":null,"size":0}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-4.1749999999999998,-0.32499999999999996],"tickmode":"array","ticktext":["1","2","3","4"],"tickvals":[-1,-2,-3,-4],"categoryorder":"array","categoryarray":["1","2","3","4"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":false,"tickfont":{"color":null,"family":null,"size":0},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":false,"gridcolor":null,"gridwidth":0,"zeroline":false,"anchor":"x","title":{"text":"","font":{"color":null,"family":null,"size":0}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","layer":"below","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498},"title":{"text":"Sex","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"194018ca299c":{"x":{},"y":{},"xend":{},"yend":{},"type":"scatter"},"194031da9124":{"x":{},"y":{},"xend":{},"yend":{}},"19407b213fe5":{"x":{},"y":{},"xend":{},"yend":{}},"194018f7746f":{"x":{},"y":{},"xend":{},"yend":{}},"1940790f12d5":{"x":{},"y":{},"xend":{},"yend":{}},"1940190e6ca5":{"x":{},"y":{},"xend":{},"yend":{}},"19405e60b678":{"x":{},"y":{},"xend":{},"yend":{}},"19401495d44b":{"x":{},"y":{},"colour":{},"shape":{},"text":{}}},"cur_data":"194018ca299c","visdat":{"194018ca299c":["function (y) ","x"],"194031da9124":["function (y) ","x"],"19407b213fe5":["function (y) ","x"],"194018f7746f":["function (y) ","x"],"1940790f12d5":["function (y) ","x"],"1940190e6ca5":["function (y) ","x"],"19405e60b678":["function (y) ","x"],"19401495d44b":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}
```
