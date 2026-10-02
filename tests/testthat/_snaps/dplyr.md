# mutate() labels a custom input the way with_filter() does

    Code
      print(dplyr::mutate(cfg, across(letters, my_select)))
    Output
      - <shinyfilters> - 4 filters
      
        letters                <chr>  my_select     *
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      * Input chosen by `mutate()`
    Code
      print(dplyr::mutate(cfg, letters = my_select))
    Output
      - <shinyfilters> - 4 filters
      
        letters                <chr>  my_select     *
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      * Input chosen by `mutate()`

# print() marks columns added by mutate()

    Code
      print(cfg)
    Output
      - <shinyfilters> - 5 filters
      
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <dbl>  numericInput
        a_very_very_long_name  <dbl>  numericInput
        y                      <dbl>  numericInput  *
      
      * Column added by `mutate()`
    Code
      print(dplyr::mutate(cfg, y = "slider", letters = "radio"))
    Output
      - <shinyfilters> - 5 filters
      
        letters                <chr>  radioButtons  *
        factors                <fct>  selectInput
        x                      <dbl>  numericInput
        a_very_very_long_name  <dbl>  numericInput
        y                      <dbl>  sliderInput   **
      
      * Input chosen by `mutate()`
      * Column added by `mutate()`
    Code
      print(dplyr::select(cfg, x, letters))
    Output
      - <shinyfilters> - 2 filters
      
        x        <dbl>  numericInput
        letters  <chr>  selectInput

# print() names the functions that chose inputs

    Code
      print(cfg)
    Output
      - <shinyfilters> - 4 filters
      
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  sliderInput   *
        a_very_very_long_name  <dbl>  numericInput
      
      * Input chosen by `mutate()`
    Code
      print(with_filter(cfg, letters = "radio"))
    Output
      - <shinyfilters> - 4 filters
      
        letters                <chr>  radioButtons  *
        factors                <fct>  selectInput
        x                      <int>  sliderInput   *
        a_very_very_long_name  <dbl>  numericInput
      
      * Input chosen by `mutate()` or `with_filter()`
    Code
      print(with_filter(cfg, x = "radio"))
    Output
      - <shinyfilters> - 4 filters
      
        letters                <chr>  selectInput
        factors                <fct>  selectInput
        x                      <int>  radioButtons  *
        a_very_very_long_name  <dbl>  numericInput
      
      * Input chosen by `with_filter()`

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
      ! Each argument to `mutate()` must be named or use `across()`.
      i Named: `mutate(filters, origin = "radio")`.
      i `across()`: `mutate(filters, across(where(is.numeric), "slider"))`.
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
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
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
      i Set a namespace: `mutate(filters, with_ns(NS("id")))`.
      i Remove it: `mutate(filters, with_ns(NULL))`.
    Code
      dplyr::mutate(cfg, with_ns(cfg, shiny::NS("m")))
    Condition
      Error in `dplyr::mutate()`:
      ! `with_ns()` takes only `ns` inside `mutate()`.
      i Set a namespace: `mutate(filters, with_ns(NS("id")))`.
      i Remove it: `mutate(filters, with_ns(NULL))`.
    Code
      dplyr::mutate(cfg, with_ns("m"))
    Condition
      Error in `dplyr::mutate()`:
      ! `ns` must be the result of calling `shiny::NS()`.

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
      ! Can't place a <shinyfilters> object in the UI of an app that uses bookmarking.
      i Call `filterInput(filters)` inside the UI function instead, so the inputs restore their bookmarked values.

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

