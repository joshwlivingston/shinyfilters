# Run the backend server for filterInput

Run the backend server for filterInput

## Usage

``` r
serverFilterInput(x, filter_combine_method, input, ...)
```

## Arguments

- x:

  An object being filtered; typically a data.frame.

- filter_combine_method:

  A string or function indicating how to combine multiple filters. If a
  string, it can be "and" (or "&") for logical AND, or "or" (or "\|")
  for logical OR. If a function, it should take two logical vectors and
  return a combined logical vector.

- input:

  A shiny `input` object, or a reactive that resolves to a list of named
  values.

- ...:

  Additional arguments passed to
  [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md).

## Value

A list with a single element, `get_input_values`, which is a reactive
function that returns the current filter input values as a named list.

## Examples

``` r
if (FALSE) { # interactive()
library(bslib)
library(DT)
library(S7)
library(shiny)

must_use_radio <- new_S3_class(
   class = "must_use_radio",
   constructor = function(.data) .data
)
method(filterInput, must_use_radio) <- function(x, ...) {
   call_filter_input(x, shiny::radioButtons, ...)
}
method(updateFilterInput, must_use_radio) <- function(x, ...) {
   call_update_filter_input(x, shiny::updateRadioButtons, ...)
}

use_radio <- function(x) {
   structure(x, class = unique(c("must_use_radio", class(x))))
}

df_shared <- data.frame(
   x = letters,
   y = use_radio(sample(c("red", "green", "blue"), 26, replace = TRUE)),
   z = round(runif(26, 0, 3.5), 2),
   q = sample(Sys.Date() - 0:7, 26, replace = TRUE)
)

filters_ui <- function(id) {
   ns <- shiny::NS(id)
   filterInput(
     x = df_shared,
     range = TRUE,
     selectize = TRUE,
     slider = TRUE,
     multiple = TRUE,
     ns = ns
   )
}

filters_server <- function(id) {
   moduleServer(id, function(input, output, session) {
     # serverFilterInput() returns a shiny::observe() expressionc
     serverFilterInput(df_shared, input = input, range = TRUE)
   })
}

ui <- page_sidebar(
   sidebar = sidebar(filters_ui("demo")),
   DTOutput("df_full"),
   verbatimTextOutput("input_values"),
   DTOutput("df_filt")
)

server <- function(input, output, session) {
   res <- filters_server("demo")
   output$df_full <- renderDT(datatable(df_shared))
   output$input_values <- renderPrint(res$get_input_values())
   output$df_filt <- renderDT(datatable(apply_filters(
     df_shared,
     res$get_input_values()
   )))
}

shinyApp(ui, server)
}
```
