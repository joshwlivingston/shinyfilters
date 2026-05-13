# Changelog

## shinyfilters (development version)

## shinyfilters 0.3.0

CRAN release: 2026-01-17

### Additions

- Added functions used internally to access argument names needed by
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
  ([\#40](https://github.com/joshwlivingston/shinyfilters/issues/40)):
  - [`arg_name_input_id()`](https://joshwlivingston.github.io/shinyfilters/reference/arg_name_input_generics.md)
  - [`arg_name_input_label()`](https://joshwlivingston.github.io/shinyfilters/reference/arg_name_input_generics.md)
  - [`arg_name_input_value()`](https://joshwlivingston.github.io/shinyfilters/reference/arg_name_input_generics.md)
- Arguments can now be passed to generics used in
  [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  ([\#24](https://github.com/joshwlivingston/shinyfilters/issues/24),
  [\#56](https://github.com/joshwlivingston/shinyfilters/issues/56)):
  - `args_unique`: pass arguments to
    [`unique()`](https://rdrr.io/r/base/unique.html)
  - `args_sort`: pass arguments to
    [`sort()`](https://rdrr.io/r/base/sort.html)
- Implementations of
  [`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  can now return a value for `inputId` (or equivalent)
  (\[[\#87](https://github.com/joshwlivingston/shinyfilters/issues/87)\])

### Bugfixes

- Use [`anyNA()`](https://rdrr.io/r/base/NA.html) for NA checks and
  [`inherits()`](https://rdrr.io/r/base/class.html) for class checks,
  per `jarl check .` ([@novica](https://github.com/novica))
- The error message now displays for invalid S7 list dispatches
- An error is now thrown when an implementation of
  [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  returns a completely unnamed list
- [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md)
  now works when passing `selected` (or equivalent) as an argument
- `selected` argument (or equivalent) is now always removed from the
  result of
  [`args_update_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  ([\#90](https://github.com/joshwlivingston/shinyfilters/issues/90))

### Performance

- Unnecessarily repeated calls to
  [`apply_filters()`](https://joshwlivingston.github.io/shinyfilters/reference/apply_filters.md)
  were removed in
  [`serverFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/serverFilterInput.md)
  ([\#92](https://github.com/joshwlivingston/shinyfilters/issues/92))

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
  has been removed from the README’s list of extensible functions.
- Renames air.yaml Github Action job: “pkgdown” –\> “air”
- Adds to README instructions on installing release version

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
