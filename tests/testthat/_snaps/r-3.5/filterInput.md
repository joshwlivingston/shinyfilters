# filterInput() throws error when supplied vector is all NA

    Code
      filterInput(x = choices_chr_na, inputId = "", label = "")
    Error <rlang_error>
      `x` must have at least one non-missing element.
    Code
      filterInput(x = choices_cpx_na, inputId = "", label = "")
    Error <rlang_error>
      `x` must have at least one non-missing element.
    Code
      filterInput(x = choices_rel_na, inputId = "", label = "")
    Error <rlang_error>
      `x` must have at least one non-missing element.
    Code
      filterInput(x = choices_int_na, inputId = "", label = "")
    Error <rlang_error>
      `x` must have at least one non-missing element.

# call_filter_input errors for data.frames

    Code
      call_filter_input(test_df, shiny::selectInput)
    Error <rlang_error>
      `call_filter_input()` does not work with a <data.frame>.
      i Instead, call `filterInput()` on each column.

# filterInput: radio and selectize cannot both be TRUE

    Code
      filterInput(choices_chr, inputId = "test", label = "Label", radio = TRUE,
        selectize = TRUE)
    Error <rlang_error>
      `radio` and `selectize` can't both be `TRUE`.

# filterInput: method not found for S7 object passed as list

    Code
      filterInput(obj)
    Error <rlang_error>
      No `filterInput()` method found for class <ClassList>.

# filterInput: arg supplied that is provided by args_filter_input()

    Code
      filterInput(letters, choices = letters)
    Error <rlang_error>
      The argument `choices` is not supported with <character> objects.
    Code
      filterInput(choices_dte, min = min(choices_dte))
    Error <rlang_error>
      The argument `min` is not supported with <Date> objects.

# ns must be result of shiny::NS()

    Code
      filterInput(x = choices_chr, inputId = "my_input", label = "Label", ns = function(
        x) x)
    Error <rlang_error>
      `ns` must be the result of calling `shiny::NS()`.

# ns requires inputId argument

    Code
      filterInput(x = choices_chr, label = "Label", ns = ns)
    Error <rlang_error>
      `inputId` is required when `ns` is provided.

