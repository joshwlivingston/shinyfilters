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

