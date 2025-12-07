# Derive Arguments for shiny Inputs

Provides the appropriate function arguments for the Shiny input selected
by
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

## Usage

``` r
args_filter_input(x, ...)

args_update_filter_input(x, ...)
```

## Arguments

- x:

  The object being passed to
  [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

- ...:

  Additional arguments passed to the method. See details.

## Details

The following aruguments are supported in `...`:

|           |                                                                                                                       |
|-----------|-----------------------------------------------------------------------------------------------------------------------|
| `textbox` | *(character)*. Logical. If `FALSE` (the default), `args_filter_input()` will provide the arguments for select inputs. |

## Examples

``` r
args_filter_input(letters, as.factor = TRUE)
#> $choices
#>  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s"
#> [20] "t" "u" "v" "w" "x" "y" "z"
#> 
```
