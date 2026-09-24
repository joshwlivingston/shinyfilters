# call_update_filter_input errors for data.frames

    Code
      call_update_filter_input(test_df, shiny::updateSelectInput)
    Condition
      Error in `call_update_filter_input()`:
      ! call_update_filter_input() is not implemented for data.frames.

# updateFilterInput: radio and selectize cannot both be TRUE

    Code
      updateFilterInput(choices_chr, inputId = "test", radio = TRUE, selectize = TRUE)
    Condition
      Error:
      ! Arguments `radio` and `selectize` cannot both be TRUE.

