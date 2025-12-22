# shinyfilters

## Overview

*shinyfilters* makes it easy to create Shiny inputs from vectors,
data.frames, and more.

- [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md):
  Create filter inputs on any object
- [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md):
  Update filter inputs
- [`serverFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/serverFilterInput.md):
  Server logic to update filter inputs
- [`apply_filters()`](https://joshwlivingston.github.io/shinyfilters/reference/apply_filters.md):
  Apply filter inputs to objects

## Installation

The latest release is available on CRAN:

``` r
# install.packages("pak")
pak::pak("shinyfilters")
```

Or, you can install the development version:

``` r
pak::pak("joshwlivingston/shinyfilters")
```

## Usage

### Vectors

``` r
library(shinyfilters)
library(shiny)

ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            # Create a filterInput() inside a shiny app:
            filterInput(
                x = letters,
                inputId = "letter",
                label = "Pick a letter:"
            )
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
```

  

### Data.frames

``` r
library(shinyfilters)

library(DT)
library(shiny)

df <- data.frame(
    x = letters,
    y = sample(c("red", "green", "blue"), 26, replace = TRUE),
    z = round(runif(26, 0, 3.5), 2),
    q = sample(Sys.Date() - 0:7, 26, replace = TRUE)
)

ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            # 1/3. Create a filterInput() for each column in a data.frame:
            filterInput(
                x = df,
                range = TRUE,
                selectize = TRUE,
                slider = TRUE,
                multiple = TRUE
            )
        ),
        mainPanel(
            DTOutput("df_full"),
            verbatimTextOutput("input_values"),
            DTOutput("df_filt")
        )
    )
)

server <- function(input, output, session) {
    output$df_full <- renderDT(datatable(df))
    # 2/3. Create a server to manage the data.frame's filterInput()'s
    res <- serverFilterInput(
        x = df, 
        input = input, 
        range = TRUE
    )
    
    # 3/3. Use the server's results
    output$input_values <- renderPrint(res$input_values)
    output$df_filt <- renderDT(datatable(
        apply_filters(df, res$input_values)
    ))
}

shinyApp(ui, server)
```

  

## Extending shinyfilters

You can extend `shinyfilters` by adding or overwriting methods to the
following:

- [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md),
  [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md)
- [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
- [`get_filter_logical()`](https://joshwlivingston.github.io/shinyfilters/reference/get_filter_logical.md)

See
[`vignette("customizing-shinyfilters")`](https://joshwlivingston.github.io/shinyfilters/articles/customizing-shinyfilters.md)
for more.
