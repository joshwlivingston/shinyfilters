# arg_name_input_id: implementation returns NULL

    Code
      filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule"))
    Condition
      Error in `filterInput()`:
      ! `arg_name_input_id(x)` must not return `NULL` when `ns` is provided.

# arg_name_input_value: method not found for S7 object passed as list

    Code
      arg_name_input_value(obj)
    Condition
      Error in `arg_name_input_value()`:
      ! No `arg_name_input_value()` method found for class <ClassList>.

