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

