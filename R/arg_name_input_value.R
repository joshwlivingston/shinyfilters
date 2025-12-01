# Generic: arg_name_input_value ####
arg_name_input_value <- new_generic(
	name = "arg_name_input_value",
	dispatch_args = c("x")
)

## Method: character ####
method(arg_name_input_value, class_character) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$textbox)) {
		return("value")
	}
	"selected"
}

## Method: data.frame ####
method(arg_name_input_value, class_data.frame) <- function(x, ...) {
	lapply(x, arg_name_input_value, ...)
}

## Method: Date  ####
method(arg_name_input_value, class_Date) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$range)) {
		# `range = TRUE`
		return(c("start", "end"))
	}
	"value"
}

## Method: factor | logical ####
method(arg_name_input_value, class_factor | class_logical) <- function(x, ...) {
	"selected"
}

## Method: list ####
method(arg_name_input_value, class_list) <- function(x, ...) {
	s7_check_is_valid_list_dispatch(x, function_name = "arg_name_input_value")
	"selected"
}

## Method: numeric ####
method(arg_name_input_value, class_numeric) <- function(x, ...) {
	"value"
}

## Method: POSIXt ####
method(arg_name_input_value, class_POSIXt) <- function(x, ...) {
	arg_name_input_value(x = as.Date(x), ...)
}
