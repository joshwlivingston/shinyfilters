# Create a shiny Input

Updates a shiny input based the type of object `x` and other arguments.

## Usage

``` r
updateFilterInput(x, ...)
```

## Arguments

- x:

  The object used to create the input.

- ...:

  Arguments used for input selection or passed to the selected input
  update function. See details.

## Value

The result of the following shiny input updates is returned, based on
the type of object passed to `x`, and other specified arguments.

|                                                                                        |                                  |                                 |
|----------------------------------------------------------------------------------------|----------------------------------|---------------------------------|
| **Value**                                                                              | **`x`**                          | **Arguments**                   |
| [shiny::updateDateInput](https://rdrr.io/pkg/shiny/man/updateDateInput.html)           | Date, POSIXt                     | *default*                       |
| [shiny::updateDateRangeInput](https://rdrr.io/pkg/shiny/man/updateDateRangeInput.html) | Date, POSIXt                     | `range = TRUE`                  |
| [shiny::updateNumericInput](https://rdrr.io/pkg/shiny/man/updateNumericInput.html)     | numeric                          | *default*                       |
| [shiny::updateRadioButtons](https://rdrr.io/pkg/shiny/man/updateRadioButtons.html)     | character, factor, list, logical | `radio = TRUE`                  |
| [shiny::updateSelectInput](https://rdrr.io/pkg/shiny/man/updateSelectInput.html)       | character, factor, list, logical | *default*                       |
| [shiny::updateSelectizeInput](https://rdrr.io/pkg/shiny/man/updateSelectInput.html)    | character, factor, list, logical | `selectize = TRUE`              |
| [shiny::updateSliderInput](https://rdrr.io/pkg/shiny/man/updateSliderInput.html)       | numeric                          | `slider = TRUE`                 |
| [shiny::updateTextAreaInput](https://rdrr.io/pkg/shiny/man/updateTextAreaInput.html)   | character                        | `textbox = TRUE`, `area = TRUE` |
| [shiny::updateTextInput](https://rdrr.io/pkg/shiny/man/updateTextInput.html)           | character                        | `textbox = TRUE`                |

## Details

The following arguments passed to `...` are supported:

|             |                                                                                                                                                                                                                                                                                                                                                                   |
|-------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `area`      | *(character)*. Logical. Controls whether to use [shiny::updateTextAreaInput](https://rdrr.io/pkg/shiny/man/updateTextAreaInput.html) (`TRUE`) or [shiny::updateTextInput](https://rdrr.io/pkg/shiny/man/updateTextInput.html) (`FALSE`, default). Only applies when `textbox` is `TRUE`.                                                                          |
| `range`     | *(Date, POSIXt)*. Logical. Controls whether to use [shiny::updateDateRangeInput](https://rdrr.io/pkg/shiny/man/updateDateRangeInput.html) (`TRUE`) or [shiny::updateDateInput](https://rdrr.io/pkg/shiny/man/updateDateInput.html) (`FALSE`, default).                                                                                                            |
| `selectize` | *(character, factor, list, logical)*. Logical. Controls whether to use [shiny::updateSelectizeInput](https://rdrr.io/pkg/shiny/man/updateSelectInput.html) (`TRUE`) or [shiny::updateSelectInput](https://rdrr.io/pkg/shiny/man/updateSelectInput.html) (`FALSE`, default). For character vectors, `selectize` only applies if `textbox` is `FALSE`, the default. |
| `slider`    | *(numeric)*. Logical. Controls whether to use [shiny::updateSliderInput](https://rdrr.io/pkg/shiny/man/updateSliderInput.html) (`TRUE`) or [shiny::updateNumericInput](https://rdrr.io/pkg/shiny/man/updateNumericInput.html) (`FALSE`, default) .                                                                                                                |
| `textbox`   | *(character)*. Logical. Controls whether to update a text input (`TRUE`) or a dropdown input (`FALSE`, default).                                                                                                                                                                                                                                                  |

Remaining arguments passed to `...` are passed to
[`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
or the selected input update function.

## Examples

``` r
if (FALSE) { # interactive()
library(shiny)

fruits <- list(
  "a" = c("apples", "avocados"),
  "b" = c("bananas", "blueberries"),
  "c" = c("cherries", "cantaloupe")
)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      filterInput(
        x = letters[1:3],
        inputId = "letter",
        label = "Pick a letter:",
       multiple = TRUE
      ),
      filterInput(
        x = fruits,
        inputId = "fruits",
        label = "Pick a fruit:"
      )
    ),
   mainPanel()
  )
)

server <- function(input, output, session) {
  shiny::observe({
    fruits_filtered <- fruits
    if (!is.null(input$letter) && length(input$letter) != 0L) {
      fruits_filtered <- fruits[input$letter]
    }
    #########################################################
    # 2. Call updateFilterInput() inside the shiny server:
    updateFilterInput(x = fruits_filtered, inputId = "fruits")
    #########################################################
  })
}
shinyApp(ui, server)
}
```
