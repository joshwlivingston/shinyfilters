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

