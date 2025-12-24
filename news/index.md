# Changelog

## shinyfilters (development version)

### Bugfixes

- Use [`anyNA()`](https://rdrr.io/r/base/NA.html) for NA checks and
  [`inherits()`](https://rdrr.io/r/base/class.html) for class checks,
  per `jarl check .` (thanks [@novica](https://github.com/novica)!)

### Documentation:

- All examples now correctly use `inputId`
  ([\#17](https://github.com/joshwlivingston/shinyfilters/issues/17))
- All outputs now display in
  [`get_input_values()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_values.md)
  example
  ([\#18](https://github.com/joshwlivingston/shinyfilters/issues/18))
- Borders have been removed in examples
  ([\#7](https://github.com/joshwlivingston/shinyfilters/issues/7))
- Hyperlinks added for all issues in NEWS
  ([\#26](https://github.com/joshwlivingston/shinyfilters/issues/26))
- Updated package title to be more precise
  ([\#22](https://github.com/joshwlivingston/shinyfilters/issues/22))
- Updated filterInput() description in README to match new title

## shinyfilters 0.2.0

CRAN release: 2025-12-17

### Additions:

- [`get_input_values()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_values.md):
  Generic to return multiple values from a shiny input object
  ([\#10](https://github.com/joshwlivingston/shinyfilters/issues/10),
  [\#5](https://github.com/joshwlivingston/shinyfilters/issues/5))
- [`get_input_ids()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_ids.md):
  Generic to return the names of the shiny input ids for an arbitrary
  object `x`. Method provided for data.frames
  ([\#12](https://github.com/joshwlivingston/shinyfilters/issues/12))
- [`get_input_labels()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_labels.md):
  Same as
  [`get_input_ids()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_ids.md),
  but returns the `label` instead of `inputId`
  ([\#10](https://github.com/joshwlivingston/shinyfilters/issues/10)).

### Bugfixes

- [`get_input_values()`](https://joshwlivingston.github.io/shinyfilters/reference/get_input_values.md)
  has been re-added; its erroneous removal was causing an error in
  [`serverFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/serverFilterInput.md)
  ([\#10](https://github.com/joshwlivingston/shinyfilters/issues/10),
  [\#5](https://github.com/joshwlivingston/shinyfilters/issues/5)).

### Documentation:

- [`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  has been removed from the readme’s list of extensible functions.
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
