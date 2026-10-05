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
	date = list(args = list(), fn = dateInput),
	numeric = list(args = list(), fn = numericInput),
	radio = list(args = list(radio = TRUE), fn = radioButtons),
	range = list(args = list(range = TRUE), fn = dateRangeInput),
	select = list(args = list(), fn = selectInput),
	selectize = list(args = list(selectize = TRUE), fn = selectizeInput),
	slider = list(args = list(slider = TRUE), fn = sliderInput),
	textbox = list(args = list(textbox = TRUE), fn = textInput)
)

# The `filterInput()` flags. A keyword for a default input sets none.
INPUT_FLAGS <- unique(unlist(
	lapply(INPUT_KEYWORDS, function(keyword) names(keyword$args)),
	use.names = FALSE
))

input_keyword <- function(keyword) {
	structure(
		keyword,
		class = c(paste0("shinyfilters_input_", keyword), "shinyfilters_input")
	)
}

class_input_keyword <- new_S3_class("shinyfilters_input")
class_input_area <- new_S3_class("shinyfilters_input_area")
class_input_date <- new_S3_class("shinyfilters_input_date")
class_input_numeric <- new_S3_class("shinyfilters_input_numeric")
class_input_radio <- new_S3_class("shinyfilters_input_radio")
class_input_range <- new_S3_class("shinyfilters_input_range")
class_input_select <- new_S3_class("shinyfilters_input_select")
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
		data = new_property(
			class = class_data.frame,
			setter = function(self, value) {
				if (!the$allowed) {
					cli_abort("@data is read-only")
				}
				self@data <- value
				self
			},
			getter = function(self) {
				return(self@data)
			}
		),
		args = new_property(
			class = class_list,
			setter = function(self, value) {
				if (!the$allowed) {
					cli_abort("Use `{.topic with_defaults}` to set @args")
				}
				self@args <- value
				self
			}
		),
		ns = new_property(
			class = class_any,
			setter = function(self, value) {
				if (!the$allowed) {
					cli_abort("Use `{.topic with_ns}` to set @ns")
				}
				self@ns <- value
				self
			}
		),
		overrides = new_property(
			class = class_list,
			setter = function(self, value) {
				if (!the$allowed) {
					cli_abort(c(
						"@overrides is only allowed to be modified internally.",
						"i" = "See `{.topic with_filter}` for the user-facing function."
					))
				}
				self@overrides <- value
				self
			}
		),
		added = new_property(
			class = class_character,
			setter = function(self, value) {
				if (!the$allowed) {
					cli_abort(c(
						"@added is only allowed to be modified internally.",
						"i" = "See `{.topic with_filter}` for the user-facing function."
					))
				}
				self@added <- value
				self
			}
		),
		replaced = new_property(
			class = class_character,
			setter = function(self, value) {
				if (!the$allowed) {
					cli_abort(c(
						"@replaced is only allowed to be modified internally.",
						"i" = "See `{.topic with_filter}` for the user-facing function."
					))
				}
				self@replaced <- value
				self
			}
		)
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
		if (is.function(self@ns) && !._is_valid_ns_function(self@ns)) {
			return("must be created using shiny::NS()")
		}
	}
)
