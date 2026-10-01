# Sample of nycflights13::flights used in examples and vignettes
flights <- nycflights13::flights

set.seed(2013)
rows <- sort(sample(nrow(flights), 200))
flights <- flights[rows, ]

nyc_flights <- data.frame(
	date = as.Date(ISOdate(flights$year, flights$month, flights$day)),
	carrier = flights$carrier,
	origin = factor(flights$origin),
	dest = flights$dest,
	dep_delay = as.numeric(flights$dep_delay),
	distance = as.numeric(flights$distance),
	delayed = flights$arr_delay > 15
)

usethis::use_data(nyc_flights, overwrite = TRUE)
