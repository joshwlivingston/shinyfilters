# Return A data.frame's filterInput() Values

Returns a list of the input values corresponding to the data.frame
passed to
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

## Usage

``` r
get_input_values(input, x, ...)
```

## Arguments

- input:

  An `input` object from a shiny server.

- x:

  Either a `data.frame` or a character vector. If `x` is a `data.frame`,
  `get_input_values()` is called on the column names of `x`.

## Value

A `reactivevalues` list of input values.

## Examples

``` r
if (FALSE) { # interactive()
df_shared <- data.frame(
  x = letters,
  y = sample(c("red", "green", "blue"), 26, replace = TRUE)
)

ui <- bslib::page_sidebar(
   sidebar = bslib::sidebar(
     filterInput(df_shared, selectize = TRUE, slider = TRUE, multiple = TRUE)
   ),
  DT::DTOutput("df_full"),
  shiny::verbatimTextOutput("inputs"),
  DT::DTOutput("df_filt")
)
server <- function(input, output, session) {
  output$df_full <- DT::renderDT(DT::datatable(df_shared))

  input_values <-
    shiny::reactive(get_input_values(input, df_shared)) |>
    shiny::throttle(2000)
  output$inputs <- shiny::renderPrint(input_values())

  df_filt <- shiny::reactiveVal(df_shared)
  output$df_filt <- DT::renderDT(DT::datatable(df_filt()))

  shiny::observe({
    df_now <- df_shared
    mapply(function(input_value, nm) {
      df_now <<- apply_filter(df_now, input_value, nm)
    }, input_values(), names(input_values()))
    df_filt(df_now)
  })

  shiny::observe({
    updateFilterInput(df_filt())
  })
}
shiny::shinyApp(ui, server)
}
```
