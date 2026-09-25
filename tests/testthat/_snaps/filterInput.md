# filterInput() throws error when supplied vector is all NA

    Code
      filterInput(x = choices_chr_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! `x` must have at least one non-missing element.
    Code
      filterInput(x = choices_cpx_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! `x` must have at least one non-missing element.
    Code
      filterInput(x = choices_rel_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! `x` must have at least one non-missing element.
    Code
      filterInput(x = choices_int_na, inputId = "", label = "")
    Condition
      Error in `filterInput()`:
      ! `x` must have at least one non-missing element.

# call_filter_input errors for data.frames

    Code
      call_filter_input(test_df, shiny::selectInput)
    Condition
      Error in `call_filter_input()`:
      ! `call_filter_input()` does not work with a <data.frame>.
      i Instead, call `filterInput()` on each column.

# filterInput: radio and selectize cannot both be TRUE

    Code
      filterInput(choices_chr, inputId = "test", label = "Label", radio = TRUE,
        selectize = TRUE)
    Condition
      Error in `filterInput()`:
      ! `radio` and `selectize` can't both be `TRUE`.

# filterInput: method not found for S7 object passed as list

    Code
      filterInput(obj)
    Condition
      Error in `filterInput()`:
      ! No `filterInput()` method found for class <ClassList>.

# filterInput: arg supplied that is provided by args_filter_input()

    Code
      filterInput(letters, choices = letters)
    Condition
      Error in `filterInput()`:
      ! The argument `choices` is not supported with <character> objects.
    Code
      filterInput(choices_dte, min = min(choices_dte))
    Condition
      Error in `filterInput()`:
      ! The argument `min` is not supported with <Date> objects.

# ns must be result of shiny::NS()

    Code
      filterInput(x = choices_chr, inputId = "my_input", label = "Label", ns = function(
        x) x)
    Condition
      Error in `filterInput()`:
      ! `ns` must be the result of calling `shiny::NS()`.

# ns requires inputId argument

    Code
      filterInput(x = choices_chr, label = "Label", ns = ns)
    Condition
      Error in `filterInput()`:
      ! `inputId` is required when `ns` is provided.

