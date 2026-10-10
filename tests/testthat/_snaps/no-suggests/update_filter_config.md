# updateFilterInput() errors for an input it can't update

    Code
      updateFilterInput(with_filters(cfg, letters = shiny::checkboxGroupInput))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      x Its input is set by a function with no known update function.
      i Name one among the input's arguments: `<input> ~ list(.update_fn = <function>)`.
    Code
      updateFilterInput(with_filters(cfg, c(letters, factors), shiny::checkboxGroupInput))
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, named arguments, or formulas.
    Code
      update_messages(updateFilterInput(with_filters(cfg, factors = "slider")[
        "factors"]))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column factors.
      Caused by error:
      ! "slider" isn't available for <factor> columns.
      i Use "radio", "select", or "selectize" instead.
    Code
      update_messages(updateFilterInput(with_filters(cfg, letters = shiny::checkboxGroupInput ~
        list(.update_fn = shiny::updateNumericInput))))
    Condition
      Error in `with_filters()`:
      ! `with_filters()` takes two unnamed arguments, named arguments, or formulas.

