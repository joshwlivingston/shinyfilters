#' Flights departing New York City
#'
#' A sample of 200 flights that departed New York City airports in 2013,
#' with a mix of column types for trying out [filterInput()].
#'
#' @format A data frame with 200 rows and 7 columns:
#' \describe{
#'   \item{date}{Date of departure.}
#'   \item{carrier}{Two-letter airline code.}
#'   \item{origin}{Origin airport: `"EWR"`, `"JFK"`, or `"LGA"`.}
#'   \item{dest}{Destination airport code.}
#'   \item{dep_delay}{Departure delay in minutes. Negative values are early
#'     departures; `NA` for cancelled flights.}
#'   \item{distance}{Distance between airports in miles.}
#'   \item{delayed}{Whether the flight arrived more than 15 minutes late; `NA`
#'     when the arrival time is unknown.}
#' }
#'
#' @source A random sample of `flights` from the nycflights13 package
#'   (<https://github.com/tidyverse/nycflights13>), released under CC0.
"nyc_flights"
