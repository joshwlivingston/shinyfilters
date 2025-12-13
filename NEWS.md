# shinyfilters (development version)

* `args_update_filter_input()` has been removed from the readme's list of 
  extensible functions.
  * `args_update_filter_input()` is implemented as a *function* that calls 
    `args_filter_input()`, the *generic*.
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
