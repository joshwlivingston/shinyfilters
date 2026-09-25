# args_filter_input validates args_unique must be list

    Code
      args_filter_input(choices_chr, args_unique = "not_a_list")
    Condition
      Error in `args_filter_input()`:
      ! `args_unique` must be a list, not a string.

# args_filter_input validates args_sort must be list

    Code
      args_filter_input(choices_chr, args_sort = "not_a_list")
    Condition
      Error in `args_filter_input()`:
      ! `args_sort` must be a list, not a string.

# args_filter_input validates args_unique list is named

    Code
      args_filter_input(choices_chr, args_unique = lst)
    Condition
      Error in `args_filter_input()`:
      ! All elements of `args_unique` must be named.

# args_filter_input validates args_sort list is named

    Code
      args_filter_input(choices_chr, args_sort = lst)
    Condition
      Error in `args_filter_input()`:
      ! All elements of `args_sort` must be named.

# args_filter_input validates args_unique names are unique

    Code
      args_filter_input(choices_chr, args_unique = lst)
    Condition
      Error in `args_filter_input()`:
      ! All names in `args_unique` must be unique.

# args_filter_input validates args_sort names are unique

    Code
      args_filter_input(choices_chr, args_sort = lst)
    Condition
      Error in `args_filter_input()`:
      ! All names in `args_sort` must be unique.

# args_filter_input: choices_asis must be TRUE for list

    Code
      args_filter_input(choices_lst, choices_asis = FALSE)
    Condition
      Error in `args_filter_input()`:
      ! `choices_asis` must be `TRUE` when `x` is a <list>.

# args_filter_input: extension does not return list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `filterInput()`:
      ! `args_filter_input(x)` must be a <list> or `NULL`, not a string.

# args_filter_input: extension does not return named list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `filterInput()`:
      ! All elements of `args_filter_input(x)` must be named.

---

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `filterInput()`:
      ! All elements of `args_filter_input(x)` must be named.

# args_filter_input: extension does not return uniquely named list

    Code
      filterInput(ClassCharacter(letters))
    Condition
      Error in `filterInput()`:
      ! All names in `args_filter_input(x)` must be unique.

