# Compute a Filter Predicate

Computes a logical vector indicating which elements of `x` match the
filter criteria specified by `val`.

## Usage

``` r
get_filter_logical(x, val, ...)
```

## Arguments

- x:

  An object to filter; typically a data.frame.

- val:

  The filter criteria.

- ...:

  Arguments passed to methods. See details.

## Details

The following arguments are supported in `...`:

|              |                                                                                                                                                                   |
|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `column`     | When `x` is a data.frame, `column` is the name of the column intended to be filtered.                                                                             |
| `comparison` | When `x` is a numeric or Date and `val` is a length-**one** numeric or Date, `comparison` is the function used to compare `x` with `val`. The default is `<=`.    |
| `gte`        | When `x` is a numeric or Date and `val` is a length-**two** numeric or Date, `gte` controls whether to use `>=` (`TRUE`, default) or `>` (`FALSE`) on `val[[1]]`. |
| `lte`        | When `x` is a numeric or Date and `val` is a length-**two** numeric or Date, `lte` controls whether to use `<=` (`TRUE`, default) or `<` (`FALSE`) on `val[[2]]`  |
