# apply_filters: unknown filter_combine_method

    Code
      apply_filters(test_df, list(chr_col = "i"), filter_combine_method = "unk")
    Condition
      Error in `apply_filters()`:
      ! Unknown `filter_combine_method` value "unk".
      i Must be one of "&", "and", "|", or "or", or a function.

# apply_filters: filter_combine_method must be function

    Code
      apply_filters(test_df, list(chr_col = "i"), filter_combine_method = 123)
    Condition
      Error in `apply_filters()`:
      ! `filter_combine_method` must be a string or a function, not a number.

# arg_name_input_id: implementation returns NULL

    Code
      filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule"))
    Condition
      Error in `filterInput()`:
      ! `arg_name_input_id(x)` must not return `NULL` when `ns` is provided.

# args_filter_input validates args_unique must be list

    Code
      args_filter_input(choices_chr, args_unique = "not_a_list")
    Condition
      Error in `method(args_filter_input, class_character)`:
      ! `args_unique` must be a list, not a string.

# args_filter_input validates args_sort must be list

    Code
      args_filter_input(choices_chr, args_sort = "not_a_list")
    Condition
      Error in `method(args_filter_input, class_character)`:
      ! `args_sort` must be a list, not a string.

# args_filter_input validates args_unique list is named

    Code
      args_filter_input(choices_chr, args_unique = lst)
    Condition
      Error in `method(args_filter_input, class_character)`:
      ! All elements of `args_unique` must be named.

# args_filter_input validates args_sort list is named

    Code
      args_filter_input(choices_chr, args_sort = lst)
    Condition
      Error in `method(args_filter_input, class_character)`:
      ! All elements of `args_sort` must be named.

# args_filter_input validates args_unique names are unique

    Code
      args_filter_input(choices_chr, args_unique = lst)
    Condition
      Error in `method(args_filter_input, class_character)`:
      ! All names in `args_unique` must be unique.

# args_filter_input validates args_sort names are unique

    Code
      args_filter_input(choices_chr, args_sort = lst)
    Condition
      Error in `method(args_filter_input, class_character)`:
      ! All names in `args_sort` must be unique.

# args_filter_input: choices_asis must be TRUE for list

    Code
      args_filter_input(choices_lst, choices_asis = FALSE)
    Condition
      Error in `method(args_filter_input, class_list)`:
      ! `choices_asis` must be `TRUE` when `x` is a <list>

# args_filter_input: extension does not return list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error:
      ! `args_filter_input(x)` must be a <list> or `NULL`, not a string.

# args_filter_input: extension does not return named list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error:
      ! All elements of `args_filter_input(x)` must be named.

---

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error:
      ! All elements of `args_filter_input(x)` must be named.

# args_filter_input: extension does not return uniquely named list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error:
      ! All names in `args_filter_input(x)` must be unique.

# call_filter_input errors for data.frames

    Code
      call_filter_input(test_df, shiny::selectInput)
    Condition
      Error in `call_filter_input()`:
      ! `call_filter_input()` does not work with a <data.frame>.
      i Instead, call `filterInput()` on each column.

# call_update_filter_input errors for data.frames

    Code
      call_update_filter_input(test_df, shiny::updateSelectInput)
    Condition
      Error in `call_update_filter_input()`:
      ! `call_update_filter_input()` does not work with a <data.frame>.
      i Instead, call `updateFilterInput()` on each column.

# get_filter_logical: column not found

    Code
      get_filter_logical(test_df, "i", column = "nonexistent")
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! Column "nonexistent" not found in `x`.

# get_filter_logical: column argument is non-empty string

    Code
      get_filter_logical(test_df, "i", column = NA_character_)
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! `column` must be a single non-empty string, not a character `NA`.
    Code
      get_filter_logical(test_df, "i", column = "")
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! `column` must be a single non-empty string, not `""`.

# get_filter_logical: non-logical vector returned

    Code
      apply_filters(df, list(x = letters[1:5]))
    Condition
      Error in `apply_filters()`:
      ! Filter on column {.val {column_name}} must return a logical vector, not an integer vector.

# get_filter_logical: logical vector of invalid length

    Code
      apply_filters(df, list(x = letters[1:5]))
    Condition
      Error in `apply_filters()`:
      ! Filter on column {.val {column_name}} must return a logical vector of length 26.
      x It returned a vector of length 25.

# filterInput: radio and selectize cannot both be TRUE

    Code
      filterInput(choices_chr, inputId = "test", label = "Label", radio = TRUE,
        selectize = TRUE)
    Condition
      Error in `method(filterInput, class_character)`:
      ! `radio` and `selectize` can't both be `TRUE`.

# filterInput: method not found for S7 object passed as list

    Code
      filterInput(obj)
    Condition
      Error in `method(filterInput, class_list)`:
      ! No `filterInput()` method found for class <ClassList>.

# filterInput: arg supplied that is provided by args_filter_input()

    Code
      filterInput(letters, choices = letters)
    Condition
      Error:
      ! The argument `choices` is not supported with <character> objects.
    Code
      filterInput(choices_dte, min = min(choices_dte))
    Condition
      Error:
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

# serverFilterInput() with reactive() throws error when missing required columns

    Code
      ._prepare_input(input_list, x = test_df)
    Condition
      Error in `method(._prepare_input, new_S3_class("reactiveExpr"))`:
      ! Missing required input values: "chr_col_radio", "chr_col_selectize", "chr_col_textarea", "chr_col_text", "dte_col", "dte_col_date_range", "fct_col", "log_col", "num_col_slider", "psc_col", and "psl_col".

# serverFilterInput() with reactive() warns when extra columns provided

    Code
      invisible(._prepare_input(input_list, x = test_df))
    Condition
      Warning:
      Ignoring unsupported input value: "unsupported".

# updateFilterInput: radio and selectize cannot both be TRUE

    Code
      updateFilterInput(choices_chr, inputId = "test", radio = TRUE, selectize = TRUE)
    Condition
      Error in `method(updateFilterInput, class_character)`:
      ! `radio` and `selectize` can't both be `TRUE`.

