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

# POSIXt ####
class_POSIXt <- new_S3_class("POSIXt")

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

# NULL ####
# `class_NULL` rather than a bare `NULL`: S7's NEWS mentions `NULL` only for
# `method<-()` dispatch (0.2.0) and DESCRIPTION sets no S7 minimum, so the
# wrapper avoids relying on a bare `NULL` in a union. The constructor keeps the
# property defaulting to `NULL`, as the bare form did.
class_NULL <- new_S3_class("NULL", constructor = function(.data) NULL)

# shinyfilters ####

## Class ####
class_shinyfilters <- new_class(
	"shinyfilters",
	package = "shinyfilters",
	properties = list(
		data = class_data.frame,
		args = class_list,
		ns = class_NULL | class_function,
		overrides = class_list
	),
	validator = function(self) {
		# properties are validated in the class validation to support S7 < 0.2.0

		# args
		if (length(self@args) != 0) {
			if (is.null(names(self@args)) || any(names(self@args) == "")) {
				return("must have all elements named")
			}
			if (anyDuplicated(names(self@args))) {
				return("must have unique names")
			}
		}

		# ns
		if (!is.null(self@ns) && !._is_valid_ns_function(self@ns)) {
			return("must be the result of calling `shiny::NS()`")
		}
	}
)
