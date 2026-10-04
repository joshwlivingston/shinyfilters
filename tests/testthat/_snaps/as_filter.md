# print() shows as_filter() arguments

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
      
      
      * Filter set by `with_filter()`
      ~ Filter replaced by `with_filter()`
    Code
      print(as_filter(shiny::sliderInput, value = range(.x), step = 2))
    Output
      <shinyfilters_filter> * sliderInput
        value = range(.x, na.rm = TRUE)
        step  = 2
    Code
      print(as_filter("selectize"))
    Output
      <shinyfilters_filter> * selectizeInput

# print() marks a row by its input, not its as_filter() arguments

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
           letters                <chr>  selectInput
                                           label = "Letters"
           factors                <fct>  selectInput
        #  x                      <int>  sliderInput
                                           value = range(.x, na.rm = TRUE)
        #  a_very_very_long_name  <dbl>  sliderInput
      
      Default Overrides
        slider = TRUE
      
      # Filter set by default argument
    Code
      print(as_filter(value = range(.x)))
    Output
      <shinyfilters_filter> * the column's input
        value = range(.x, na.rm = TRUE)

# as_filter() errors

    Code
      as_filter("sldier")
    Condition
      Error in `as_filter()`:
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
      x Got "sldier".
    Code
      as_filter(1:3)
    Condition
      Error in `as_filter()`:
      ! An input must be a keyword or a function, not an integer vector.
    Code
      as_filter("slider", range(.x))
    Condition
      Error in `as_filter()`:
      ! All elements of `...` must be named.
    Code
      as_filter("slider", inputId = "x")
    Condition
      Error in `as_filter()`:
      ! Can't set `inputId` in `as_filter()`.
      i An input's id is always its column's name.
    Code
      as_filter()
    Condition
      Error in `as_filter()`:
      ! `as_filter()` needs an input or at least one argument.
    Code
      with_filter(cfg, nope = as_filter("slider"))
    Condition
      Error in `with_filter()`:
      ! Can't find column nope.
      x `as_filter("slider")` chooses the input for an existing column.
      i To add a column, compute it from the others: `with_filter(filters, nope = <expression>)`.
    Code
      with_filter(cfg, nope = as_filter(step = 2))
    Condition
      Error in `with_filter()`:
      ! Can't find column nope.
      x `as_filter(step = 2)` sets arguments for an existing column's input.
      i To add a column, compute it from the others: `with_filter(filters, nope = <expression>)`.
    Code
      with_filter(cfg, x, as_filter("sldier"))
    Condition
      Error in `with_filter()`:
      ! Can't evaluate the input `as_filter("sldier")`.
      Caused by error in `as_filter()`:
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
      x Got "sldier".
    Code
      with_filter(cfg, x, as_filter("slider", max = max(a_very_very_long_name)))
    Condition
      Error in `with_filter()`:
      ! Can't evaluate the input `as_filter("slider", max = max(a_very_very_long_name))`.
      Caused by error:
      ! object 'a_very_very_long_name' not found
    Code
      filterInput(with_filter(cfg, x = as_filter("slider", value = nope(.x))))
    Condition
      Error in `filterInput()`:
      ! Can't evaluate `value = nope(.x)` for column x.
      Caused by error in `nope()`:
      ! could not find function "nope"
    Code
      filterInput(with_filter(cfg, x = as_filter("slider", valeu = 1)))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column x.
      Caused by error:
      ! unused argument (valeu = 1)
    Code
      filterInput(with_filter(cfg, letters = as_filter("slider", value = 1)))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column letters.
      Caused by error:
      ! "slider" isn't available for <character> columns.
      i Use "area", "radio", "selectize", or "textbox" instead.
    Code
      filterInput(with_filter(cfg, letters = as_filter(valeu = 1)))
    Condition
      Error in `filterInput()`:
      ! Can't create an input for column letters.
      Caused by error:
      ! unused argument (valeu = 1)

