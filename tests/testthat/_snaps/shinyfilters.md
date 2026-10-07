# shinyfilters(): `ns` must be result of shiny::NS()

    Code
      shinyfilters(data.frame(stringsAsFactors = FALSE, a = letters), ns = function(x)
        x)
    Condition
      Error in `shinyfilters()`:
      ! `ns` must not be a custom function.

# a shiny input is matched as it is now, not as it was when built

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput

# `radio = TRUE` turns off the `selectize` default

    Code
      filterInput(shinyfilters(df_config, radio = TRUE, selectize = TRUE))
    Condition
      Error:
      ! `radio` and `selectize` can't both be `TRUE`.

# print() marks columns added by with_filters()

    Code
      print(cfg)
    Output
      <shinyfilters> * 5 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
        +  y                      <dbl>  sliderInput
      
      + Filter added by `with_filters()`
    Code
      print(cfg["y"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        +  y  <dbl>  sliderInput
      
      + Filter added by `with_filters()`
    Code
      print(cfg["x"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        x  <int>  sliderInput

# print() marks columns replaced by with_filters()

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        ~  x                      <dbl>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      ~ Filter replaced by `with_filters()`
    Code
      print(cfg["x"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        ~  x  <dbl>  sliderInput
      
      ~ Filter replaced by `with_filters()`
    Code
      print(cfg["letters"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        letters  <chr>  selectizeInput

# print() shows one marker per row

    Code
      print(cfg)
    Output
      <shinyfilters> * 6 filters
      
      Filters
        #  letters                <chr>  selectInput
        #  factors                <fct>  selectInput
        ~  x                      <dbl>  radioButtons
        ~  a_very_very_long_name  <dbl>  numericInput
        +  y                      <dbl>  sliderInput
        +  z                      <chr>  selectInput
      
      Default Overrides
        selectize = FALSE
      
      # Filter set by default argument
      + Filter added by `with_filters()`
      ~ Filter replaced by `with_filters()`

# print() handles long names

    Code
      print(filters)
    Output
      <shinyfilters> * 8 filters * namespace "sidebar-mod"
      
      Filters
           date                       <date>  dateRangeInput
        *  origin                     <fct>   radioButtons
           dest                       <chr>   selectizeInput
           dep_delay                  <dbl>   sliderInput
                                                value = urgfjkbhqaewpqaedoufikljshygbqaeoli...
        *  distance                   <dbl>   sliderInput
           delayed                    <lgl>   selectizeInput
           awpirgbeqaprkjgbaepirg...  <chr>   selectizeInput
        +  on_time                    <lgl>   selectizeInput
      
      * Filter set by `with_filters()`
      + Filter added by `with_filters()`

# errors from a function override name the column

    Code
      filterInput(cfg)
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column x.
      Caused by error:
      ! Not today.
    Code
      cfg$x
    Condition
      Error in `cfg$x`:
      ! Can't create an input for column x.
      Caused by error:
      ! Not today.

# shinyfilters() and with_filters() errors

    Code
      shinyfilters(1:3)
    Condition
      Error in `shinyfilters()`:
      ! `.data` must be a <data.frame>, not an integer vector.
    Code
      shinyfilters(df_config[0, ])
    Condition
      Error in `shinyfilters()`:
      ! `.data` must have at least one row.
    Code
      shinyfilters(df_config, TRUE)
    Condition
      Error in `shinyfilters()`:
      ! All elements of `...` must be named.
    Code
      with_filters(df_config, x = "radio")
    Condition
      Error in `with_filters()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_filters(cfg)
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filters(cfg, x)
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filters(cfg, x, "radio", "slider")
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filters(cfg, x = "radio", "letters")
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filters(cfg, nope = "radio")
    Condition
      Error in `with_filters()`:
      ! Can't find column nope.
      x `"radio"` chooses the input for an existing column.
      i To add a column, compute it from the others: `with_filters(filters, nope = <expression>)`.
    Code
      with_filters(cfg, nope, "radio")
    Condition
      Error in `with_filters()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_filters(cfg, where(is.logical), "radio")
    Condition
      Error in `with_filters()`:
      ! `where(is.logical)` doesn't select any columns.
    Code
      with_filters(cfg, x = "radioo")
    Condition
      Error in `with_filters()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".
    Code
      with_filters(cfg, nope ~ "radio")
    Condition
      Error in `with_filters()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_filters(cfg, where(is.logical) ~ "radio")
    Condition
      Error in `with_filters()`:
      ! `where(is.logical)` doesn't select any columns.
    Code
      with_filters(cfg, x ~ "radioo")
    Condition
      Error in `with_filters()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".
    Code
      with_filters(cfg, ~"radio")
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filters(cfg, x, c("radio", "slider"))
    Condition
      Error in `with_filters()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "radio" and "slider".
    Code
      with_filters(cfg, x, radio)
    Condition
      Error in `with_filters()`:
      ! Can't evaluate the input `radio`.
      i Keywords are strings, e.g. `"radio"`.
      Caused by error:
      ! object 'radio' not found
    Code
      with_filters(cfg, x, range)
    Condition
      Error in `with_filters()`:
      ! Can't use the function `range()` as an input.
      i Keywords are strings: `"range"`.
    Code
      with_filters(cfg, x = numeric)
    Condition
      Error in `with_filters()`:
      ! Can't use the function `numeric()` as an input.
      i Keywords are strings: `"numeric"`.
    Code
      with_filters(cfg, y = nope * 2)
    Condition
      Error in `with_filters()`:
      ! Can't evaluate `y = nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      with_filters(cfg, y = 1:2)
    Condition
      Error in `with_filters()`:
      ! Column y must have 1 or 3 values, not 2.
    Code
      with_filters(cfg, y = NULL)
    Condition
      Error in `with_filters()`:
      ! Column y must be a vector, not NULL.
    Code
      filterInput(with_filters(cfg, factors = "slider"))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column factors.
      Caused by error:
      ! "slider" isn't available for <factor> columns.
      i Use "radio", "select", or "selectize" instead.
    Code
      filterInput(with_filters(cfg, a_very_very_long_name = "range"))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column a_very_very_long_name.
      Caused by error:
      ! "range" isn't available for <numeric> columns.
      i Use "numeric", "radio", "select", "selectize", or "slider" instead.
    Code
      filterInput(with_filters(cfg, x = shiny::dateInput))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column x.
      Caused by error:
      ! "date" isn't available for <integer> columns.
      i Use "numeric", "radio", "select", "selectize", or "slider" instead.
    Code
      filterInput(with_filters(shinyfilters(data.frame(a = as.Date("2024-01-01"))),
      a = shiny::numericInput))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column a.
      Caused by error:
      ! "numeric" isn't available for <Date> columns.
      i Use "date", "radio", "range", "select", or "selectize" instead.
    Code
      filterInput(with_filters(shinyfilters(data.frame(stringsAsFactors = FALSE, a = NA_integer_)),
      a = "radio"))
    Condition
      Error in `filterInput()`:
      ! Column a must have at least one non-missing value.
    Code
      filterInput(shinyfilters(data.frame(stringsAsFactors = FALSE, a = NA_integer_)))
    Condition
      Error in `filterInput()`:
      ! Column a must have at least one non-missing value.

# with_ns() errors

    Code
      with_ns(df_config, shiny::NS("m"))
    Condition
      Error in `with_ns()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_ns(cfg, function(x) x)
    Condition
      Error in `with_ns()`:
      ! `ns` must not be a custom function.
    Code
      with_ns(cfg)
    Condition
      Error in `with_ns()`:
      ! `ns` must be supplied. Use `NULL` to remove the namespace.
    Code
      with_ns(cfg, c("m", "n"))
    Output
      <shinyfilters> * 4 filters * namespace "m-n"
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput
    Code
      with_ns(cfg, NA_character_)
    Output
      <shinyfilters> * 4 filters * namespace "NA"
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput

# with_defaults() errors

    Code
      with_defaults(df_config, slider = TRUE)
    Condition
      Error in `with_defaults()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_defaults(cfg, TRUE)
    Condition
      Error in `with_defaults()`:
      ! All elements of `...` must be named.
    Code
      with_defaults(cfg, ns = shiny::NS("m"))
    Condition
      Error in `with_defaults()`:
      ! `ns` isn't a default argument.
      i Use `with_ns()` to change the namespace.

# print() shows the namespace with_ns() sets

    Code
      print(with_ns(cfg, shiny::NS("other")))
    Output
      <shinyfilters> * 4 filters * namespace "other"
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput
    Code
      print(with_ns(cfg, NULL))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput

# print() shows each column's input

    Code
      print(shinyfilters(df_config))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput
    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters * namespace "m"
      
      Filters
        *  letters                <chr>  my_select
           factors                <fct>  selectizeInput
        *  x                      <int>  radioButtons
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `with_filters()`
    Code
      print(with_filters(shinyfilters(df_config), factors = "slider"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
        *  factors                <fct>  x "slider" isn't available for <factor> columns.
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `with_filters()`
    Code
      print(with_filters(shinyfilters(df_config), letters = shiny::radioButtons))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  radioButtons
           factors                <fct>  selectizeInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `with_filters()`
    Code
      print(shinyfilters(df_config, args_unique = "bad"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  x `args_unique` must be a list, not a string.
        factors                <fct>  x `args_unique` must be a list, not a string.
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput
      
      Default Overrides
        args_unique = "bad"
    Code
      print(shinyfilters(data.frame(stringsAsFactors = FALSE, x = "a")))
    Output
      <shinyfilters> * 1 filter
      
      Filters
        x  <chr>  selectizeInput

# print() shows the defaults that differ from shinyfilters()'s

    Code
      print(shinyfilters(df_config, slider = FALSE, width = "200px"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        #  x                      <int>  numericInput
        #  a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        slider = FALSE
        width  = "200px"
      
      # Filter set by default argument
    Code
      print(shinyfilters(df_config, radio = TRUE))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        #  letters                <chr>  radioButtons
        #  factors                <fct>  radioButtons
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      Default Overrides
        radio     = TRUE
        selectize = FALSE
      
      # Filter set by default argument
    Code
      print(shinyfilters(df_config, selectize = FALSE, multiple = FALSE))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        #  letters                <chr>  selectInput
        #  factors                <fct>  selectInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      Default Overrides
        selectize = FALSE
        multiple  = FALSE
      
      # Filter set by default argument
    Code
      print(with_defaults(shinyfilters(df_config), range = NULL, textbox = TRUE))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        #  letters                <chr>  textInput
           factors                <fct>  selectizeInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      Default Overrides
        range   = FALSE
        textbox = TRUE
      
      # Filter set by default argument

# print() shows a datetime column's type

    Code
      print(shinyfilters(df))
    Output
      <shinyfilters> * 2 filters
      
      Filters
        dte  <date>  dateRangeInput
        dtm  <dttm>  dateRangeInput

# print() resolves custom methods

    Code
      print(shinyfilters(df))
    Output
      <shinyfilters> * 2 filters
      
      Filters
        radio   <chr>  radioButtons
        custom  <chr>  <custom>

# print() names the input of a method that changes it

    Code
      print(shinyfilters(df))
    Output
      <shinyfilters> * 1 filter
      
      Filters
        tagged  <chr>  radioButtons

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
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      cfg[[9]]
    Condition
      Error in `cfg[[9]]`:
      ! Can't select columns past the end.
      i Location 9 doesn't exist.
      i There are only 4 columns.
    Code
      cfg[[c("x", "nope")]]
    Condition
      Error in `cfg[[c("x", "nope")]]`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.

# a config placed in a UI that htmltools inspects errors

    Code
      htmltools::tagGetAttribute(cfg["x"], "class")
    Condition
      Error:
      ! <shinyfilters> objects cannot be used in some shiny functions.
      i Use `[[`, `$`, `filterInput()`, or `dplyr::pull()` to render the filters directly.
    Code
      suppressMessages(htmltools::tagQuery(htmltools::div(cfg["x"]))$find(".a"))
    Condition
      Error:
      ! <shinyfilters> objects cannot be used in some shiny functions.
      i Use `[[`, `$`, `filterInput()`, or `dplyr::pull()` to render the filters directly.

# a config placed in bslib::accordion() errors

    Code
      bslib::accordion(cfg["x"])
    Condition
      Error:
      ! <shinyfilters> objects cannot be used in some shiny functions.
      i Use `[[`, `$`, `filterInput()`, or `dplyr::pull()` to render the filters directly.
    Code
      suppressMessages(bslib::accordion(bslib::accordion_panel("A", cfg["x"])))
    Condition
      Error:
      ! <shinyfilters> objects cannot be used in some shiny functions.
      i Use `[[`, `$`, `filterInput()`, or `dplyr::pull()` to render the filters directly.

# `[` returns a config with the selected columns

    Code
      print(cfg[c("letters", "x")])
    Output
      <shinyfilters> * 2 filters
      
      Filters
           letters  <chr>  selectizeInput
        *  x        <int>  radioButtons
      
      * Filter set by `with_filters()`

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
    Code
      cfg[0]
    Condition
      Error in `cfg[0]`:
      ! `0` doesn't select any columns.
    Code
      cfg[character(0)]
    Condition
      Error in `cfg[character(0)]`:
      ! `character(0)` doesn't select any columns.
    Code
      cfg[, "x"]
    Condition
      Error in `cfg[, "x"]`:
      ! Can't subset a <shinyfilters> object by rows and columns.
      i Select columns with `x[cols]`.
    Code
      cfg[1, 2]
    Condition
      Error in `cfg[1, 2]`:
      ! Can't subset a <shinyfilters> object by rows and columns.
      i Select columns with `x[cols]`.
    Code
      cfg[[1, 2]]
    Condition
      Error in `cfg[[1, 2]]`:
      ! Can't subset a <shinyfilters> object by rows and columns.
      i Select columns with `x[cols]`.
    Code
      cfg[factros]
    Condition
      Error in `cfg[factros]`:
      ! Can't select columns that don't exist.
      x Column `factros` doesn't exist.
    Code
      cfg[t]
    Condition
      Error in `cfg[t]`:
      ! Can't select columns that don't exist.
      x Column `t` doesn't exist.

# a shinyfilters object's properties are read-only

    Code
      cfg@data <- df_config
    Condition
      Error:
      ! @data is read-only
    Code
      cfg@args <- list(slider = TRUE)
    Condition
      Error:
      ! Use `?with_defaults` to set @args
    Code
      cfg@ns <- shiny::NS("m")
    Condition
      Error:
      ! Use `?with_ns` to set @ns
    Code
      cfg@overrides <- list()
    Condition
      Error:
      ! @overrides is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      cfg@added <- character()
    Condition
      Error:
      ! @added is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      cfg@replaced <- character()
    Condition
      Error:
      ! @replaced is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      S7::set_props(cfg, ns = shiny::NS("m"))
    Condition
      Error:
      ! Use `?with_ns` to set @ns

# a changed shinyfilters object is still read-only

    Code
      namespaced@ns <- NULL
    Condition
      Error:
      ! Use `?with_ns` to set @ns
    Code
      defaulted@args <- list()
    Condition
      Error:
      ! Use `?with_defaults` to set @args
    Code
      overridden@overrides <- list()
    Condition
      Error:
      ! @overrides is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      selected@data <- df_config
    Condition
      Error:
      ! @data is read-only

# functions that change a shinyfilters object are internal

    Code
      call_as_user(S7::S7_class(cfg), data = df_config)
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.
    Code
      call_as_user(._modify, cfg, data = df_config)
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.
    Code
      call_as_user(._config_filtered, cfg, df_config)
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.
    Code
      call_as_user(._set_overrides, cfg, list(x = list(input = identity)))
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.
    Code
      call_as_user(._set_column, cfg, "y", rlang::quo(x * 2), NULL, "f")
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.
    Code
      call_as_user(._override_cols, cfg, rlang::quo(x), rlang::quo("radio"), NULL,
      "f")
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.
    Code
      call_as_user(._select_columns, cfg, rlang::quo(x), "x", NULL)
    Condition
      Error in `fn()`:
      ! This function is internal to shinyfilters.
      i Change a <shinyfilters> object with `with_filters()`, `with_defaults()`, or `with_ns()`.

# a shinyfilters object changed through its attributes is invalid

    Code
      S7::validate(unnamed)
    Condition
      Error:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @args must have all elements named
    Code
      S7::validate(duplicated)
    Condition
      Error:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @args must have unique names
    Code
      S7::validate(custom_ns)
    Condition
      Error:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @ns must be created using shiny::NS()
    Code
      with_defaults(unnamed, slider = TRUE)
    Condition
      Error:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @args must have all elements named

