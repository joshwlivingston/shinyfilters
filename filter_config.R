# examples that should all be equivalent after implementation
# once implemented, these will move to tests

# option 1 ####
penguins |>
	as_filters(slider = TRUE) |>
	with_filter(year = "radio") |>
	# with_args(
	# 	"numeric",
	# 	~ list(value = c(min(.x, na.rm = TRUE), max(.x, na.rm = TRUE)))
	# ) |>
	filterInput() -> x

# option 2 ####
penguins |>
	as_filters(slider = TRUE) |>
	with_filter(id("year"), shiny::radioButtons) |>
	# with_args(
	# 	class_numeric,
	# 	function(x) {
	# 		list(
	# 			min = min(x),
	# 			max = max(x),
	# 			value = c(min(x), max(x))
	# 		)
	# 	}
	# ) |>
	filterInput() -> y

# option 3.a ####
penguins_filters <-
	penguins |>
		as_filters() |>
		with_filter("numeric", "slider") |>
		with_filter(id("year"), "radio") |>
		# 	with_args(
		# 		numeric(),
		# 		~ list(value = c(min(.x), max(.x)))
		# 	) |>
		filterInput() -> z

penguins_filters <-
	penguins |>
		as_filters() |>
		with_filter(
			c("bill_len", "bill_dep", "flipper_len", "body_mass"),
			"slider"
		) |>
		with_filter(id("year"), "radio") |>
		# 	with_args(
		# 		numeric(),
		# 		~ list(value = c(min(.x), max(.x)))
		# 	) |>
		filterInput() -> s

# option 4 ####
penguins |>
	as_filters(slider = TRUE) |>
	with_filter(year = "radio") |>
	# with_args("slider", value = c(min(.x), max(.x))) |>
	filterInput() -> q

# option 4 ####
penguins |>
	as_filters(slider = TRUE) |>
	with_filter(year, radio) |>
	# with_args("slider", value = c(min(.x), max(.x))) |>
	filterInput() -> t

# original API ####
library(dplyr)
penguins <- penguins |>
	mutate(
		year = structure(
			year,
			class = c("use_radio", "character")
		)
	)

library(S7)
class_radio <- new_S3_class("use_radio")
method(filterInput, class_radio) <- function(x, ...) {
	call_filter_input(x, shiny::radioButtons, ...)
}

method(args_filter_input, class_numeric) <- function(x, ...) {
	min_x <- min(x, na.rm = TRUE)
	max_x <- max(x, na.rm = TRUE)
	list(
		min = min_x,
		max = max_x,
		value = max_x
		# value = c(min_x, max_x)
	)
}

filterInput(penguins, slider = TRUE) -> r

waldo::compare(x, y)
waldo::compare(x, z)
waldo::compare(x, q)
waldo::compare(x, t)
waldo::compare(x, r)
waldo::compare(x, s)
