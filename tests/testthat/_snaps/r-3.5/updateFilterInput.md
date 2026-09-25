# call_update_filter_input errors for data.frames

    Code
      call_update_filter_input(test_df, shiny::updateSelectInput)
    Error <rlang_error>
      `call_update_filter_input()` does not work with a <data.frame>.
      i Instead, call `updateFilterInput()` on each column.

# updateFilterInput: radio and selectize cannot both be TRUE

    Code
      updateFilterInput(choices_chr, inputId = "test", radio = TRUE, selectize = TRUE)
    Error <rlang_error>
      `radio` and `selectize` can't both be `TRUE`.

# updateFilterInput: method not found for S7 object passed as list

    Code
      updateFilterInput(obj, inputId = "x")
    Error <rlang_error>
      No `updateFilterInput()` method found for class <ClassList>.

