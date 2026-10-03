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
      with_filter(cfg, nope = as_filter("slider"))
    Condition
      Error in `with_filter()`:
      ! Can't find column nope.
      x `as_filter("slider")` chooses the input for an existing column.
      i To add a column, compute it from the others: `with_filter(filters, nope = <expression>)`.
    Code
      with_filter(cfg, x, as_filter("sldier"))
    Condition
      Error in `with_filter()`:
      ! Can't evaluate the input `as_filter("sldier")`.
      i Keywords are strings, e.g. `"radio"`.
      Caused by error in `as_filter()`:
      ! An input must be one of "area", "radio", "range", "selectize", "slider", or "textbox", or a function.
      x Got "sldier".
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

