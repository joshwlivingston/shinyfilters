# with_args() leaves another function named across() alone

    Code
      with_args(cfg, across(x, step := 2))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `across(x, step := 2)` isn't one of these.
      x `across()` is another function here. To select columns, use `dplyr::across()` or a formula.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.

# print() shows what each way of writing with_args() sets

    Code
      with_args(cfg, x ~ value := range(.x))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
        a_very_very_long_name  <dbl>  sliderInput
    Code
      with_args(cfg, x ~ list(value := range(.x), step = 2))
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
      with_args(cfg, across(where(is.numeric), value := range(.x)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
        a_very_very_long_name  <dbl>  sliderInput
                                        value = range(.x, na.rm = TRUE)
    Code
      with_args(cfg, across(where(is.numeric), list(value := range(.x), step = 2)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
                                        step  = 2
        a_very_very_long_name  <dbl>  sliderInput
                                        value = range(.x, na.rm = TRUE)
                                        step  = 2
    Code
      with_args(cfg, x ~ value := range(.x), letters ~ label := "Letters")
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
      with_filters(cfg, x ~ step := 2)
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
      with_filters(cfg, x ~ list(step := 2, width = "50%"))
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
      with_filters(cfg, across(where(is.numeric), step := 2))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        #  x                      <int>  numericInput
                                           step = 2
        #  a_very_very_long_name  <dbl>  numericInput
                                           step = 2
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
    Code
      with_filters(cfg, x = "slider" ~ value := range(.x))
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
      with_filters(cfg, x = "slider" ~ list(value := range(.x), step = 2))
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
      with_filters(cfg, x = shiny::sliderInput(value := range(.x), step = 2))
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
      with_filters(cfg, x = shiny::sliderInput ~ value := range(.x))
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
      with_filters(cfg, where(is.numeric) ~ "slider" ~ value := range(.x))
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
      with_filters(cfg, where(is.numeric) ~ "slider" ~ list(value := range(.x), step = 2))
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
      with_filters(cfg, where(is.numeric) ~ shiny::sliderInput(value := range(.x)))
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
      with_filters(cfg, across(where(is.numeric), "slider" ~ value := range(.x)))
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
      with_filters(cfg, across(where(is.numeric), shiny::sliderInput(value := range(
        .x))))
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
      with_filters(cfg, letters = shiny::checkboxGroupInput(inline := TRUE,
      .update_fn := shiny::updateCheckboxGroupInput))
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
    Code
      with_filters(cfg, x := "slider")
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
      
      # Filter set by default argument
      * Filter set by `with_filters()`

# print() shows the arguments of inputs with_filters() chose

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  radioButtons
                                           inline = TRUE
                                           label  = "Letters"
        *  factors                <fct>  selectizeInput
        ~  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
        *  a_very_very_long_name  <dbl>  sliderInput
                                           value = range(.x, na.rm = TRUE)
      
      Default Overrides
        slider = FALSE
      
      * Filter set by `with_filters()`
      ~ Filter replaced by `with_filters()`

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
      filterInput(with_args(cfg, x ~ value := nope(.x)))
    Condition
      Error in `filterInput()`:
      ! Can't evaluate `value = nope(.x)` for column x.
      Caused by error in `nope()`:
      ! could not find function "nope"
    Code
      filterInput(with_args(cfg, x ~ valeu := 1))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column x.
      Caused by error:
      ! unused argument (valeu = 1)
    Code
      filterInput(with_args(cfg, letters ~ valeu := 1))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column letters.
      Caused by error in `selectInput()`:
      ! unused argument (valeu = 1)
    Code
      filterInput(with_filters(cfg, letters = "slider" ~ value := 1))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column letters.
      Caused by error:
      ! "slider" isn't available for <character> columns.
      i Use "area", "radio", "select", "selectize", or "textbox" instead.
    Code
      with_filters(cfg, x = "sldier" ~ step := 2)
    Condition
      Error in `with_filters()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "sldier".

# with_filters() errors with `:=`

    Code
      with_filters(cfg, value := 1)
    Condition
      Error in `with_filters()`:
      ! Can't find column value.
      x `value := 1` needs an existing column on its left.
      i To set an argument, select columns: `with_filters(filters, cols ~ value := 1)`.
      i To add a column, name it with `=`: `with_filters(filters, value = <expression>)`.
    Code
      with_filters(cfg, nope = shiny::sliderInput(value := 1))
    Condition
      Error in `with_filters()`:
      ! Can't find column nope.
      x `shiny::sliderInput(value := 1)` chooses the input for an existing column.
      i To add a column, compute it from the others: `with_filters(filters, nope = <expression>)`.
    Code
      with_filters(cfg, nope = step := 2)
    Condition
      Error in `with_filters()`:
      ! Can't find column nope.
      x `step := 2` sets arguments for an existing column's input.
      i To add a column, compute it from the others: `with_filters(filters, nope = <expression>)`.
    Code
      with_filters(cfg, x = shiny::sliderInput(value := 1, 5))
    Condition
      Error in `with_filters()`:
      ! All arguments must be named.
      x `5` isn't.
    Code
      with_filters(cfg, x ~ inputId := "y")
    Condition
      Error in `with_filters()`:
      ! Can't set `inputId` in `with_filters()`.
      i An input's id is always its column's name.
    Code
      with_filters(cfg, x = shiny::sliderInput(.update_fn := "updateSliderInput"))
    Condition
      Error in `with_filters()`:
      ! `.update_fn` must be a function, not a string.
    Code
      with_filters(cfg, x ~ max := nope * 2)
    Condition
      Error in `with_filters()`:
      ! Can't evaluate `max := nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      with_filters(cfg, x = "slider" ~ "radio")
    Condition
      Error in `with_filters()`:
      ! Can't read `"slider" ~ "radio"`.
      i An input is followed by its arguments: `input ~ arg := value`.
      i Arguments are written `arg := value`, or `list(arg := value, ...)` for several.

# with_args() errors

    Code
      with_args(df_config, x ~ step := 2)
    Condition
      Error in `with_args()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_args(cfg)
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x = list(step = 2))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x = list(step = 2)` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, value := 1)
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `value := 1` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ "slider")
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x ~ "slider"` isn't one of these.
      i To choose an input, use `with_filters()`.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ shiny::sliderInput(value := 1))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x ~ shiny::sliderInput(value := 1)` isn't one of these.
      i To choose an input, use `with_filters()`.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ "slider" ~ value := 1)
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x ~ "slider" ~ value := 1` isn't one of these.
      i To choose an input, use `with_filters()`.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, across(x, "slider" ~ value := 1))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `across(x, "slider" ~ value := 1)` isn't one of these.
      i To choose an input, use `with_filters()`.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ list())
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x ~ list()` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ list(step := 2, 5))
    Condition
      Error in `with_args()`:
      ! All arguments must be named.
      x `5` isn't.
    Code
      with_args(cfg, x ~ list(step := 2, step = 4))
    Condition
      Error in `with_args()`:
      ! Argument `step` is set more than once.
    Code
      with_args(cfg, x ~ inputId := "y")
    Condition
      Error in `with_args()`:
      ! Can't set `inputId` in `with_args()`.
      i An input's id is always its column's name.
    Code
      with_args(cfg, nope ~ step := 2)
    Condition
      Error in `with_args()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_args(cfg, where(is.logical) ~ step := 2)
    Condition
      Error in `with_args()`:
      ! `where(is.logical)` doesn't select any columns.
    Code
      with_args(cfg, x ~ max := nope * 2)
    Condition
      Error in `with_args()`:
      ! Can't evaluate `max := nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      with_args(cfg, across(x))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `across(x)` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, across(x, step := 2, min := 0))
    Condition
      Error in `with_args()`:
      ! `across()` takes only `.cols` and `.fns` here.
      x Got 1 extra argument.
      i Put several arguments in `list()`.
    Code
      with_args(cfg, across(x, step := 2, .names = "a"))
    Condition
      Error in `with_args()`:
      ! `across()` doesn't support `.names` here.
      i It selects columns; it doesn't rename them.
    Code
      with_args(cfg, x = across(x, step := 2))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x = across(x, step := 2)` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.

