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

When `x` is a `data.frame`:

|      |                                             |
|------|---------------------------------------------|
| `nm` | The name of the column in `x` to filter on. |

When `x` is a `data.frame` and `val` is numeric or Date:

|       |                                                                                                                   |
|-------|-------------------------------------------------------------------------------------------------------------------|
| `.f`  | When `val` is length-one, `.f` is the function used to compare `x` with `val`. The default is `<=`.               |
| `gte` | When `val` is length-two and `gte` is `TRUE` (the default), the *lower* bound, determined by `val`, is inclusive. |
| `lte` | When `val` is length-two and `lte` is `TRUE` (the default), the *upper* bound, determined by `val`, is inclusive. |
