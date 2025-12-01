# Run the backend server for filterInput

Run the backend server for filterInput

## Usage

``` r
serverFilterInput(x, ...)
```

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

df_shared <- tibble::tibble(
   x = letters,
   y = sample(c("red", "green", "blue"), 26, replace = TRUE) |> use_radio(),
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
