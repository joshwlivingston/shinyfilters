# Generic: arg_name_input_id ####
arg_name_input_id <- new_generic(
	name = "arg_name_input_id",
	dispatch_args = c("x")
)

## Method: character | Date | factor | logical | list | numeric | POSIXt ####
method(
	arg_name_input_id,
	class_character |
		class_Date |
		class_factor |
		class_logical |
		class_list |
		class_numeric |
		class_POSIXt
) <- function(x, ...) {
	"inputId"
}

## Method: data.frame ####
method(arg_name_input_id, class_data.frame) <- function(x, ...) {
	stop("`arg_name_input_id()` is not implemented for data.frames.")
}
