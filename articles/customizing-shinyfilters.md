# Customizing shinyfilters

## Introduction

shinyfilters is built to be fully customizable. This article
demonstrates the ways in which you can customize shinyfilters.

1.  [Extending shinyfilters](#extending-shinyfilters)
2.  [Overwriting shinyfilters](#overwriting-shinyfilters)

## Motivation

Let’s say you have an S7 class,
[`Person`](https://github.com/RConsortium/S7/blob/v0.2.0/vignettes/classes-objects.Rmd#L324):

``` r
library(S7)

StringNonEmpty <- new_property(
    class = class_character,
    validator = function(value) {
        if (length(value) != 1 || is.na(value) || value == "") {
            return("must be a non-empty string")
        }
    }
)

Person <- new_class(
    name = "Person",
    properties = list(
        first_name = StringNonEmpty,
        last_name = StringNonEmpty
    )
)
```

And you want to combine a list of `Person`’s into a new class, `People`:

``` r
People <- new_class(
    name = "People",
    parent = class_list,
    constructor = function(...) new_object(list(...)),
    validator = function(self) {
        if (!all(vapply(self, S7_inherits, logical(1), class = Person))) {
            return("must be a list of `Person`'s")
        }
    }
)

people <- People(
    Person("Ross", "Ihaka"),
    Person("Robert", "Gentleman")
)
people
#> <People> List of 2
#>  $ : <Person>
#>   ..@ first_name: chr "Ross"
#>   ..@ last_name : chr "Ihaka"
#>  $ : <Person>
#>   ..@ first_name: chr "Robert"
#>   ..@ last_name : chr "Gentleman"
```

Now, in your Shiny app, you want to use
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
to select a `Person` from `people`; however, if you call
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
on `people`, you will get an error:

``` r
library(shinyfilters)
library(shiny)

filterInput(people, inputId = "people", label = "Pick a person:")
#> Error in as.vector(x, "character"): cannot coerce type 'closure' to vector of type 'character'
```

To allow
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
to be called on `people`, you can *extend*
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

## Extending shinyfilters

Extending
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
involves two steps:

1.  Define a method for
    [`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).
2.  Define a method for
    [`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)

### Step 1: Define filterInput()

Defining a method for
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
involves dispatching the provided `x` to the appropriate shiny input
function.

In this case, we want
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
to dispatch to a
[`shiny::selectizeInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)
for `People`:

``` r
method(filterInput, People) <- function(x, ...) {
    call_filter_input(x, shiny::selectizeInput, ...)
}
```

It’s recommended that methods for
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
call
[`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md),
as shown above.
[`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md)
prepares the arguments for the input function, then calls the provided
input function with the prepared arguments.

*Now*, if we run
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
on `people`…

``` r
filterInput(people, inputId = "people", label = "Pick a person:")
#> Error in as.vector(x, "character"): cannot coerce type 'closure' to vector of type 'character'
```

… we’ll still get an error.

To fix *this* error, you need to define a method for
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md).

### Step 2: Define args_filter_input()

[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
tells
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
how to convert `x` into the arguments it uses for the shiny input
function.

To define
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md),
write a method that returns a named list, representing the arguments
passed to the selected input:

``` r
full_names <- new_generic("full_names", "x")
method(full_names, People) <- function(x) vapply(x, full_names, character(1))
method(full_names, Person) <- function(x) paste(x@first_name, x@last_name)

method(args_filter_input, People) <- function(x, ...) {
    list(choices = full_names(x))
}
```

Now you can call
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md):

``` r
filterInput(people, inputId = "people", label = "Pick a person:")
```

Pick a person:

Ross Ihaka Robert Gentleman

## Overwriting shinyfilters

Overwriting
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
is similar to extending
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md),
except that when you *overwrite*, you replace an *existing* method. Use
overwriting when you want to customize existing functionality.

### Step 1: Overwrite filterInput()

Overwrite
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
when you want to customize the input function that is selected.

For example, let’s say you want to use `shinyWidgets` instead of
`shiny`:

``` r
library(shinyWidgets)

method(filterInput, class_numeric) <- function(x, ...) {
    call_filter_input(x, numericRangeInput, ...)
}
#> Overwriting method filterInput(<integer>)
#> Overwriting method filterInput(<double>)
```

Now when you call
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
on a `character` vector,
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
will call `shinyWidgets` instead of `shiny`:

``` r
filterInput(0:10, inputId = "number", label = "Pick a number:")
```

Pick a number:

to

However, this isn’t quite right. Notice how the range shows the same
number twice. To fix this, we need to also overwrite
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md).

### Step 2: Overwrite args_filter_input()

Overwrite
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
when you want to modify the arguments passed to the selected input
function.

For example, to allow numeric vectors to work with the shinyWidgets
input function, we need to pass `value` as a length-two numeric vector:

``` r
method(args_filter_input, class_numeric) <- function(x, ...) {
    list(
        # Value should be a length-two vector, per ?numericRangeInput
        value = c(min(x, na.rm = TRUE), max(x, na.rm = TRUE))
    )
}
#> Overwriting method args_filter_input(<integer>)
#> Overwriting method args_filter_input(<double>)
```

Now, our overwritten
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
will work as intended:

``` r
filterInput(0:10, inputId = "number", label = "Pick a number:")
```

Pick a number:

to

## Why call_filter_input() ?

[`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md)
exists to handle the arguments for the provided vector and selected
input function.

------------------------------------------------------------------------

  

You *can* skip the call to
[`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md),
and in doing so, you skip the call to
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md).
So, you’d need to handle the argument preparation inside your
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md)
method:

``` r
method(filterInput, People) <- function(x, ...) {
    shiny::selectizeInput(
        choices = full_names(x),
        ...
    )
}
#> Overwriting method filterInput(<People>)

filterInput(people, inputId = "people", label = "Pick a person:")
```

Pick a person:

Ross Ihaka Robert Gentleman

  

However, such an implementation is more bug-prone, and, increases the
opportunity for confusing errors to emerge:

``` r
filterInput(
    people,
    inputId = "people",
    label = "Pick a person:",
    choices = full_names(people)
)
#> Error in selectInput(inputId, ..., selectize = FALSE, width = width): formal argument "choices" matched by multiple actual arguments
```

> Error in … : formal argument “choices” matched by multiple actual
> arguments

*“But I only provided `choices` once!”*

  

Additionally, the user of your extension may themselves be extending
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
only, and not
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).
In such cases, they generally would expect
[`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md)
to be called, so that *their* extension of
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md)
would be picked up by *your* extension of
[`filterInput()`](https://joshwlivingston.github.io/shinyfilters/reference/filterInput.md).

  

------------------------------------------------------------------------

For the best user experience, you should handle arguments in your
extension.
[`call_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/call_input_function.md)
exists for this purpose, handling the argument prep dynamically (via
[`args_filter_input()`](https://joshwlivingston.github.io/shinyfilters/reference/args_filter_input.md))
and sending informative errors:

``` r
method(filterInput, People) <- function(x, ...) {
    call_filter_input(x, shiny::selectizeInput, ...)
}
#> Overwriting method filterInput(<People>)

filterInput(
    people,
    inputId = "people",
    label = "Pick a person:",
    choices = full_names(people)
)
#> Error in error_input_args(x, names(args)): The argument `choices` is not supported in when used with `People` objects.
```
