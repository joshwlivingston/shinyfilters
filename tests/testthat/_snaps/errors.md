# apply_filters: unknown filter_combine_method

    Code
      apply_filters(test_df, list(chr_col = "i"), filter_combine_method = "unk")
    Condition
      Error in `._prepare_filter_logical()`:
      ! Unknown `filter_combine_method` value: unk

# apply_filters: filter_combine_method must be function

    Code
      apply_filters(test_df, list(chr_col = "i"), filter_combine_method = 123)
    Condition
      Error in `._prepare_filter_logical()`:
      ! Argument `filter_combine_method` must be a function.

# arg_name_input_id: implementation returns NULL

    Code
      filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule"))
    Condition
      Error:
      ! The result of `arg_name_input_id(x)` cannot be `NULL` when `ns` is provided

# args_filter_input validates args_unique must be list

    Code
      args_filter_input(choices_chr, args_unique = "not_a_list")
    Condition
      Error in `check_supplied_arguments()`:
      ! Supplied arguments must be a list.

# args_filter_input validates args_sort must be list

    Code
      args_filter_input(choices_chr, args_sort = "not_a_list")
    Condition
      Error in `check_supplied_arguments()`:
      ! Supplied arguments must be a list.

# args_filter_input validates args_unique list is named

    Code
      args_filter_input(choices_chr, args_unique = lst)
    Condition
      Error in `check_supplied_arguments()`:
      ! All supplied arguments must be named.

# args_filter_input validates args_sort list is named

    Code
      args_filter_input(choices_chr, args_sort = lst)
    Condition
      Error in `check_supplied_arguments()`:
      ! All supplied arguments must be named.

# args_filter_input validates args_unique names are unique

    Code
      args_filter_input(choices_chr, args_unique = lst)
    Condition
      Error in `check_supplied_arguments()`:
      ! All argument names must be unique.

# args_filter_input validates args_sort names are unique

    Code
      args_filter_input(choices_chr, args_sort = lst)
    Condition
      Error in `check_supplied_arguments()`:
      ! All argument names must be unique.

# args_filter_input: choices_asis must be TRUE for list

    Code
      args_filter_input(choices_lst, choices_asis = FALSE)
    Condition
      Error in `method(args_filter_input, class_list)`:
      ! Argument `choices_asis` must be TRUE when `x` is a list.

# args_filter_input: extension does not return list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `check_named_list_or_null()`:
      ! Value must be a NULL or a list.

# args_filter_input: extension does not return named list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `check_named_list_or_null()`:
      ! All list elements must be named.

---

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `check_named_list_or_null()`:
      ! All list elements must be named.

# args_filter_input: extension does not return uniquely named list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `check_named_list_or_null()`:
      ! All list names must be unique.

# call_filter_input errors for data.frames

    Code
      call_filter_input(test_df, shiny::selectInput)
    Condition
      Error in `call_filter_input()`:
      ! call_filter_input() is not implemented for data.frames.

# call_update_filter_input errors for data.frames

    Code
      call_update_filter_input(test_df, shiny::updateSelectInput)
    Condition
      Error in `call_update_filter_input()`:
      ! call_update_filter_input() is not implemented for data.frames.

# get_filter_logical: column not found

    Code
      get_filter_logical(test_df, "i", column = "nonexistent")
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! Column `nonexistent` not found in `x`.

# get_filter_logical: column argument is non-empty string

    Code
      get_filter_logical(test_df, "i", column = NA_character_)
    Condition
      Error in `check_is_nonempty_string()`:
      ! `column` must be a non-empty string
    Code
      get_filter_logical(test_df, "i", column = "")
    Condition
      Error in `check_is_nonempty_string()`:
      ! `column` must be a non-empty string

# get_filter_logical: non-logical vector returned

    Code
      apply_filters(df, list(x = letters[1:5]))
    Condition
      Error in `._check_filter_logical()`:
      ! Filter on column `x` did not return a logical vector.

# get_filter_logical: logical vector of invalid length

    Code
      apply_filters(df, list(x = letters[1:5]))
    Condition
      Error in `._check_filter_logical()`:
      ! Filter on column `x` returned a logical vector of length 25, but expected length 26.

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

# serverFilterInput() with reactive() throws error when missing required columns

    Code
      ._prepare_input(input_list, x = test_df)
    Condition
      Error in `method(._prepare_input, new_S3_class("reactiveExpr"))`:
      ! Missing required input values: `chr_col_radio`, `chr_col_selectize`, `chr_col_textarea`, `chr_col_text`, `dte_col`, `dte_col_date_range`, `fct_col`, `log_col`, `num_col_slider`, `psc_col`, `psl_col`

# serverFilterInput() with reactive() warns when extra columns provided

    Code
      invisible(._prepare_input(input_list, x = test_df))
    Condition
      Warning in `method(._prepare_input, new_S3_class("reactiveExpr"))`:
      Ignoring unsupported input values: `unsupported`

# updateFilterInput: radio and selectize cannot both be TRUE

    Code
      updateFilterInput(choices_chr, inputId = "test", radio = TRUE, selectize = TRUE)
    Condition
      Error:
      ! Arguments `radio` and `selectize` cannot both be TRUE.

