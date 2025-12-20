# Get Multiple Values from a shiny Input Object

Retrieves multiple input values from a shiny `input` object based on the
names provided in `x`.

## Usage

``` r
get_input_values(input, x, ...)
```

## Arguments

- input:

  A shiny `input` object, i.e., the `input` argument to the shiny
  server.

- x:

  A character vector of input names, or a data.frame whose column names
  are converted to input names via
  [`get_input_ids()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_ids.md).

- ...:

  Passed onto methods.

## Value

A named list of input values corresponding to the names in `x`.

## Examples

``` r
if (FALSE) { # interactive()
library(shiny)
df <- data.frame(
  name = c("Alice", "Bob"),
  age = c(25, 30),
  completed = c(TRUE, FALSE)
)
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      filterInput(df)
    ),
    mainPanel(
      verbatimTextOutput("output_all"),
      verbatimTextOutput("output_subset")
    )
  )
)
server <- function(input, output, session) {
  output$output_all <- renderPrint({
    get_input_values(input, df)
  })
  output$output_subset <- renderPrint({
    get_input_values(input, c("name", "completed"))
  })
}
shinyApp(ui, server)
}
```
