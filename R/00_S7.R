# R/00_S7.R
#
# For valid S7 method registration, S7 classes need to be defined first

# S3 classes ####

## quosure ####
class_quosure <- new_S3_class(
	class = "quosure",
	constructor = function(.data) NULL
)

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

## shinyfilters_id
class_shinyfilters_id <- new_S3_class(
	class = "shinyfilters_id",
	constructor = function(.data) NULL
)

# FilterConfig ####

## Property (template): *_args ####
prop_args <- function(name, required) {
	new_property(
		class = class_list,
		validator = function(value) {
			if (!all(required %in% names(value))) {
				return(sprintf(
					"Missing list elements from @%s:\n* `%s`",
					name,
					paste0(setdiff(required, names(value)), collapse = "`\n* `")
				))
			}

			if (any(names(value) == "")) {
				return(sprintf("All elements of @%s must be named", name))
			}

			if (!identical(length(value), length(unique(names(value))))) {
				return(sprintf("All names of @%s must be unique", name))
			}
		}
	)
}

## Property: ns ####
prop_ns <- new_property(
	NULL | class_function,
	validator = function(value) {
		if (!is.null(value) && !._is_valid_ns_function(value)) {
			return(ERROR_MESSAGE_INVALID_NS)
		}
	}
)

## Class ####
FilterConfig <- new_class(
	"FilterConfig",
	properties = list(
		data = class_data.frame,
		dispatch_args = prop_args(
			"dispatch_args",
			c(DISPATCH_KEYWORDS, ARGUMENT_KEYWORDS)
		),
		ns = prop_ns,
		filter_overrides = class_list
	)
)
