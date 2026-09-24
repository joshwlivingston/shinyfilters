# get_filter_logical() throws error for missing column

    Code
      get_filter_logical(df, val = "test", column = "nonexistent")
    Condition
      Error in `method(get_filter_logical, list(new_S3_class("data.frame"), class_any))`:
      ! Column `nonexistent` not found in `x`.

