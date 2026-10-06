# across_filters() errors

    Code
      across_filters(x, "radio")
    Condition
      Error in `across_filters()`:
      ! `across_filters()` must be used inside `with_filters()` or `mutate()`.
      i It selects columns and names one input for all of them.
    Code
      with_filters(cfg, across_filters())
    Condition
      Error in `with_filters()`:
      ! `across_filters()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      with_filters(cfg, across_filters(where(is.numeric)))
    Condition
      Error in `with_filters()`:
      ! `across_filters()` needs an input as its second argument.
      i Keywords are strings, e.g. `"slider"`.
      i Functions are shiny inputs, e.g. `shiny::radioButtons()`.
    Code
      with_filters(cfg, across_filters(x, "radio", .names = "{.col}_1"))
    Condition
      Error in `with_filters()`:
      ! `across_filters()` doesn't support `.names` here.
      i It chooses an input for the selected columns; it doesn't rename them.
    Code
      with_filters(cfg, across_filters(x, "radio", foo = 1))
    Condition
      Error in `with_filters()`:
      ! `across_filters()` takes only `.cols` and `.fns` here.
      x Got 1 extra argument.
    Code
      with_filters(cfg, x = across_filters(where(is.numeric), "slider"))
    Condition
      Error in `with_filters()`:
      ! `across_filters()` can't be named.
      i `across_filters()` already selects the columns it sets.
      i To set one column, use `x = input`.
    Code
      with_filters(cfg, across_filters(x, letters ~ "radio"))
    Condition
      Error in `with_filters()`:
      ! Can't use `letters ~ "radio"` as an input.
      i `across_filters()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filters(cfg, across_filters(x, ~ mean(.x)))
    Condition
      Error in `with_filters()`:
      ! Can't use `~mean(.x)` as an input.
      i `across_filters()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filters(cfg, across_filters(x, list(a = "radio")))
    Condition
      Error in `with_filters()`:
      ! An input must be a keyword or a function, not a list.
    Code
      with_filters(cfg, across(x, "radio"))
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across_filters()` calls.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.
      i `across()` works only inside `mutate()`; use `across_filters()` here.

