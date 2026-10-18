# a shinyfilters object's properties are read-only

    Code
      cfg@data <- df_config
    Condition
      Error in `<shinyfilters>@data`:
      ! @data is read-only
    Code
      cfg@args <- list(slider = TRUE)
    Condition
      Error in `<shinyfilters>@args`:
      ! Use `?with_defaults` to set @args
    Code
      cfg@ns <- shiny::NS("m")
    Condition
      Error in `<shinyfilters>@ns`:
      ! Use `?with_ns` to set @ns
    Code
      cfg@overrides <- list()
    Condition
      Error in `<shinyfilters>@overrides`:
      ! @overrides is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      cfg@added <- character()
    Condition
      Error in `<shinyfilters>@added`:
      ! @added is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      cfg@replaced <- character()
    Condition
      Error in `<shinyfilters>@replaced`:
      ! @replaced is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      S7::set_props(cfg, ns = shiny::NS("m"))
    Condition
      Error in `<shinyfilters>@ns`:
      ! Use `?with_ns` to set @ns

# a changed shinyfilters object is still read-only

    Code
      namespaced@ns <- NULL
    Condition
      Error in `<shinyfilters>@ns`:
      ! Use `?with_ns` to set @ns
    Code
      defaulted@args <- list()
    Condition
      Error in `<shinyfilters>@args`:
      ! Use `?with_defaults` to set @args
    Code
      overridden@overrides <- list()
    Condition
      Error in `<shinyfilters>@overrides`:
      ! @overrides is only allowed to be modified internally.
      i See `?with_filters` for the user-facing function.
    Code
      selected@data <- df_config
    Condition
      Error in `<shinyfilters>@data`:
      ! @data is read-only

# a shinyfilters object changed through its attributes is invalid

    Code
      S7::validate(unnamed)
    Condition
      Error in `S7::validate()`:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @args must have all elements named
    Code
      S7::validate(duplicated)
    Condition
      Error in `S7::validate()`:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @args must have unique names
    Code
      S7::validate(custom_ns)
    Condition
      Error in `S7::validate()`:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @ns must be created using shiny::NS()
    Code
      with_defaults(unnamed, slider = TRUE)
    Condition
      Error in `class_shinyfilters()`:
      ! <shinyfilters::shinyfilters> object is invalid:
      - @args must have all elements named

