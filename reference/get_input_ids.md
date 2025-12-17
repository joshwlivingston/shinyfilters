# Retrieve the Ids of Input Objects

Returns the (unnamespaced) ids of the inputs for the provided object.

## Usage

``` r
get_input_ids(x, ...)
```

## Arguments

- x:

  An object for which to retrieve input ids; typically a data.frame.

- ...:

  Passed onto methods.

## Value

A character vector of input ids.

## Examples

``` r
df <- data.frame(
  name = c("Alice", "Bob"),
  age = c(25, 30),
  completed = c(TRUE, FALSE)
)

get_input_ids(df)
#> [1] "name"      "age"       "completed"
```
