# a shinyWidgets input is updated by its own update function

    Code
      print(picker)
    Output
      <shinyfilters> * 4 filters
      
      Filters
        *  letters                <chr>  pickerInput {shinyWidgets}
                                           .update_fn = updatePickerInput {shinyWidgets}
           factors                <fct>  selectizeInput
           x                      <int>  sliderInput
           a_very_very_long_name  <dbl>  sliderInput
      
      * Filter set by `with_filters()`

# a shinyWidgets function with no update function isn't given one

    Code
      updateFilterInput(with_filters(cfg, letters = shinyWidgets::colorSelectorInput))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      x Its input is set by a function with no known update function.
      i Name one among the input's arguments: `<input>(.update_fn := <function>)`.
    Code
      updateFilterInput(with_filters(cfg, letters = unexported))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      x Its input is set by a function with no known update function.
      i Name one among the input's arguments: `<input>(.update_fn := <function>)`.

# updateFilterInput() errors for an input it can't update

    Code
      updateFilterInput(with_filters(cfg, letters = shiny::checkboxGroupInput))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      x Its input is set by a function with no known update function.
      i Name one among the input's arguments: `<input>(.update_fn := <function>)`.
    Code
      updateFilterInput(with_filters(cfg, c(letters, factors), shiny::checkboxGroupInput))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for columns letters and factors.
      x Their inputs are set by functions with no known update function.
      i Name one among the input's arguments: `<input>(.update_fn := <function>)`.
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
      update_messages(updateFilterInput(with_filters(cfg, letters = shiny::checkboxGroupInput(
        .update_fn := shiny::updateNumericInput))))
    Condition
      Error in `updateFilterInput()`:
      ! Can't update the input for column letters.
      Caused by error:
      ! unused argument (choices = c("a", "b", "c"))

