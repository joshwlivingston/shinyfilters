# Changelog

## shinyfilters (development version)

### Additions:

- [`get_input_values()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_values.md):
  Generic to return multiple values from a shiny input object
- [`get_input_ids()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_ids.md):
  Generic to return the names of the shiny input ids for an arbitrary
  object `x`. Method provided for data.frames
- [`get_input_labels()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_labels.md):
  Same as
  [`get_input_ids()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_ids.md),
  but returns the `label` instead of `inputId`.

### Bugfixes

- Fixed issue preventing
  [`serverFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/serverFilterInput.md)
  from running due to
  [`get_input_values()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_values.md)
  having been erroneously removed.

### Documentation:

- [`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  has been removed from the readme’s list of extensible functions.
  - [`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
    is implemented as a *function* that calls
    [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md),
    the *generic*.
- Renames air.yaml Github Action job: “pkgdown” –\> “air”
- Adds to readme instructions on installing release version

## shinyfilters 0.1.0

CRAN release: 2025-12-17

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
