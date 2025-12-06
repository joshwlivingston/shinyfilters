# shinyfilters

Intro text

# Installation

You can install the development version from Github:

``` r
pak("joshwlivingston/shinyfilters")
```

# Usage

## Vectors

``` r
filterInput(
    x = letters,
    id = "letter",
    label = "Pick a letter:"
)
```

## Data.frames

``` r
filterInput(x = iris)
```

## Shiny modules

``` r
df_shared <- data.frame(
    x = letters,
    y = sample(c("red", "green", "blue"), 26, replace = TRUE),
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
```
