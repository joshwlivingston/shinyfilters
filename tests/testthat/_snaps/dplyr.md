# mutate() labels a custom input the way with_filter() does

    Code
      print(dplyr::mutate(cfg, across(letters, my_select)))
    Output
      -- <shinyfilters> - 4 filters --------------------------------------------------
      
        letters                <chr>  my_select     *
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      * set by with_filter()
    Code
      print(dplyr::mutate(cfg, letters = my_select))
    Output
      -- <shinyfilters> - 4 filters --------------------------------------------------
      
        letters                <chr>  my_select     *
        factors                <fct>  selectInput
        x                      <int>  numericInput
        a_very_very_long_name  <dbl>  numericInput
      
      * set by with_filter()

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
      i It chooses each column's input; it doesn't add, drop, or move columns.
    Code
      dplyr::mutate(cfg, .by = x)
    Condition
      Error in `dplyr::mutate()`:
      ! `mutate()` doesn't support `.by` for a <shinyfilters> object.
      i It chooses each column's input; it doesn't add, drop, or move columns.
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
    Code
      dplyr::mutate(cfg, x = "radioo")
    Condition
      Error in `dplyr::mutate()`:
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
      x Got "radioo".

# pull() errors

    Code
      dplyr::pull(cfg, x, name = letters)
    Condition
      Error in `dplyr::pull()`:
      ! `name` is not supported for <shinyfilters> objects.

