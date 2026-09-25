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
      as_filters(df_config[0, ])
    Condition
      Error in `as_filters()`:
      ! `data` must have at least one row.
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
      -- <shinyfilters> - 4 filters --------------------------------------------------
      
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
    Code
      print(cfg)
    Output
      -- <shinyfilters> - 4 filters * namespace "m" ----------------------------------
      Defaults  slider = TRUE
      
        letters                <chr>  my_select     *
        factors                <fct>  selectInput
        x                      <int>  radioButtons  *
        a_very_very_long_name  <dbl>  sliderInput
      
      * set by with_filter()
    Code
      print(with_filter(as_filters(df_config), factors = "slider"))
    Output
      -- <shinyfilters> - 4 filters --------------------------------------------------
      
        letters                <chr>  selectInput
        factors                <fct>  x "slider" isn't available for <factor> columns.  *
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      * set by with_filter()
    Code
      print(as_filters(df_config, args_unique = "bad"))
    Output
      -- <shinyfilters> - 4 filters --------------------------------------------------
      Defaults  args_unique = "bad"
      
        letters                <chr>  x `args_unique` must be a list, not a string.
        factors                <fct>  x `args_unique` must be a list, not a string.
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
    Code
      print(as_filters(data.frame(x = "a")))
    Output
      -- <shinyfilters> - 1 filter ---------------------------------------------------
      
        x  <chr>  selectInput

# print() resolves custom methods

    Code
      print(as_filters(df))
    Output
      -- <shinyfilters> - 3 filters --------------------------------------------------
      
        radio    <chr>  radioButtons
        custom   <chr>  <custom>
        wrapped  <chr>  radioButtons

# `$` and `[[` error on unknown columns

    Code
      cfg$nope
    Condition
      Error in `cfg$nope`:
      ! Can't find column nope.
    Code
      cfg[["nope"]]
    Condition
      Error in `cfg[["nope"]]`:
      ! Can't find column nope.
    Code
      cfg[[9]]
    Condition
      Error in `cfg[[9]]`:
      ! Can't find column 9.
    Code
      cfg[[c("x", "nope")]]
    Condition
      Error in `cfg[[c("x", "nope")]]`:
      ! Select a single column, not 2 values.
    Code
      cfg[[1:2]]
    Condition
      Error in `cfg[[1:2]]`:
      ! Select a single column, not 2 values.

# `[` returns a config with the selected columns

    Code
      print(cfg[c("letters", "x")])
    Output
      -- <shinyfilters> - 2 filters --------------------------------------------------
      Defaults  slider = TRUE
      
        letters  <chr>  selectInput
        x        <int>  radioButtons  *
      
      * set by with_filter()

# `[` errors on unknown columns

    Code
      cfg["nope"]
    Condition
      Error in `cfg["nope"]`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      cfg[9]
    Condition
      Error in `cfg[9]`:
      ! Can't select columns past the end.
      i Location 9 doesn't exist.
      i There are only 4 columns.
    Code
      cfg[TRUE]
    Condition
      Error in `cfg[TRUE]`:
      ! Can't select columns.
      x Subscript must be numeric or character, not `TRUE`.

