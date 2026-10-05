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
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      

# print() marks columns added by with_filter()

    Code
      print(cfg)
    Output
      <shinyfilters> * 5 filters
      
      Filters
           letters                <chr>  selectInput
           factors                <fct>  selectInput
           x                      <int>  numericInput
           a_very_very_long_name  <dbl>  numericInput
        +  y                      <dbl>  numericInput
      
      
      + Filter added by `with_filter()`
    Code
      print(cfg["y"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        +  y  <dbl>  numericInput
      
      
      + Filter added by `with_filter()`
    Code
      print(cfg["x"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        x  <int>  numericInput
      

# print() marks columns replaced by with_filter()

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectInput
           factors                <fct>  selectInput
        ~  x                      <dbl>  numericInput
           a_very_very_long_name  <dbl>  numericInput
      
      
      ~ Filter replaced by `with_filter()`
    Code
      print(cfg["x"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        ~  x  <dbl>  numericInput
      
      
      ~ Filter replaced by `with_filter()`
    Code
      print(cfg["letters"])
    Output
      <shinyfilters> * 1 filter
      
      Filters
        letters  <chr>  selectInput
      

# print() shows one marker per row

    Code
      print(cfg)
    Output
      <shinyfilters> * 6 filters
      
      Filters
        #  letters                <chr>  selectizeInput
        #  factors                <fct>  selectizeInput
        ~  x                      <dbl>  radioButtons
        ~  a_very_very_long_name  <dbl>  numericInput
        +  y                      <dbl>  sliderInput
        +  z                      <chr>  selectizeInput
      
      Default Overrides
        slider    = TRUE
        selectize = TRUE
      
      # Filter set by default argument
      + Filter added by `with_filter()`
      ~ Filter replaced by `with_filter()`

# print() handles long names

    Code
      print(filters)
    Output
      <shinyfilters> * 8 filters * namespace "sidebar-mod"
      
      Filters
        #  date                       <date>  dateRangeInput
        *  origin                     <fct>   radioButtons
        #  dest                       <chr>   selectizeInput
           dep_delay                  <dbl>   numericInput
                                                value = urgfjkbhqaewpqaedoufikljshygbqaeoli...
        *  distance                   <dbl>   sliderInput
        #  delayed                    <lgl>   selectizeInput
        #  awpirgbeqaprkjgbaepirg...  <chr>   selectizeInput
        +  on_time                    <lgl>   selectizeInput
      
      Default Overrides
        range     = TRUE
        selectize = TRUE
      
      # Filter set by default argument
      * Filter set by `with_filter()`
      + Filter added by `with_filter()`

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

# shinyfilters() and with_filter() errors

    Code
      shinyfilters(1:3)
    Condition
      Error in `shinyfilters()`:
      ! `data` must be a data frame, not an integer vector.
    Code
      shinyfilters(df_config[0, ])
    Condition
      Error in `shinyfilters()`:
      ! `data` must have at least one row.
    Code
      shinyfilters(df_config, TRUE)
    Condition
      Error in `shinyfilters()`:
      ! All elements of `...` must be named.
    Code
      with_filter(df_config, x = "radio")
    Condition
      Error in `with_filter()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_filter(cfg)
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across_filters()` calls.
      i Select columns: `with_filter(filters, c(a, b), "radio")`.
      i Name columns: `with_filter(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filter(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filter(cfg, x)
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across_filters()` calls.
      i Select columns: `with_filter(filters, c(a, b), "radio")`.
      i Name columns: `with_filter(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filter(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filter(cfg, x, "radio", "slider")
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across_filters()` calls.
      i Select columns: `with_filter(filters, c(a, b), "radio")`.
      i Name columns: `with_filter(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filter(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filter(cfg, x = "radio", "letters")
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across_filters()` calls.
      i Select columns: `with_filter(filters, c(a, b), "radio")`.
      i Name columns: `with_filter(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filter(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filter(cfg, nope = "radio")
    Condition
      Error in `with_filter()`:
      ! Can't find column nope.
      x `"radio"` chooses the input for an existing column.
      i To add a column, compute it from the others: `with_filter(filters, nope = <expression>)`.
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
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".
    Code
      with_filter(cfg, nope ~ "radio")
    Condition
      Error in `with_filter()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_filter(cfg, where(is.logical) ~ "radio")
    Condition
      Error in `with_filter()`:
      ! `where(is.logical)` doesn't select any columns.
    Code
      with_filter(cfg, x ~ "radioo")
    Condition
      Error in `with_filter()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".
    Code
      with_filter(cfg, ~"radio")
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across_filters()` calls.
      i Select columns: `with_filter(filters, c(a, b), "radio")`.
      i Name columns: `with_filter(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filter(filters, c(a, b) ~ "radio", x = "slider")`.
    Code
      with_filter(cfg, x, c("radio", "slider"))
    Condition
      Error in `with_filter()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
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
      with_filter(cfg, x, range)
    Condition
      Error in `with_filter()`:
      ! Can't use the function `range()` as an input.
      i Keywords are strings: `"range"`.
    Code
      with_filter(cfg, x = numeric)
    Condition
      Error in `with_filter()`:
      ! Can't use the function `numeric()` as an input.
      i Keywords are strings: `"numeric"`.
    Code
      with_filter(cfg, y = nope * 2)
    Condition
      Error in `with_filter()`:
      ! Can't evaluate `y = nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      with_filter(cfg, y = 1:2)
    Condition
      Error in `with_filter()`:
      ! Column y must have 1 or 3 values, not 2.
    Code
      with_filter(cfg, y = NULL)
    Condition
      Error in `with_filter()`:
      ! Column y must be a vector, not NULL.
    Code
      filterInput(with_filter(cfg, factors = "slider"))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column factors.
      Caused by error:
      ! "slider" isn't available for <factor> columns.
      i Use "radio", "select", or "selectize" instead.
    Code
      filterInput(with_filter(cfg, a_very_very_long_name = "range"))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column a_very_very_long_name.
      Caused by error:
      ! "range" isn't available for <numeric> columns.
      i Use "numeric", "radio", "select", "selectize", or "slider" instead.
    Code
      filterInput(with_filter(cfg, x = shiny::dateInput))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column x.
      Caused by error:
      ! "date" isn't available for <integer> columns.
      i Use "numeric", "radio", "select", "selectize", or "slider" instead.
    Code
      filterInput(with_filter(shinyfilters(data.frame(a = as.Date("2024-01-01"))), a = shiny::numericInput))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column a.
      Caused by error:
      ! "numeric" isn't available for <Date> columns.
      i Use "date", "radio", "range", "select", or "selectize" instead.
    Code
      filterInput(with_filter(shinyfilters(data.frame(stringsAsFactors = FALSE, a = NA_integer_)),
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
      ! `.filters` must be a <shinyfilters> object, not a data frame.
      i Usage: `df_config |> shinyfilters() |> with_ns(shiny::NS("m"))`
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
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
    Code
      with_ns(cfg, NA_character_)
    Output
      <shinyfilters> * 4 filters * namespace "NA"
      
      Filters
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      

# with_defaults() errors

    Code
      with_defaults(df_config, slider = TRUE)
    Condition
      Error in `with_defaults()`:
      ! `.filters` must be a <shinyfilters> object, not a data frame.
      i Usage: `df_config |> shinyfilters() |> with_defaults(...)`
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
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
    Code
      print(with_ns(cfg, NULL))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      

# print() shows each column's input

    Code
      print(shinyfilters(df_config))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters * namespace "m"
      
      Filters
        *  letters                <chr>  <custom>
           factors                <fct>  selectInput
        *  x                      <int>  radioButtons
        #  a_very_very_long_name  <dbl>  sliderInput
      
      Default Overrides
        slider = TRUE
      
      # Filter set by default argument
      * Filter set by `with_filter()`
    Code
      print(with_filter(shinyfilters(df_config), factors = "slider"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectInput
        *  factors                <fct>  x "slider" isn't available for <factor> columns.
           x                      <int>  numericInput
           a_very_very_long_name  <dbl>  numericInput
      
      
      * Filter set by `with_filter()`
    Code
      print(with_filter(shinyfilters(df_config), letters = shiny::radioButtons))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  radioButtons
           factors                <fct>  selectInput
           x                      <int>  numericInput
           a_very_very_long_name  <dbl>  numericInput
      
      
      * Filter set by `with_filter()`
    Code
      print(shinyfilters(df_config, args_unique = "bad"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  x `args_unique` must be a list, not a string.
        factors                <fct>  x `args_unique` must be a list, not a string.
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      Default Overrides
        args_unique = "bad"
    Code
      print(shinyfilters(data.frame(stringsAsFactors = FALSE, x = "a")))
    Output
      <shinyfilters> * 1 filter
      
      Filters
        x  <chr>  selectInput
      

# print() resolves custom methods

    Code
      print(shinyfilters(df))
    Output
      <shinyfilters> * 2 filters
      
      Filters
        radio   <chr>  radioButtons
        custom  <chr>  <custom>
      

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
      <shinyfilters> * 2 filters
      
      Filters
           letters  <chr>  selectInput
        *  x        <int>  radioButtons
      
      Default Overrides
        slider = TRUE
      
      * Filter set by `with_filter()`

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

