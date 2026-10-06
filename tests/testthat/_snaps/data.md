# nyc_flights gets an input for every column

    Code
      shinyfilters(nyc_flights)
    Output
      <shinyfilters> * 7 filters
      
      Filters
        date       <date>  dateRangeInput
        carrier    <chr>   selectizeInput
        origin     <fct>   selectizeInput
        dest       <chr>   selectizeInput
        dep_delay  <dbl>   sliderInput
        distance   <dbl>   sliderInput
        delayed    <lgl>   selectizeInput

