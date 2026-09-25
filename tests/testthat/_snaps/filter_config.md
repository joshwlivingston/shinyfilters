# as_filters(): `ns` must be result of shiny::NS()

    Code
      as_filters(data.frame(a = letters), ns = function(x) x)
    Condition
      Error in `as_filters()`:
      ! `ns` must be the result of calling `shiny::NS()`.

# as_filters() and with_filter() errors

    Code
      as_filters(1:3)
    Condition
      Error in `as_filters()`:
      ! `data` must be a data frame, not an integer vector.
    Code
      as_filters(df_config, TRUE)
    Condition
      Error in `as_filters()`:
      ! All elements of `...` must be named.
    Code
      with_filter(df_config, x = "radio")
    Condition
      Error in `with_filter()`:
      ! `config` must be created by `as_filters()`, not a data frame.
    Code
      with_filter(cfg)
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments or only named arguments.
      i Select columns: `with_filter(config, c(a, b), "radio")`.
      i Name columns: `with_filter(config, a = "radio", b = "slider")`.
    Code
      with_filter(cfg, x)
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments or only named arguments.
      i Select columns: `with_filter(config, c(a, b), "radio")`.
      i Name columns: `with_filter(config, a = "radio", b = "slider")`.
    Code
      with_filter(cfg, x, "radio", "slider")
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments or only named arguments.
      i Select columns: `with_filter(config, c(a, b), "radio")`.
      i Name columns: `with_filter(config, a = "radio", b = "slider")`.
    Code
      with_filter(cfg, x = "radio", "letters")
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments or only named arguments.
      i Select columns: `with_filter(config, c(a, b), "radio")`.
      i Name columns: `with_filter(config, a = "radio", b = "slider")`.
    Code
      with_filter(cfg, nope = "radio")
    Condition
      Error in `with_filter()`:
      ! Can't find column nope.
    Code
      with_filter(cfg, nope, "radio")
    Condition
      Error in `with_filter()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_filter(cfg, where(is.logical), "radio")
    Condition
      Error in `with_filter()`:
      ! `where(is.logical)` doesn't select any columns.
    Code
      with_filter(cfg, x = "radioo")
    Condition
      Error in `with_filter()`:
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".
    Code
      with_filter(cfg, x, c("radio", "slider"))
    Condition
      Error in `with_filter()`:
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
      x Got "radio" and "slider".
    Code
      with_filter(cfg, x, radio)
    Condition
      Error in `with_filter()`:
      ! Can't evaluate the input `radio`.
      i Keywords are strings, e.g. `"radio"`.
      Caused by error:
      ! object 'radio' not found
    Code
      with_filter(cfg, x = 1)
    Condition
      Error in `with_filter()`:
      ! An input must be a keyword or a function, not a number.
    Code
      filterInput(with_filter(cfg, factors = "slider"))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column factors.
      Caused by error:
      ! "slider" isn't available for <factor> columns.
      i Use "radio" or "selectize" instead.
    Code
      filterInput(with_filter(cfg, a_very_very_long_name = "range"))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column a_very_very_long_name.
      Caused by error:
      ! "range" isn't available for <numeric> columns.
      i Use "radio", "selectize", or "slider" instead.
    Code
      filterInput(with_filter(as_filters(data.frame(a = NA_integer_)), a = "radio"))
    Condition
      Error in `filterInput()`:
      ! Column a must have at least one non-missing value.
    Code
      filterInput(as_filters(data.frame(a = NA_integer_)))
    Condition
      Error in `filterInput()`:
      ! Column a must have at least one non-missing value.

# print() shows each column's input

    Code
      print(as_filters(df_config))
    Output
      -- <FilterConfig> - 3 x 4 ------------------------------------------------------
      
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
    Code
      print(with_filter(as_filters(df_config, slider = TRUE, ns = shiny::NS("m")), x = "radio",
      letters = my_select))
    Output
      -- <FilterConfig> - 3 x 4 * ns "m" ---------------------------------------------
      Defaults  slider = TRUE
      
        letters                <chr>  my_select     *
        factors                <fct>  selectInput
        x                      <int>  radioButtons  *
        a_very_very_long_name  <dbl>  sliderInput
      
      * set by with_filter()
    Code
      print(with_filter(as_filters(df_config), factors = "slider"))
    Output
      -- <FilterConfig> - 3 x 4 ------------------------------------------------------
      
        letters                <chr>  selectInput
        factors                <fct>  x "slider" isn't available for <factor> columns.  *
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      * set by with_filter()

# print() resolves custom methods

    Code
      print(as_filters(df))
    Output
      -- <FilterConfig> - 2 x 2 ------------------------------------------------------
      
        radio   <chr>  radioButtons
        custom  <chr>  <custom>

