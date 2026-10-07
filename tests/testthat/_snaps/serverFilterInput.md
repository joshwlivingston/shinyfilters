# serverFilterInput() still takes `input`, with a warning

    Code
      session$flushReact()
    Condition
      Warning:
      The `input` argument of `shinyfilters_server()` is deprecated as of shinyfilters 0.4.0.
      i Please omit, or provide the `session` argument instead.
      This warning is displayed once per session.

---

    Code
      session$flushReact()
    Condition
      Warning:
      The `input` argument of `shinyfilters_server()` is deprecated as of shinyfilters 0.4.0.
      i Please omit, or provide the `session` argument instead.
      This warning is displayed once per session.

# shinyfilters_server() errors when called, for an input it can't update

    Code
      shinyfilters_server(cfg)
    Condition
      Error in `shinyfilters_server()`:
      ! Can't update the input for column letters.
      x Its input is set by a function with no known update function.
      i Name one among the input's arguments: `<input>(.update_fn := <function>)`.

# serverFilterInput() with reactive() throws error when missing required columns

    Code
      ._prepare_input(input_list, x = test_df)
    Condition
      Error in `._prepare_input()`:
      ! Missing required input values: "chr_col_radio", "chr_col_selectize", "chr_col_textarea", "chr_col_text", "dte_col", "dte_col_date_range", "fct_col", "log_col", "num_col_slider", "psc_col", and "psl_col".

# serverFilterInput() with reactive() warns when extra columns provided

    Code
      invisible(._prepare_input(input_list, x = test_df))
    Condition
      Warning in `._prepare_input()`:
      Ignoring unsupported input value: "unsupported".

