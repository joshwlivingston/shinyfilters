# shinyfilters 0.3.0

## Additions
* Added functions used internally to access argument names needed by `filterInput()` ([#40](https://github.com/joshwlivingston/shinyfilters/issues/40)):
  * `arg_name_input_id()`
  * `arg_name_input_label()`
  * `arg_name_input_value()`
* Arguments can now be passed to generics used in `args_filter_input()` ([#24](https://github.com/joshwlivingston/shinyfilters/issues/24), [#56](https://github.com/joshwlivingston/shinyfilters/issues/56)):
  * `args_unique`: pass arguments to `unique()`
  * `args_sort`: pass arguments to `sort()`
* Implementations of `args_update_filter_input()` can now return a value for `inputId` (or equivalent) ([[#87](https://github.com/joshwlivingston/shinyfilters/issues/87)])

## Bugfixes
* Use `anyNA()` for NA checks and `inherits()` for class checks, per `jarl check .` ([@novica](https://github.com/novica))
* The error message now displays for invalid S7 list dispatches
* An error is now thrown when an implementation of `args_filter_input()` returns a completely unnamed list
* `updateFilterInput()` now works when passing `selected` (or equivalent) as an argument
* `selected` argument (or equivalent) is now always removed from the result of `args_update_filter_input()` ([#90](https://github.com/joshwlivingston/shinyfilters/issues/90))

## Performance
* Unnecessarily repeated calls to `apply_filters()` were removed in `serverFilterInput()` ([#92](https://github.com/joshwlivingston/shinyfilters/issues/92))

## Documentation:
* All examples now correctly use `inputId` ([#17](https://github.com/joshwlivingston/shinyfilters/issues/17))
* All outputs now display in `get_input_values()` example ([#18](https://github.com/joshwlivingston/shinyfilters/issues/18))
* Borders have been removed in examples ([#7](https://github.com/joshwlivingston/shinyfilters/issues/7))
* Hyperlinks added for all issues in NEWS ([#26](https://github.com/joshwlivingston/shinyfilters/issues/26))
* Updated package title to be more precise ([#22](https://github.com/joshwlivingston/shinyfilters/issues/22))
* Updated filterInput() description in README to match new title

# shinyfilters 0.2.0

## Additions:
* `get_input_values()`: Generic to return multiple values from a shiny input 
  object ([#10](https://github.com/joshwlivingston/shinyfilters/issues/10), [#5](https://github.com/joshwlivingston/shinyfilters/issues/5))
* `get_input_ids()`: Generic to return the names of the shiny input ids for an 
  arbitrary object `x`. Method provided for data.frames ([#12](https://github.com/joshwlivingston/shinyfilters/issues/12))
* `get_input_labels()`: Same as `get_input_ids()`, but returns the `label`
  instead of `inputId` ([#10](https://github.com/joshwlivingston/shinyfilters/issues/10)).

## Bugfixes
* `get_input_values()` has been re-added; its erroneous removal was causing an 
  error in `serverFilterInput()` ([#10](https://github.com/joshwlivingston/shinyfilters/issues/10), [#5](https://github.com/joshwlivingston/shinyfilters/issues/5)).

## Documentation:
* `args_update_filter_input()` has been removed from the README's list of 
  extensible functions.
* Renames air.yaml Github Action job: "pkgdown" --> "air"
* Adds to README instructions on installing release version 

# shinyfilters 0.1.0

Initial release of shinyfilters.

The package provides the following functions:

* `filterInput()`: Create a shiny input from a vector or data.frame, with
  support for extension
* `updateFilterInput()`: Update a filter input created by `filterInput()`
* `serverFilterInput()`: Server logic to update filter inputs for data.frames
* `apply_filters()`: Apply a list of filters to a data.frame
* `args_filter_input()`, `args_update_filter_input()`: Get default args for
  `filterInput()` and `updateFilterInput()`.
* `call_filter_input()`, `call_update_filter_input()`: Create calls to
  `filterInput()` and `updateFilterInput()`.
* `get_filter_logical()`: Compute a logical vector for filtering a data.frame 
  column
