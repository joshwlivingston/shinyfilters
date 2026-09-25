# R/00_S7.R
#
# For valid S7 method registration, S7 classes need to be defined first

# S3 classes ####

## reactivevalues ####
class_reactivevalues <- new_S3_class(
	class = "reactivevalues",
	constructor = function(.data) NULL
)

## reactiveExpr ####
class_reactiveExpr <- new_S3_class(
	class = "reactiveExpr",
	constructor = function(.data) NULL
)

# Input keywords ####
#
# Keywords accepted by `with_filter()`. `args` are the `filterInput()` flags the
# keyword sets; `fn` is the matching shiny input.
INPUT_KEYWORDS <- list(
	area = list(args = list(textbox = TRUE, area = TRUE), fn = textAreaInput),
	radio = list(args = list(radio = TRUE), fn = radioButtons),
	range = list(args = list(range = TRUE), fn = dateRangeInput),
	selectize = list(args = list(selectize = TRUE), fn = selectizeInput),
	slider = list(args = list(slider = TRUE), fn = sliderInput),
	textbox = list(args = list(textbox = TRUE), fn = textInput)
)

input_keyword <- function(keyword) {
	structure(
		keyword,
		class = c(paste0("shinyfilters_input_", keyword), "shinyfilters_input")
	)
}

class_input_keyword <- new_S3_class("shinyfilters_input")
class_input_area <- new_S3_class("shinyfilters_input_area")
class_input_radio <- new_S3_class("shinyfilters_input_radio")
class_input_range <- new_S3_class("shinyfilters_input_range")
class_input_selectize <- new_S3_class("shinyfilters_input_selectize")
class_input_slider <- new_S3_class("shinyfilters_input_slider")
class_input_textbox <- new_S3_class("shinyfilters_input_textbox")

# shinyfilters ####

## Property: args ####
prop_args <- new_property(
	class = class_list,
	validator = function(value) {
		if (length(value) == 0) {
			return(NULL)
		}
		if (is.null(names(value)) || any(names(value) == "")) {
			return("must have all elements named")
		}
		if (anyDuplicated(names(value))) {
			return("must have unique names")
		}
	}
)

## Property: ns ####
prop_ns <- new_property(
	NULL | class_function,
	validator = function(value) {
		if (!is.null(value) && !._is_valid_ns_function(value)) {
			return("must be the result of calling `shiny::NS()`")
		}
	}
)

## Class ####
class_shinyfilters <- new_class(
	"shinyfilters",
	properties = list(
		data = class_data.frame,
		args = prop_args,
		ns = prop_ns,
		overrides = class_list
	)
)
