# Apply Filters to an object

Applies a list of filters to an object, returning the filtered object.

## Usage

``` r
apply_filters(
  x,
  filter_list,
  filter_combine_method = "and",
  expanded = FALSE,
  cols = NULL,
  ...
)
```

## Arguments

- x:

  An object to filter; typically a data.frame.

- filter_list:

  A named list of filter values, used to filter the values in `x`. If
  `filter_list` is `NULL`, `x` is returned unmodified.

- filter_combine_method:

  A string or function indicating how to combine multiple filters. If a
  string, it can be "and" (or "&") for logical AND, or "or" (or "\|")
  for logical OR. If a function, it should take two logical vectors and
  return a combined logical vector.

- expanded:

  Logical; if `TRUE`, returns a named list of data.frames, each
  containing one column, its own, filtered according to the values of
  all *other* filters.

- cols:

  Optional character vector of column names to retain in the output when
  `x` is a data.frame. If `NULL` (the default), all columns are
  retained.

- ...:

  Additional arguments passed to
  [`get_filter_logical()`](https://joshwlivingston.github.io/shinyfilters/reference/get_filter_logical.md).

## Value

A filtered object, or a named list of filtered objects if
`expanded = TRUE`.

## Examples

``` r
library(S7)
df <- data.frame(
 category = rep(letters[1:3], each = 4),
 value = 1:12,
 date = as.Date('2024-01-01') + 0:11
)
filters <- list(
  category = c("a", "b"),
  value = c(3, 11)
)

# Apply filters with logical AND
apply_filters(df, filters, filter_combine_method = "and")
#>   category value       date
#> 3        a     3 2024-01-03
#> 4        a     4 2024-01-04
#> 5        b     5 2024-01-05
#> 6        b     6 2024-01-06
#> 7        b     7 2024-01-07
#> 8        b     8 2024-01-08

# Apply filters with logical OR
apply_filters(df, filters, filter_combine_method = "or")
#>    category value       date
#> 1         a     1 2024-01-01
#> 2         a     2 2024-01-02
#> 3         a     3 2024-01-03
#> 4         a     4 2024-01-04
#> 5         b     5 2024-01-05
#> 6         b     6 2024-01-06
#> 7         b     7 2024-01-07
#> 8         b     8 2024-01-08
#> 9         c     9 2024-01-09
#> 10        c    10 2024-01-10
#> 11        c    11 2024-01-11

# Get expanded filters
apply_filters(df, filters, expanded = TRUE)
#> $category
#>    category
#> 3         a
#> 4         a
#> 5         b
#> 6         b
#> 7         b
#> 8         b
#> 9         c
#> 10        c
#> 11        c
#> 
#> $value
#>   value
#> 1     1
#> 2     2
#> 3     3
#> 4     4
#> 5     5
#> 6     6
#> 7     7
#> 8     8
#> 
```
