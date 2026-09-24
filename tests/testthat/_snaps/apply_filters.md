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

