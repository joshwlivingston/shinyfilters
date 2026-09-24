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

