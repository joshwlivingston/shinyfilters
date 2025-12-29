# Generic: arg_name_input_label ####
arg_name_input_label <- new_generic(
	name = "arg_name_input_label",
	dispatch_args = c("x")
)

## Method: character | Date | factor | logical | list | numeric | POSIXt ####
method(
	arg_name_input_label,
	class_character |
		class_Date |
		class_factor |
		class_logical |
		class_list |
		class_numeric |
		class_POSIXt
) <- function(x, ...) {
	"label"
}

## Method: data.frame ####
method(arg_name_input_label, class_data.frame) <- function(x, ...) {
	stop("`arg_name_input_label()` is not implemented for data.frames.")
}
