#' @keywords internal
"_PACKAGE"

#' 'shinyfilters' Objects
#'
#' A `shinyfilters` object holds a data.frame and all of the data's filters. To
#' create one, call [shinyfilters()]. To modify one, use [with_filters()],
#' [with_defaults()], or [with_ns()].
#'
#' # Usage
#'
#' The object behaves much like the data.frame that defines it.
#' ```
#' filters <- shinyfilters(nyc_flights)
#' ```
#'
#' ## Names
#'
#' `names(filters)` provides the names of the data.frame.
#'
#' ## Shape
#'
#' `dim(filters)`, `nrow(filters)`, and `ncol(filters)` describe the dimensions.
#'
#' ## Data
#'
#' `as.data.frame(filters)` returns the data.
#'
#' ## Subsetting
#'
#' `filters$col` creates the input for one filter.
#'
#' `filters[[cols]]` creates the inputs for all filters in `cols`.
#'
#' `filters[cols]` subsets a `shinyfilters` object, returning only filters
#'   matching `cols`.
#'
#' \pkg{shinyfilters} supports <[`tidy-select`][tidyselect::language]> in both
#' `[` and `[[`
#'
#' ## dplyr
#'
#' Some `dplyr` verbs are also supported:
#'
#' | **dplyr**   | **shinyfilters**          |
#' |-------------|---------------------------|
#' | `mutate`    | `with_filters`            |
#' | `select`    | `[`                       |
#' | `transmute` | `with_filters` + `select` |
#' | `pull`      | `[[`                      |
#'
#' ## In a \pkg{shiny} app
#'
#' A `shinyfilters` object can be placed directly inside a ui:
#'
#' ```
#' library(bslib)
#' ui <- page_sidebar(sidebar = filters)
#' ```
#' <br>
#'
#' To enable interdependent filters, call [shinyfilters_server] in the server:
#' ```
#' server <- function(...) {
#'   shinyfilters_server(filters)
#' }
#' ```
#' <br>
#'
#' ### Creating filters
#'
#' Sometimes, you will have to create the filters as you place them in the app.
#' The following functions create filters:
#'
#' * `[[`
#' * `$`
#' * [filterInput]
#' * [dplyr::pull]
#'
#' ```
#' ui <- function(request) {
#'   page_sidebar(sidebar = filters[[everything()]])
#' }
#' ```
#' <br>
#'
#' Currently, it is known that you must create the filters when:
#'
#' 1. Bookmarking is enabled
#' 2. When placing a filter inside [bslib::accordion].
#'
#' In these instances, shinyfilters will intercept and throw an informative
#' error.
#' ```
#' accordion(shinyfilters(nyc_flights))
#' #> Error:
#' #> ! <shinyfilters> objects cannot be used in some shiny functions.
#' #> ℹ Use `[[`, `$`, `filterInput()`, or `dplyr::pull()` to render the filters
#' #>   directly.
#' ```
#' <br>
#'
#' # Printing
#'
#' Printing shows the input each column receives:
#'
#' ```
#' shinyfilters(nyc_flights)
#' #> <shinyfilters> • 7 filters
#' #>
#' #> Filters
#' #>   date       <date>  dateRangeInput
#' #>   carrier    <chr>   selectizeInput
#' #>   origin     <fct>   selectizeInput
#' #>   dest       <chr>   selectizeInput
#' #>   dep_delay  <dbl>   sliderInput
#' #>   distance   <dbl>   sliderInput
#' #>   delayed    <lgl>   selectizeInput
#' ```
#' <br>
#'
#' Any modifications will be displayed:
#'
#' ```
#' shinyfilters(nyc_flights, range = FALSE) |>
#'   with_filters(date = "date") |>
#'   with_ns("sidebar-mod")
#' #> <shinyfilters> • 7 filters • namespace "sidebar-mod"
#' #>
#' #> Filters
#' #>   ●  date       <date>  dateInput
#' #>      carrier    <chr>   selectizeInput
#' #>      origin     <fct>   selectizeInput
#' #>      dest       <chr>   selectizeInput
#' #>      dep_delay  <dbl>   sliderInput
#' #>      distance   <dbl>   sliderInput
#' #>      delayed    <lgl>   selectizeInput
#' #>
#' #> Default Overrides
#' #>   range = FALSE
#' #>
#' #> ● Filter set by `with_filters()`
#' ```
#'
#' @name shinyfilters-class
NULL

