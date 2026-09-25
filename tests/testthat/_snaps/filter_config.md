# as_filters(): `ns` must be result of shiny::NS()

    Code
      as_filters(data.frame(a = letters), ns = function(x) x)
    Condition
      Error:
      ! <shinyfilters::FilterConfig> object properties are invalid:
      - @ns must be the result of calling `shiny::NS()`

