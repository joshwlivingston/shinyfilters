# Prepare and Evaluate Input Function and Arguments

Internal function used to prepare input arguments using
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md),
and gracefully pass them to provided input function.

## Usage

``` r
call_filter_input(x, .f, ...)

call_update_filter_input(x, .f, ...)
```

## Arguments

- x:

  The object being passed to
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

- .f:

  The input function to be called.

- ...:

  Arguments passed to either
  [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
  or provided input function.

## Value

The result of calling the provided input function.

## Details

`call_filter_input()` and `call_update_filter_input()` are used when
customizing shinyfilters. For more, see
[`vignette("customizing-shinyfilters")`](https://joshwlivingston.github.io/shinyfilters/articles/customizing-shinyfilters.md).

## Examples

``` r
if (FALSE) { # interactive()
library(S7)
library(shiny)
# call_filter_input() is used inside filterInput() methods
method(filterInput, class_numeric) <- function(x, ...) {
  call_filter_input(x, sliderInput, ...)
}

# call_update_filter_input() is used inside updateFilterInput() methods
method(updateFilterInput, class_numeric) <- function(x, ...) {
  call_update_filter_input(x, updateSliderInput, ...)
}
}
```
