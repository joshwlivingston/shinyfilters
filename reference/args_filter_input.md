# Derive Arguments for shiny Inputs

Provides the appropriate function arguments for the input function
selected by
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
or
[`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md).

## Usage

``` r
args_filter_input(x, ...)

args_update_filter_input(x, ...)
```

## Arguments

- x:

  The object being passed to
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
  or
  [`updateFilterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/updateFilterInput.md).

- ...:

  Additional arguments passed to the method. See details.

## Value

A named list of arguments for a shiny input function

## Details

The following arguments are supported in `...`:

|                |                                                                                                                                                                                                                                                                                                 |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `range`        | *(Date, POSIXt)*. Logical. If `TRUE`, `args_filter_input()` will provide the arguments for range date inputs. Only applies when `x` is of class `Date` or `POSIXt`.                                                                                                                             |
| `textbox`      | *(character)*. Logical. If `FALSE` (the default), `args_filter_input()` will provide the arguments for select inputs.                                                                                                                                                                           |
| `choices_asis` | *(character, factor, list, logical)*. Logical. If `TRUE`, the choices provided to select inputs will not be modified. If `FALSE` (the default), duplicate values will be removed and the choices will be sorted. Only applies when `x` is of class `character`, `factor`, `list`, or `logical`. |
| `server`       | If `TRUE`, indicates that the choices will be provided server-side. In this case, arguments are not computed for `args_filter_input()`. Ignored in `args_update_filter_input()`.                                                                                                                |

## Examples

``` r
args_filter_input(iris$Petal.Length)
#> $min
#> [1] 1
#> 
#> $max
#> [1] 6.9
#> 
#> $value
#> [1] 6.9
#> 
```
