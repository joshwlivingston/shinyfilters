# with_filters() errors with across()

    Code
      with_filters(cfg, across())
    Condition
      Error in `with_filters()`:
      ! `across()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      with_filters(cfg, across(where(is.numeric)))
    Condition
      Error in `with_filters()`:
      ! `across()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      with_filters(cfg, across(x, "radio", .names = "{.col}_1"))
    Condition
      Error in `with_filters()`:
      ! `across()` doesn't support `.names` here.
      i It chooses an input for the selected columns; it doesn't rename them.
    Code
      with_filters(cfg, across(x, "radio", foo = 1))
    Condition
      Error in `with_filters()`:
      ! `across()` takes only `.cols` and `.fns` here.
      x Got 1 extra argument.
    Code
      with_filters(cfg, x = across(where(is.numeric), "slider"))
    Condition
      Error in `with_filters()`:
      ! `across()` can't be named.
      i `across()` already selects the columns it sets.
      i To set one column, use `x = input`.
    Code
      with_filters(cfg, across(x, letters ~ "radio"))
    Condition
      Error in `with_filters()`:
      ! Can't use `letters ~ "radio"` as an input.
      i `across()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filters(cfg, across(x, ~ mean(.x)))
    Condition
      Error in `with_filters()`:
      ! Can't use `~mean(.x)` as an input.
      i `across()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filters(cfg, across(x, list(a = "radio")))
    Condition
      Error in `with_filters()`:
      ! An input must be a keyword or a function, not a list.

