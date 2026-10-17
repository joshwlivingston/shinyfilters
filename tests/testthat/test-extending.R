# filterInput ####
test_that("filterInput is extensible", {
	method(filterInput, ClassInteger) <- function(x, ...) {
		call_filter_input(x, shiny::sliderInput, ...)
	}
	expect_shiny_sliderInput(
		x = ClassInteger(choices_num),
		inputId = "",
		label = ""
	)
})

test_that("filterInput is extensible, without using call_filter_input", {
	input_impl <- function(x) {
		shiny::sliderInput(
			inputId = "",
			label = "",
			min = min(x, na.rm = TRUE),
			max = max(x, na.rm = TRUE),
			value = min(x, na.rm = TRUE)
		)
	}
	method(filterInput, ClassInteger) <- function(x, ...) {
		input_impl(x)
	}
	expect_identical(
		filterInput(ClassInteger(choices_num)),
		input_impl(choices_num)
	)
})

# args_filter_input ####
test_that("args_filter_input is extensible", {
	method(filterInput, ClassInteger) <- function(x, ...) {
		call_filter_input(x, shiny::numericInput, ...)
	}
	method(args_filter_input, ClassInteger) <- function(x, ...) {
		list(
			value = min(x, na.rm = TRUE),
			min = min(x, na.rm = TRUE),
			max = max(x, na.rm = TRUE),
			inputId = "Numeric Input Id",
			label = "Numeric Input Label"
		)
	}

	expect_identical(
		filterInput(ClassInteger(choices_num)),
		shiny::numericInput(
			inputId = "Numeric Input Id",
			label = "Numeric Input Label",
			value = min(choices_num, na.rm = TRUE),
			min = min(choices_num, na.rm = TRUE),
			max = max(choices_num, na.rm = TRUE)
		)
	)
})

# updateFilterInput ####

# arg_name_input_id ####

# arg_name_input_value ####

# arg_name_input_label ####

# get_filter_logical ####

# get_input_ids ####

# get_input_labels ####
