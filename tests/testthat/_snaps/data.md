# nyc_flights gets an input for every column

    Code
      as_filters(nyc_flights)
    Output
      -- <shinyfilters> - 7 filters --------------------------------------------------
      
        date       <date>  dateInput
        carrier    <chr>   selectInput
        origin     <fct>   selectInput
        dest       <chr>   selectInput
        dep_delay  <dbl>   numericInput
        distance   <dbl>   numericInput
        delayed    <lgl>   selectInput