## usethis namespace: start
#' @importFrom cli ansi_align
#' @importFrom cli ansi_nchar
#' @importFrom cli ansi_strip
#' @importFrom cli ansi_strtrim
#' @importFrom cli cat_line
#' @importFrom cli cli_abort
#' @importFrom cli cli_warn
#' @importFrom cli col_blue
#' @importFrom cli col_cyan
#' @importFrom cli col_green
#' @importFrom cli col_grey
#' @importFrom cli col_magenta
#' @importFrom cli col_red
#' @importFrom cli col_yellow
#' @importFrom cli console_width
#' @importFrom cli format_inline
#' @importFrom cli is_utf8_output
#' @importFrom cli qty
#' @importFrom cli symbol
#' @importFrom htmltools tagList
#' @importFrom methods formalArgs
#' @importFrom methods functionBody
#' @importFrom rlang !!
#' @importFrom rlang !!!
#' @importFrom rlang as_label
#' @importFrom rlang call_args
#' @importFrom rlang call_match
#' @importFrom rlang call_modify
#' @importFrom rlang call2
#' @importFrom rlang caller_arg
#' @importFrom rlang caller_env
#' @importFrom rlang current_call
#' @importFrom rlang current_env
#' @importFrom rlang enquo
#' @importFrom rlang enquos
#' @importFrom rlang eval_tidy
#' @importFrom rlang f_lhs
#' @importFrom rlang f_rhs
#' @importFrom rlang inject
#' @importFrom rlang is_call
#' @importFrom rlang is_formula
#' @importFrom rlang is_missing
#' @importFrom rlang is_quosure
#' @importFrom rlang is_string
#' @importFrom rlang is_symbol
#' @importFrom rlang is_vector
#' @importFrom rlang local_error_call
#' @importFrom rlang maybe_missing
#' @importFrom rlang missing_arg
#' @importFrom rlang names2
#' @importFrom rlang new_quosure
#' @importFrom rlang quo
#' @importFrom rlang quo_get_env
#' @importFrom rlang quo_get_expr
#' @importFrom rlang try_fetch
#' @importFrom S7 class_any
#' @importFrom S7 class_character
#' @importFrom S7 class_data.frame
#' @importFrom S7 class_Date
#' @importFrom S7 class_factor
#' @importFrom S7 class_function
#' @importFrom S7 class_list
#' @importFrom S7 class_logical
#' @importFrom S7 class_numeric
#' @importFrom S7 method
#' @importFrom S7 method<-
#' @importFrom S7 methods_register
#' @importFrom S7 new_class
#' @importFrom S7 new_generic
#' @importFrom S7 new_object
#' @importFrom S7 new_property
#' @importFrom S7 new_S3_class
#' @importFrom S7 S7_class
#' @importFrom S7 S7_dispatch
#' @importFrom S7 S7_inherits
#' @importFrom S7 S7_object
#' @importFrom shiny getDefaultReactiveDomain
#' @importFrom shiny getShinyOption
#' @importFrom shiny NS
#' @importFrom shiny observe
#' @importFrom shiny reactiveValues
#' @importFrom tidyselect eval_select
#' @importFrom tidyselect vars_pull
#' @importFrom utils getS3method
#' @importFrom utils methods
#' @importFrom utils modifyList
#' @rawNamespace if (getRversion() < "4.3.0") importFrom(S7, "@")
## usethis namespace: end
NULL
