# Changelog

## shinyfilters (development version)

## shinyfilters 0.1.0

Initial release of shinyfilters.

The package provides the following functions:

- [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md):
  Create a shiny input from a vector or data.frame, with support for
  extension
- [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md):
  Update a filter input created by
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
- [`serverFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/serverFilterInput.md):
  Server logic to update filter inputs for data.frames
- [`apply_filters()`](https://joshwlivingston.github.io/shinyfilters/reference/apply_filters.md):
  Apply a list of filters to a data.frame
- [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md),
  [`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md):
  Get default args for
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
  and
  [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md).
- [`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md),
  [`call_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md):
  Create calls to
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
  and
  [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md).
- [`get_filter_logical()`](https://joshwlivingston.github.io/shinyfilters/reference/get_filter_logical.md):
  Compute a logical vector for filtering a data.frame column
