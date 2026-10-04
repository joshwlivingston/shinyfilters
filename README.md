
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyfilters

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

*shinyfilters* makes it easy to create Shiny inputs directly from
data.frames.

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

Build interdependent filters in 3 steps:

1.  Create the filters from a data.frame:

``` r
library(shinyfilters)

filters <- shinyfilters(nyc_flights)
filters
```

<picture>
<source media="(prefers-color-scheme: dark)" srcset="man/figures/README-/filters-dark.svg">
<img src="man/figures/README-/filters.svg" alt="" width="100%" />
</picture> <br>

2.  Place the filters in your ui

``` r
# pak::pak("bslib")
library(bslib)

ui <- page_sidebar(
    sidebar = sidebar(
        filters
    )
)
```

<br>

3.  Place the filters in your server

``` r
server <- function(...) {
    shinyfilters_server(filters)
}
```

<br>

Your app now has interdependent filters!

``` r
library(shiny)
shinyApp(ui, server)
```

<br>

## Customizing filters

`{shinyfilters}` is fully customizable. See
[`vignette("shinyfilters")`](https://joshwlivingston.github.io/shinyfilters/shinyfilters.html)
for a full tour.

<br>
