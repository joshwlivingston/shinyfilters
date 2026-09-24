# filterInput() throws error when supplied vector is all NA

    Code
      filterInput(x = choices_chr_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! No nonmissing elements found
    Code
      filterInput(x = choices_cpx_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! No nonmissing elements found
    Code
      filterInput(x = choices_rel_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! No nonmissing elements found
    Code
      filterInput(x = choices_int_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! No nonmissing elements found

# call_filter_input errors for data.frames

    Code
      call_filter_input(test_df, shiny::selectInput)
    Condition
      Error in `call_filter_input()`:
      ! call_filter_input() is not implemented for data.frames.

# filterInput: radio and selectize cannot both be TRUE

    Code
      filterInput(choices_chr, inputId = "test", label = "Label", radio = TRUE,
        selectize = TRUE)
    Condition
      Error:
      ! Arguments `radio` and `selectize` cannot both be TRUE.

# filterInput: method not found for S7 object passed as list

    Code
      filterInput(obj)
    Condition
      Error in `s7_check_is_valid_list_dispatch()`:
      ! No method found for `filterInput()` for class `ClassList`.

# filterInput: arg supplied that is provided by args_filter_input()

    Code
      filterInput(letters, choices = letters)
    Condition
      Error in `error_input_args()`:
      ! The argument `choices` is not supported in when used with `character` objects.
    Code
      filterInput(choices_dte, min = min(choices_dte))
    Condition
      Error in `error_input_args()`:
      ! The arguments
       - `min`
       - `max`
       - `value`
      are not supported in when used with `Date` objects.

# ns must be result of shiny::NS()

    Code
      filterInput(x = choices_chr, inputId = "my_input", label = "Label", ns = function(
        x) x)
    Condition
      Error in `._check_valid_shiny_ns()`:
      ! `ns` must be the result of calling `shiny::NS()`.

# ns requires inputId argument

    Code
      filterInput(x = choices_chr, label = "Label", ns = ns)
    Condition
      Error:
      ! Argument `inputId` is required when `ns` is provided.

