# get_filter_logical() throws error for missing column

    Code
      get_filter_logical(df, val = "test", column = "nonexistent")
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! Column `nonexistent` not found in `x`.

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

