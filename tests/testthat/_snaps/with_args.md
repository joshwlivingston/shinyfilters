# print() shows with_args() arguments

    Code
      print(cfg)
    Output
      <shinyfilters> * 4 filters
      
      Filters
        letters                <chr>  selectizeInput
                                        label = "Letters"
        factors                <fct>  selectizeInput
        x                      <int>  sliderInput
                                        value = range(.x, na.rm = TRUE)
                                        step  = 2
        a_very_very_long_name  <dbl>  sliderInput

# with_args() errors

    Code
      with_args(df_config, x ~ step := 2)
    Condition
      Error in `with_args()`:
      ! `.filters` must be created by `shinyfilters()`, not a data frame.
    Code
      with_args(cfg)
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x = list(step = 2))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x = list(step = 2)` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, value := 1)
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `value := 1` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ "slider")
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x ~ "slider"` isn't one of these.
      i To choose an input, use `with_filters()`.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ list())
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x ~ list()` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, x ~ list(step := 2, 5))
    Condition
      Error in `with_args()`:
      ! All arguments must be named.
      x `5` isn't.
    Code
      with_args(cfg, x ~ list(step := 2, step = 4))
    Condition
      Error in `with_args()`:
      ! Argument `step` is set more than once.
    Code
      with_args(cfg, x ~ inputId := "y")
    Condition
      Error in `with_args()`:
      ! Can't set `inputId` in `with_args()`.
      i An input's id is always its column's name.
    Code
      with_args(cfg, nope ~ step := 2)
    Condition
      Error in `with_args()`:
      ! Can't select columns that don't exist.
      x Column `nope` doesn't exist.
    Code
      with_args(cfg, where(is.logical) ~ step := 2)
    Condition
      Error in `with_args()`:
      ! `where(is.logical)` doesn't select any columns.
    Code
      with_args(cfg, x ~ max := nope * 2)
    Condition
      Error in `with_args()`:
      ! Can't evaluate `max := nope * 2`.
      Caused by error:
      ! object 'nope' not found
    Code
      with_args(cfg, across(x))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `across(x)` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.
    Code
      with_args(cfg, across(x, step := 2, min := 0))
    Condition
      Error in `with_args()`:
      ! `across()` takes only `.cols` and `.fns` here.
      x Got 1 extra argument.
      i Put several arguments in `list()`.
    Code
      with_args(cfg, across(x, step := 2, .names = "a"))
    Condition
      Error in `with_args()`:
      ! `across()` doesn't support `.names` here.
      i It selects columns; it doesn't rename them.
    Code
      with_args(cfg, x = across(x, step := 2))
    Condition
      Error in `with_args()`:
      ! `with_args()` takes `cols ~ arg := value` formulas and `across()` calls.
      x `x = across(x, step := 2)` isn't one of these.
      i One argument: `with_args(filters, x ~ value := range(.x))`.
      i Several: `with_args(filters, x ~ list(value := range(.x), step = 5))`.
      i Several columns: `with_args(filters, across(c(x, y), value := range(.x)))`.

