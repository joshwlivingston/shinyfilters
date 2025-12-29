# Determine Filter Input Argument Names

Generics that determine the appropriate argument names for filter input
functions based on the type of object being filtered. These generics
dispatch on `x` and return the shiny input argument name(s) used
internally by shinyfilters.

## Usage

``` r
arg_name_input_id(x, ...)

arg_name_input_label(x, ...)

arg_name_input_value(x, ...)
```

## Arguments

- x:

  The object called by
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

- ...:

  Additional arguments passed to methods.

## Value

- `arg_name_input_id()`: Always returns `"inputId"`

- `arg_name_input_label()`: Always returns `"label"`

- `arg_name_input_value()`: Returns the appropriate argument name(s):

  - character: `"selected"` (default), or `"value"` ()`textbox = TRUE`)

  - Date: `"value"` (default), or `c("start", "end")` (`range = TRUE`)

  - factor/list/logical: `"selected"`

  - numeric: `"value"`

  - POSIXt: dispatches to Date method

  - data.frame: list of values for each column
