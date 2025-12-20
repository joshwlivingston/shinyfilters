# Create a shiny Input

Selects and creates a shiny input based the type of object `x` and other
arguments.

## Usage

``` r
filterInput(x, ...)
```

## Arguments

- x:

  The object used to create the input.

- ...:

  Arguments used for input selection or passed to the selected input.
  See details.

## Value

One of the following shiny inputs is returned, based on the type of
object passed to `x`, and other specified arguments. See
[`vignette("filter-input-catalog")`](https://joshwlivingston.github.io/shinyfilters/articles/filter-input-catalog.md)
for the full list of examples.

|                                                                            |                                  |                                 |
|----------------------------------------------------------------------------|----------------------------------|---------------------------------|
| **Value**                                                                  | **`x`**                          | **Arguments**                   |
| [shiny::dateInput](https://rdrr.io/pkg/shiny/man/dateInput.html)           | Date, POSIXt                     | *default*                       |
| [shiny::dateRangeInput](https://rdrr.io/pkg/shiny/man/dateRangeInput.html) | Date, POSIXt                     | `range = TRUE`                  |
| [shiny::numericInput](https://rdrr.io/pkg/shiny/man/numericInput.html)     | numeric                          | *default*                       |
| [shiny::radioButtons](https://rdrr.io/pkg/shiny/man/radioButtons.html)     | character, factor, list, logical | `radio = TRUE`                  |
| [shiny::selectInput](https://rdrr.io/pkg/shiny/man/selectInput.html)       | character, factor, list, logical | *default*                       |
| [shiny::selectizeInput](https://rdrr.io/pkg/shiny/man/selectInput.html)    | character, factor, list, logical | `selectize = TRUE`              |
| [shiny::sliderInput](https://rdrr.io/pkg/shiny/man/sliderInput.html)       | numeric                          | `slider = TRUE`                 |
| [shiny::textAreaInput](https://rdrr.io/pkg/shiny/man/textAreaInput.html)   | character                        | `textbox = TRUE`, `area = TRUE` |
| [shiny::textInput](https://rdrr.io/pkg/shiny/man/textInput.html)           | character                        | `textbox = TRUE`                |

## Details

The following arguments passed to `...` are supported:

|             |                                                                                                                                                                                                                                                                                                                                           |
|-------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `area`      | *(character)*. Logical. Controls whether to use [shiny::textAreaInput](https://rdrr.io/pkg/shiny/man/textAreaInput.html) (`TRUE`) or [shiny::textInput](https://rdrr.io/pkg/shiny/man/textInput.html) (`FALSE`, default). Only applies when `textbox` is `TRUE`.                                                                          |
| `range`     | *(Date, POSIXt)*. Logical. Controls whether to use [shiny::dateRangeInput](https://rdrr.io/pkg/shiny/man/dateRangeInput.html) (`TRUE`) or [shiny::dateInput](https://rdrr.io/pkg/shiny/man/dateInput.html) (`FALSE`, default).                                                                                                            |
| `selectize` | *(character, factor, list, logical)*. Logical. Controls whether to use [shiny::selectizeInput](https://rdrr.io/pkg/shiny/man/selectInput.html) (`TRUE`) or [shiny::selectInput](https://rdrr.io/pkg/shiny/man/selectInput.html) (`FALSE`, default). For character vectors, `selectize` only applies if `textbox` is `FALSE`, the default. |
| `slider`    | *(numeric)*. Logical. Controls whether to use [shiny::sliderInput](https://rdrr.io/pkg/shiny/man/sliderInput.html) (`TRUE`) or [shiny::numericInput](https://rdrr.io/pkg/shiny/man/numericInput.html) (`FALSE`, default) .                                                                                                                |
| `textbox`   | *(character)*. Logical. Controls whether to use a text input (`TRUE`) or a dropdown input (`FALSE`, default).                                                                                                                                                                                                                             |
| `ns`        | An optional namespace created by [`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html). Useful when using `filterInput()` on a data.frame inside a shiny module.                                                                                                                                                                         |

Remaining arguments passed to `...` are passed to the
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
or the selected input function.

## Examples

``` r
if (FALSE) { # interactive()
library(shiny)

ui <- fluidPage(
   sidebarLayout(
     sidebarPanel(
       #############################################
       # Create a filterInput() inside a shiny app:
       filterInput(
        x = letters,
        inputId = "letter",
        label = "Pick a letter:"
       )
       #############################################
     ),
     mainPanel(
       textOutput("selected_letter")
     )
   )
)

server <- function(input, output, session) {
   output$selected_letter <- renderText({
     paste("You selected:", input$letter)
   })
}

shinyApp(ui, server)
}
```
