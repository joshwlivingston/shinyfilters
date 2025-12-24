# shinyfilters (development version)

## Bugfixes
* Use `anyNA()` for NA checks and `inherits()` for class checks, per `jarl check .` (thanks @novica!)

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
* `args_update_filter_input()` has been removed from the readme's list of 
  extensible functions.
* Renames air.yaml Github Action job: "pkgdown" --> "air"
* Adds to readme instructions on installing release version 

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
