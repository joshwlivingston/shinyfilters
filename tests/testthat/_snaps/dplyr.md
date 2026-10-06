# mutate() labels a custom input the way with_filters() does

    Code
      print(dplyr::mutate(cfg, across(letters, my_select)))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  my_select
           factors                <fct>  selectizeInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `mutate()`
    Code
      print(dplyr::mutate(cfg, letters = my_select))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  my_select
           factors                <fct>  selectizeInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `mutate()`

# print() marks columns added by mutate()

    Code
      print(cfg)
    Output
      <shinyfilters> * 5 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        ~  x                      <dbl>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
        +  y                      <dbl>  sliderInput
      
      + Filter added by `mutate()`
      ~ Filter replaced by `mutate()`
    Code
      print(dplyr::mutate(cfg, y = "slider", letters = "radio"))
    Output
      <shinyfilters> * 5 filters
      
      Filters
        *  letters                <chr>  radioButtons
           factors                <fct>  selectizeInput
        ~  x                      <dbl>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
        +  y                      <dbl>  sliderInput
      
      * Filter set by `mutate()`
      + Filter added by `mutate()`
      ~ Filter replaced by `mutate()`
    Code
      print(dplyr::select(cfg, x, letters))
    Output
      <shinyfilters> * 2 filters
      
      Filters
        ~  x        <dbl>  sliderInput
           letters  <chr>  selectizeInput
      
      ~ Filter replaced by `mutate()`
    Code
      print(with_filters(cfg, z = y + 1, x = x / 2))
    Output
      <shinyfilters> * 6 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        ~  x                      <dbl>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
        +  y                      <dbl>  sliderInput
        +  z                      <dbl>  sliderInput
      
      + Filter added by `mutate()` or `with_filters()`
      ~ Filter replaced by `with_filters()`

