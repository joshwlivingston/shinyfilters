# get_filter_logical() throws error for missing column

    Code
      get_filter_logical(df, val = "test", column = "nonexistent")
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! Column "nonexistent" not found in `x`.

# get_filter_logical() warns when falling back for mismatched types

    Code
      get_filter_logical(1:3, "a")
    Condition
      Warning:
      ! No `get_filter_logical()` method for `x` of class <integer> and `val` of class <character>.
      i Returning `TRUE` for all elements.
    Output
      [1] TRUE TRUE TRUE

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

