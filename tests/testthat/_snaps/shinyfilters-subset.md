# `[` returns a config with the selected columns

    Code
      print(cfg[c("letters", "x")])
    Output
      <shinyfilters> * 2 filters
      
      Filters
           letters  <chr>  selectizeInput
        *  x        <int>  radioButtons
      
      * Filter set by `with_filters()`

# `[` errors on unknown columns

    Code
      cfg["nope"]
    Condition
      Error in `cfg["nope"]`:
      ! Can't find column nope.
    Code
      cfg[9]
    Condition
      Error in `cfg[9]`:
      ! Can't select columns past the end.
      i Location 9 doesn't exist.
      i There are only 4 columns.
    Code
      cfg[c(x, TRUE)]
    Condition
      Error in `cfg[c(x, TRUE)]`:
      ! Can't select columns with `c(x, TRUE)`.
      x Logical values can't be combined with other selections.
    Code
      cfg[, "x"]
    Condition
      Error in `cfg[, "x"]`:
      ! Can't subset a <shinyfilters> object by rows and columns.
      i Select columns with `x[cols]`.
    Code
      cfg[1, 2]
    Condition
      Error in `cfg[1, 2]`:
      ! Can't subset a <shinyfilters> object by rows and columns.
      i Select columns with `x[cols]`.
    Code
      cfg[[1, 2]]
    Condition
      Error in `cfg[[1, 2]]`:
      ! Can't subset a <shinyfilters> object by rows and columns.
      i Select columns with `x[cols]`.
    Code
      cfg[factros]
    Condition
      Error in `cfg[factros]`:
      ! Can't find column factros.
    Code
      cfg[t]
    Condition
      Error in `cfg[t]`:
      ! Bad!

# `[` errors on a malformed `any_of()`

    Code
      cfg[tidyselect::any_of()]
    Condition
      Error in `cfg[tidyselect::any_of()]`:
      ! `any_of()` takes exactly one argument.
    Code
      cfg[tidyselect::any_of("x", "letters")]
    Condition
      Error in `cfg[tidyselect::any_of("x", "letters")]`:
      ! `any_of()` takes exactly one argument.
    Code
      cfg[tidyselect::any_of(TRUE)]
    Condition
      Error in `cfg[tidyselect::any_of(TRUE)]`:
      ! `any_of()` needs a character or numeric vector, not `TRUE`.

# `[[` errors on unknown columns

    Code
      cfg[["nope"]]
    Condition
      Error in `cfg[["nope"]]`:
      ! Can't find column nope.
    Code
      cfg[[9]]
    Condition
      Error in `cfg[[9]]`:
      ! Can't select columns past the end.
      i Location 9 doesn't exist.
      i There are only 4 columns.
    Code
      cfg[[c("x", "nope")]]
    Condition
      Error in `cfg[[c("x", "nope")]]`:
      ! Can't find column nope.

