# Retrieve the Labels of Input Objects

Returns the labels of the shiny inputs for the provided object.

## Usage

``` r
get_input_labels(x, ...)
```

## Arguments

- x:

  An object for which to retrieve input labels; typically a data.frame.

- ...:

  Passed onto methods.

## Value

A character vector of input labels

## Examples

``` r
df <- data.frame(
  name = c("Alice", "Bob"),
  age = c(25, 30),
  completed = c(TRUE, FALSE)
)

get_input_labels(df)
#> [1] "name"      "age"       "completed"
```