# print() names the functions that chose inputs

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `mutate()`
    Code
      print(with_filters(cfg, letters = "radio"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  radioButtons
           factors                <fct>  selectizeInput
        *  x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `mutate()` or `with_filters()`
    Code
      print(with_filters(cfg, x = "radio"))
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectizeInput
           factors                <fct>  selectizeInput
        *  x                      <int>  radioButtons
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `with_filters()`

# mutate() errors

    Code
      dplyr::mutate(cfg, across(where(is.numeric)))
    Condition
      Error in `dplyr::mutate()`:
      ! `across()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      dplyr::mutate(cfg, x = across(where(is.numeric), "slider"))
    Condition
      Error in `dplyr::mutate()`:
      ! `across()` can't be named.
      i `across()` already selects the columns it sets.
      i To set one column, use `x = input`.
    Code
      dplyr::mutate(cfg, .keep = "none")
    Condition
      Error in `dplyr::mutate()`:
      ! `mutate()` doesn't support `.keep` for a <shinyfilters> object.
      i It chooses inputs and computes columns; it doesn't drop or move them.
    Code
      dplyr::mutate(cfg, .by = x)
    Condition
      Error in `dplyr::mutate()`:
      ! `mutate()` doesn't support `.by` for a <shinyfilters> object.
      i It chooses inputs and computes columns; it doesn't drop or move them.
    Code
      dplyr::mutate(cfg, 1 + 1)
    Condition
      Error in `dplyr::mutate()`:
      ! Each argument to `mutate()` must be named, a `cols ~ input` formula, or use `across()` or `with_ns()`.
      i Formula: `mutate(filters, where(is.numeric) ~ "slider")`.
      i Named: `mutate(filters, origin = "radio")`.
      i `across()`: `mutate(filters, across(where(is.numeric), "slider"))`.
      i `with_ns()`: `mutate(filters, with_ns("id"))`.
    Code
      dplyr::mutate(cfg, nope = "radio")
    Condition
      Error in `dplyr::mutate()`:
      ! Can't find column nope.
      x `"radio"` chooses the input for an existing column.
      i To add a column, compute it from the others: `mutate(filters, nope = <expression>)`.
    Code
      dplyr::mutate(cfg, x = "radioo")
    Condition
      Error in `dplyr::mutate()`:
      ! An input must be one of "area", "date", "numeric", "radio", "range", "select", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".
    Code
      dplyr::mutate(cfg, y = shiny::selectInput)
    Condition
      Error in `dplyr::mutate()`:
      ! Can't find column y.
      x `shiny::selectInput` chooses the input for an existing column.
      i To add a column, compute it from the others: `mutate(filters, y = <expression>)`.
    Code
      dplyr::mutate(cfg, y = nope * 2)
    Condition
      Error in `dplyr::mutate()`:
      ! Can't evaluate `y = nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      dplyr::mutate(cfg, x = radio)
    Condition
      Error in `dplyr::mutate()`:
      ! Can't evaluate `x = radio`.
      i Keywords are strings, e.g. `"radio"`.
      Caused by error:
      ! object 'radio' not found
    Code
      dplyr::mutate(cfg, y = 1:2)
    Condition
      Error in `dplyr::mutate()`:
      ! Column y must have 1 or 3 values, not 2.
    Code
      dplyr::mutate(cfg, y = NULL)
    Condition
      Error in `dplyr::mutate()`:
      ! Column y must be a vector, not NULL.
    Code
      dplyr::mutate(cfg, with_ns())
    Condition
      Error in `dplyr::mutate()`:
      ! `with_ns()` takes only `ns` inside `mutate()`.
      i Set a namespace: `mutate(filters, with_ns("id"))`.
      i Remove it: `mutate(filters, with_ns(NULL))`.
    Code
      dplyr::mutate(cfg, with_ns(cfg, shiny::NS("m")))
    Condition
      Error in `dplyr::mutate()`:
      ! `with_ns()` takes only `ns` inside `mutate()`.
      i Set a namespace: `mutate(filters, with_ns("id"))`.
      i Remove it: `mutate(filters, with_ns(NULL))`.
    Code
      dplyr::mutate(cfg, with_ns(1))
    Output
      <shinyfilters> * 4 filters * namespace "1"
      
      Filters
        letters                <chr>  selectizeInput
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
        a_very_very_long_name  <dbl>  sliderInput

# transmute() errors

    Code
      dplyr::transmute(cfg, .keep = "none")
    Condition
      Error in `dplyr::transmute()`:
      ! `transmute()` doesn't support `.keep` for a <shinyfilters> object.
      i It chooses inputs and computes columns; it doesn't drop or move them.
    Code
      dplyr::transmute(cfg, 1 + 1)
    Condition
      Error in `dplyr::transmute()`:
      ! Each argument to `transmute()` must be named, a `cols ~ input` formula, or use `across()` or `with_ns()`.
      i Formula: `transmute(filters, where(is.numeric) ~ "slider")`.
      i Named: `transmute(filters, origin = "radio")`.
      i `across()`: `transmute(filters, across(where(is.numeric), "slider"))`.
      i `with_ns()`: `transmute(filters, with_ns("id"))`.
    Code
      dplyr::transmute(cfg, nope = "radio")
    Condition
      Error in `dplyr::transmute()`:
      ! Can't find column nope.
      x `"radio"` chooses the input for an existing column.
      i To add a column, compute it from the others: `transmute(filters, nope = <expression>)`.
    Code
      dplyr::transmute(cfg)
    Condition
      Error in `dplyr::transmute()`:
      ! `transmute()` must keep at least one column.
      i Name columns: `transmute(filters, origin = "radio")`.
    Code
      dplyr::transmute(cfg, with_ns("m"))
    Condition
      Error in `dplyr::transmute()`:
      ! `transmute()` must keep at least one column.
      i Name columns: `transmute(filters, origin = "radio")`.
    Code
      dplyr::transmute(cfg, with_ns())
    Condition
      Error in `dplyr::transmute()`:
      ! `with_ns()` takes only `ns` inside `transmute()`.
      i Set a namespace: `transmute(filters, with_ns("id"))`.
      i Remove it: `transmute(filters, with_ns(NULL))`.
    Code
      dplyr::transmute(cfg, across(starts_with("nope"), "radio"))
    Condition
      Error in `dplyr::transmute()`:
      ! `starts_with("nope")` doesn't select any columns.

# pull() errors

    Code
      dplyr::pull(cfg, x, name = letters)
    Condition
      Error in `dplyr::pull()`:
      ! `name` is not supported for <shinyfilters> objects.

# a config placed in the UI of a bookmarked app errors

    Code
      htmltools::renderTags(shiny::sidebarPanel(cfg))
    Condition
      Error:
      ! <shinyfilters> objects cannot be placed in the UI of apps with bookmarking enabled.
      i Use `[[`, `$`, `filterInput()`, or `dplyr::pull()` inside the UI function to render the filters directly, so they restore their bookmarked values.

# select() errors name the user's call

    Code
      dplyr::select(cfg, nope)
    Condition
      Error in `select()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      dplyr::select(cfg)
    Condition
      Error in `select()`:
      ! `select()` must select at least one column.
      i Select columns: `select(filters, a, b)`.
    Code
      dplyr::select(cfg, where(is.complex))
    Condition
      Error in `select()`:
      ! `where(is.complex)` doesn't select any columns.
    Code
      dplyr::select(cfg, where(is.complex), where(is.raw))
    Condition
      Error in `select()`:
      ! `where(is.complex), where(is.raw)` doesn't select any columns.

