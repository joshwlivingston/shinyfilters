# updateFilterInput() errors for an input it can't update

    Code
      updateFilterInput(with_filter(cfg, letters = shiny::checkboxGroupInput))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      x Its input is set by a function with no known update function.
      i Name one with `as_filter(<input>, .update_fn = <function>)`.
    Code
      updateFilterInput(with_filter(cfg, c(letters, factors), shiny::checkboxGroupInput))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for columns letters and factors.
      x Their inputs are set by functions with no known update function.
      i Name one with `as_filter(<input>, .update_fn = <function>)`.
    Code
      update_messages(updateFilterInput(with_filter(cfg, factors = "slider")[
        "factors"]))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column factors.
      Caused by error:
      ! "slider" isn't available for <factor> columns.
      i Use "radio", "select", or "selectize" instead.
    Code
      update_messages(updateFilterInput(with_filter(cfg, letters = as_filter(shiny::checkboxGroupInput,
      .update_fn = shiny::updateNumericInput))))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      Caused by error:
      ! unused argument (choices = c("a", "b", "c"))

