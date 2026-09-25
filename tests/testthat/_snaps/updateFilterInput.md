# call_update_filter_input errors for data.frames

    Code
      call_update_filter_input(test_df, shiny::updateSelectInput)
    Condition
      Error in `call_update_filter_input()`:
      ! `call_update_filter_input()` does not work with a <data.frame>.
      i Instead, call `updateFilterInput()` on each column.

# updateFilterInput: radio and selectize cannot both be TRUE

    Code
      updateFilterInput(choices_chr, inputId = "test", radio = TRUE, selectize = TRUE)
    Condition
      Error in `method(updateFilterInput, class_character)`:
      ! `radio` and `selectize` can't both be `TRUE`.

