# arg_name_input_id: implementation returns NULL

    Code
      filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule"))
    Error <rlang_error>
      `arg_name_input_id(x)` must not return `NULL` when `ns` is provided.

# arg_name_input_value: method not found for S7 object passed as list

    Code
      arg_name_input_value(obj)
    Error <rlang_error>
      No `arg_name_input_value()` method found for class <ClassList>.

