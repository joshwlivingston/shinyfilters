# shinyfilters 0.2.0

## Additions:
* `get_input_values()`: Generic to return multiple values from a shiny input 
  object (#11)
* `get_input_ids()`: Generic to return the names of the shiny input ids for an 
  arbitrary object `x`. Method provided for data.frames (#11)
* `get_input_labels()`: Same as `get_input_ids()`, but returns the `label`
  instead of `inputId` (#11).

## Bugfixes
* `get_input_values()` has been re-added; its erroneous removal was causing an 
  error in `serverFilterInput()` (#11).

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
