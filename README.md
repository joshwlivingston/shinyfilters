
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyfilters <img src="man/figures/logo.svg" align="right" height="139" alt="" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/shinyfilters)](https://CRAN.R-project.org/package=shinyfilters)
[![Ask
DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/joshwlivingston/shinyfilters)
[![Codecov test
coverage](https://codecov.io/gh/joshwlivingston/shinyfilters/graph/badge.svg)](https://app.codecov.io/gh/joshwlivingston/shinyfilters)
[![tinyverse-status](https://tinyverse.netlify.app/badge/shinyfilters)](https://CRAN.R-project.org/package=shinyfilters)
[![r-universe
status](https://joshwlivingston.r-universe.dev/shinyfilters/badges/version)](https://joshwlivingston.r-universe.dev/shinyfilters)
[![R-CMD-check](https://github.com/joshwlivingston/shinyfilters/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/joshwlivingston/shinyfilters/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

*shinyfilters* makes it easy to create interdependent filters directly
from data.frames.

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

## Quickstart

Build interdependent filters in 3 steps:

1.  Create the filters from a data.frame:

``` r
library(shinyfilters)

filters <- shinyfilters(nyc_flights)
filters
#> <shinyfilters> • 7 filters
#> 
#> Filters
#>   date       <date>  dateRangeInput
#>   carrier    <chr>   selectizeInput
#>   origin     <fct>   selectizeInput
#>   dest       <chr>   selectizeInput
#>   dep_delay  <dbl>   sliderInput
#>   distance   <dbl>   sliderInput
#>   delayed    <lgl>   selectizeInput
```

2.  Place the filters in your ui:

``` r
# pak::pak(c("bslib", "DT"))
library(bslib)
library(DT)
library(shiny)

ui <- page_sidebar(
    sidebar = sidebar(
        filters
    ),
    DTOutput("data")
)
```

3.  Place the filters in your server:

``` r
server <- function(input, output, session) {
    sidebar <- shinyfilters_server(filters)
    output$data <- renderDT(datatable(sidebar$filtered))
}
```

Then run your app:

``` r
shinyApp(ui, server)
```

## Going further

See `vignette("shinyfilters")` for the full tour.
