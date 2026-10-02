# across_filters() errors

    Code
      across_filters(x, "radio")
    Condition
      Error in `across_filters()`:
      ! `across_filters()` must be used inside `with_filter()` or `mutate()`.
      i It selects columns and names one input for all of them.
    Code
      with_filter(cfg, across_filters())
    Condition
      Error in `with_filter()`:
      ! `across_filters()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      with_filter(cfg, across_filters(where(is.numeric)))
    Condition
      Error in `with_filter()`:
      ! `across_filters()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      with_filter(cfg, across_filters(x, "radio", .names = "{.col}_1"))
    Condition
      Error in `with_filter()`:
      ! `across_filters()` doesn't support `.names` here.
      i It chooses an input for the selected columns; it doesn't rename them.
    Code
      with_filter(cfg, across_filters(x, "radio", foo = 1))
    Condition
      Error in `with_filter()`:
      ! `across_filters()` takes only `.cols` and `.fns` here.
      x Got 1 extra argument.
    Code
      with_filter(cfg, x = across_filters(where(is.numeric), "slider"))
    Condition
      Error in `with_filter()`:
      ! `across_filters()` can't be named.
      i `across_filters()` already selects the columns it sets.
      i To set one column, use `x = input`.
    Code
      with_filter(cfg, across_filters(x, letters ~ "radio"))
    Condition
      Error in `with_filter()`:
      ! Can't use `letters ~ "radio"` as an input.
      i `across_filters()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filter(cfg, across_filters(x, ~ mean(.x)))
    Condition
      Error in `with_filter()`:
      ! Can't use `~mean(.x)` as an input.
      i `across_filters()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filter(cfg, across_filters(x, list(a = "radio")))
    Condition
      Error in `with_filter()`:
      ! An input must be a keyword or a function, not a list.
    Code
      with_filter(cfg, across(x, "radio"))
    Condition
      Error in `with_filter()`:
      ! `with_filter()` takes two unnamed arguments, named arguments, or `across_filters()`.
      i Select columns: `with_filter(filters, c(a, b), "radio")`.
      i Name columns: `with_filter(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filter(filters, across_filters(c(a, b), "radio"), x = "slider")`.
      i `across()` works only inside `mutate()`; use `across_filters()` here.

