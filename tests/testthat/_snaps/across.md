# with_filters() leaves another function named across() alone

    Code
      with_filters(cfg, across(x, "radio"))
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      x `across()` is another function here. To select columns, use `dplyr::across()` or a formula.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.

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
      i It selects columns; it doesn't rename them.
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
      ! Can't read `letters ~ "radio"`.
      i An input is followed by its arguments: `input ~ list(arg = value, ...)`.
    Code
      with_filters(cfg, across(x, ~ mean(.x)))
    Condition
      Error in `with_filters()`:
      ! Can't use `~mean(.x)` as an input.
      i `across()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filters(cfg, across(x, ~ list(step = 2)))
    Condition
      Error in `with_filters()`:
      ! Can't use `~list(step = 2)` as an input.
      i `across()` takes a keyword or a shiny input function, not a lambda.
    Code
      with_filters(cfg, base::across(x, "radio"))
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, or named arguments, `cols ~ input` formulas, and `across()` calls.
      x `across()` is another function here. To select columns, use `dplyr::across()` or a formula.
      i Select columns: `with_filters(filters, c(a, b), "radio")`.
      i Name columns: `with_filters(filters, a = "radio", b = "slider")`.
      i Mix the two: `with_filters(filters, c(a, b) ~ "radio", x = "slider")`.

