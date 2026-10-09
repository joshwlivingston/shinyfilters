# print() shows what each way of writing with_args() sets

    Code
      with_args(cfg, x ~ list(value = range(.x)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
        a_very_very_long_name  <dbl>  sliderInput
    Code
      with_args(cfg, x ~ list(value = range(.x), step = 2))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
                                        step  = 2
        a_very_very_long_name  <dbl>  sliderInput
    Code
      with_args(cfg, x ~ list(value = range(.x)), letters ~ list(label = "Letters"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
                                        label = "Letters"
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
        a_very_very_long_name  <dbl>  sliderInput

# print() shows what each way of writing with_filters() sets

    Code
      with_filters(cfg, x ~ list(step = 2))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        #  x                      <int>  numericInput
                                           step = 2
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
    Code
      with_filters(cfg, x ~ list(step = 2, width = "50%"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        #  x                      <int>  numericInput
                                           step  = 2
                                           width = "50%"
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
    Code
      with_filters(cfg, x = "slider" ~ list(value = range(.x)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
      * Filter set by `with_filters()`
    Code
      with_filters(cfg, x = "slider" ~ list(value = range(.x), step = 2))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
                                           step  = 2
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
      * Filter set by `with_filters()`
    Code
      with_filters(cfg, x = shiny::sliderInput ~ list(value = range(.x)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
      * Filter set by `with_filters()`
    Code
      with_filters(cfg, where(is.numeric) ~ "slider" ~ list(value = range(.x)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
        *  a_very_very_long_name  <dbl>  sliderInput
                                           value = range(.x, na.rm = TRUE)
      
      Default Overrides
        slider = FALSE
      
      * Filter set by `with_filters()`
    Code
      with_filters(cfg, where(is.numeric) ~ "slider" ~ list(value = range(.x), step = 2))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
                                           step  = 2
        *  a_very_very_long_name  <dbl>  sliderInput
                                           value = range(.x, na.rm = TRUE)
                                           step  = 2
      
      Default Overrides
        slider = FALSE
      
      * Filter set by `with_filters()`
    Code
      with_filters(cfg, letters = shiny::checkboxGroupInput ~ list(inline = TRUE,
        .update_fn = shiny::updateCheckboxGroupInput))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  checkboxGroupInput {shiny}
                                           inline     = TRUE
                                           .update_fn = updateCheckboxGroupInput {shiny}
           factors                <fct>  selectizeInput
        #  x                      <int>  numericInput
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
      * Filter set by `with_filters()`

# print() shortens a long argument

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
                                        label = "A label that runs past thirt...
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput

# print() shows `.update_fn`

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  checkboxGroupInput {shiny}
                                           inline     = TRUE
                                           .update_fn = updateCheckboxGroupInput {shiny}
        *  factors                <fct>  checkbox
                                           .update_fn = update_checkbox
        *  x                      <int>  div_input
                                           .update_fn = <custom>
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `with_filters()`

# an argument an input can't take errors when the input is created

    Code
      filterInput(with_args(cfg, x ~ list(value = nope(.x))))
    Condition
      Error in `filterInput()`:
      ! Can't evaluate `value = nope(.x)` for column x.
      Caused by error in `nope()`:
      ! could not find function "nope"
    Code
      filterInput(with_args(cfg, x ~ list(valeu = 1)))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column x.
      Caused by error:
      ! unused argument (valeu = 1)
    Code
      filterInput(with_args(cfg, letters ~ list(valeu = 1)))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column letters.
      Caused by error in `selectInput()`:
      ! unused argument (valeu = 1)
    Code
      filterInput(with_filters(cfg, letters = "slider" ~ list(value = 1)))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column letters.
      Caused by error:
      ! "slider" isn't available for <character> columns.
      i Use "area", "radio", "select", "selectize", or "textbox" instead.
    Code
      with_filters(cfg, x = "sldier" ~ list(step = 2))
    Condition
      Error in `with_filters()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "sldier".

# with_filters() errors for an input's arguments

    Code
      with_filters(cfg, nope = "slider" ~ list(value = 1))
    Condition
      Error in `with_filters()`:
      ! Can't find column nope.
      x `"slider" ~ list(value = 1)` chooses the input for an existing column.
      i To add a column, compute it from the others: `with_filters(filters, nope = <expression>)`.
    Code
      with_filters(cfg, x = "slider" ~ list(value = 1, 5))
    Condition
      Error in `with_filters()`:
      ! All arguments must be named.
      x `5` isn't.
    Code
      with_filters(cfg, x ~ list(inputId = "y"))
    Condition
      Error in `with_filters()`:
      ! Can't set `inputId` in `with_filters()`.
      i An input's id is always its column's name.
    Code
      with_filters(cfg, x = "slider" ~ list(.update_fn = "updateSliderInput"))
    Condition
      Error in `with_filters()`:
      ! `.update_fn` must be a function, not a string.
    Code
      with_filters(cfg, x ~ list(max = nope * 2))
    Condition
      Error in `with_filters()`:
      ! Can't evaluate `max = nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      with_filters(cfg, x = "slider" ~ "radio")
    Condition
      Error in `with_filters()`:
      ! Can't read `"slider" ~ "radio"`.
      i An input is followed by its arguments: `input ~ list(arg = value, ...)`.
    Code
      with_filters(cfg, x, letters ~ "radio")
    Condition
      Error in `with_filters()`:
      ! Can't read `letters ~ "radio"`.
      i An input is followed by its arguments: `input ~ list(arg = value, ...)`.

# with_args() errors

    Code
      with_args(df_config, x ~ list(step = 2))
    Condition
      Error in `with_args()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_args(cfg)
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ list(arg = value)` formulas.
      i One column: `with_args(filters, x ~ list(value = range(.x), step = 5))`.
      i Several columns: `with_args(filters, c(x, y) ~ list(value = range(.x))))`.
    Code
      with_args(cfg, x = list(step = 2))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ list(arg = value)` formulas.
      x `x = list(step = 2)` isn't one of these.
      i One column: `with_args(filters, x ~ list(value = range(.x), step = 5))`.
      i Several columns: `with_args(filters, c(x, y) ~ list(value = range(.x))))`.
    Code
      with_args(cfg, x ~ "slider")
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ list(arg = value)` formulas.
      x `x ~ "slider"` isn't one of these.
      i One column: `with_args(filters, x ~ list(value = range(.x), step = 5))`.
      i Several columns: `with_args(filters, c(x, y) ~ list(value = range(.x))))`.
    Code
      with_args(cfg, x ~ "slider" ~ list(value = 1))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ list(arg = value)` formulas.
      x `x ~ "slider" ~ list(value = 1)` isn't one of these.
      i One column: `with_args(filters, x ~ list(value = range(.x), step = 5))`.
      i Several columns: `with_args(filters, c(x, y) ~ list(value = range(.x))))`.
    Code
      with_args(cfg, x ~ list())
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ list(arg = value)` formulas.
      x `x ~ list()` isn't one of these.
      i One column: `with_args(filters, x ~ list(value = range(.x), step = 5))`.
      i Several columns: `with_args(filters, c(x, y) ~ list(value = range(.x))))`.
    Code
      with_args(cfg, x ~ list(step = 2, 5))
    Condition
      Error in `with_args()`:
      ! All arguments must be named.
      x `5` isn't.
    Code
      with_args(cfg, x ~ list(step = 2, step = 4))
    Condition
      Error in `with_args()`:
      ! Argument `step` is set more than once.
    Code
      with_args(cfg, x ~ list(inputId = "y"))
    Condition
      Error in `with_args()`:
      ! Can't set `inputId` in `with_args()`.
      i An input's id is always its column's name.
    Code
      with_args(cfg, nope ~ list(step = 2))
    Condition
      Error in `with_args()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_args(cfg, x ~ list(max = nope * 2))
    Condition
      Error in `with_args()`:
      ! Can't evaluate `max = nope * 2`.
      Caused by error:
      ! object 'nope' not found

# with_args() errors (tidyselect)

    Code
      with_args(cfg, tidyselect::where(is.logical) ~ list(step = 2))
    Condition
      Error in `with_args()`:
      ! `tidyselect::where(is.logical)` doesn't select any columns.

