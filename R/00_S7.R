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
# Keywords accepted by `with_filters()`. `args` are the `filterInput()` flags the
# keyword sets; `fn` names the matching shiny input.
INPUT_KEYWORDS <- list(
	area = list(args = list(textbox = TRUE, area = TRUE), fn = "textAreaInput"),
	date = list(args = list(), fn = "dateInput"),
	numeric = list(args = list(), fn = "numericInput"),
	radio = list(args = list(radio = TRUE), fn = "radioButtons"),
	range = list(args = list(range = TRUE), fn = "dateRangeInput"),
	select = list(args = list(), fn = "selectInput"),
	selectize = list(args = list(selectize = TRUE), fn = "selectizeInput"),
	slider = list(args = list(slider = TRUE), fn = "sliderInput"),
	textbox = list(args = list(textbox = TRUE), fn = "textInput")
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

# The shiny input a keyword stands for
._keyword_fn <- function(keyword) {
	._shiny_inputs()[[INPUT_KEYWORDS[[unclass(keyword)]]$fn]]
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

## Sealing ####
#
# A shinyfilters object is sealed once it is built: its setters refuse a sealed
# object, so a change builds a new one with `._modify()`. The seal is on the
# object, not in the package, so an object made before the package is reloaded
# behaves like any other.
._is_sealed <- function(x) {
	isTRUE(attr(x, "sealed", exact = TRUE))
}

._seal <- function(x) {
	attr(x, "sealed") <- TRUE
	x
}

## Class ####

#' shinyfilters objects
#'
#' A `shinyfilters` object holds a data frame and the input each of its
#' columns gets in a \pkg{shiny} app. [shinyfilters()] creates one. To modify
#' one, use [with_filters()], [with_defaults()], or [with_ns()].
#'
#' # Printing
#'
#' Printing shows the input each column gets:
#'
#' ```r
#' library(shinyfilters)
#'
#' filters <- shinyfilters(nyc_flights)
#' filters
#' #> <shinyfilters> • 7 filters
#' #>
#' #> Filters
#' #>   date       <date>  dateRangeInput
#' #>   carrier    <chr>   selectizeInput
#' #>   origin     <fct>   selectizeInput
#' #>   dest       <chr>   selectizeInput
#' #>   dep_delay  <dbl>   sliderInput
#' #>   distance   <dbl>   sliderInput
#' #>   delayed    <lgl>   selectizeInput
#' ```
#'
#' # Columns
#'
#' The columns of the data are the object's filters. `names(x)` lists them,
#' `dim(x)`, `nrow(x)`, and `ncol(x)` describe the data, and
#' `as.data.frame(x)` returns it.
#'
#' * `x$col` creates the input for one column, named exactly.
#' * `x[[cols]]` creates the inputs for the selected columns. One column gives
#'   the input itself, as `$` does; several give a [shiny::tagList()] in the
#'   order selected.
#' * `x[cols]` returns a `shinyfilters` object with only the selected columns,
#'   in the order selected. They keep their inputs, arguments, and markers,
#'   and the object keeps its defaults and namespace.
#'
#' `$` and `[[` create the inputs [filterInput()] creates for those columns,
#' with the object's defaults, namespace, and [with_filters()] choices applied.
#'
#' `cols` uses <[`tidy-select`][tidyselect::language]> in both `[` and `[[`:
#' bare names, strings, positions, `c()`, `!`, and helpers such as
#' `starts_with()`. Use `all_of()` to select with a character vector stored in
#' a variable. A selection must match at least one column, and neither
#' operator takes rows.
#'
#' [dplyr::select()] works like `[`, and [dplyr::pull()] like `$`; see
#' [shinyfilters-dplyr].
#'
#' Assigning with `$<-`, `[[<-`, or `@<-` is an error.
#'
#' # In an app
#'
#' Place the object in a UI like any tag. It creates its inputs when the page
#' is rendered, as `filterInput(x)` does: one input per column, in column
#' order. An input's id is its column's name, prefixed with the namespace.
#' Place `x[cols]` to put some of the filters in one part of the page.
#'
#' `$`, `[[`, and [filterInput()] create the inputs right away instead. Two
#' cases need them:
#'
#' * A UI function that inspects its contents before the page is rendered,
#'   such as `bslib::accordion()`, errors when given the object. Give it
#'   `x[[cols]]`.
#' * An app with bookmarking enabled errors when the object is placed in its
#'   UI, because inputs created when the page is rendered don't restore their
#'   bookmarked values. Create the inputs inside the UI function. Inside a
#'   session, such as in [shiny::renderUI()], the object works as it is.
#'
#' In the server, pass the object to [shinyfilters_server()]. It keeps each
#' input's choices in line with the other filters, and returns the filtered
#' data.
#'
#' @seealso [shinyfilters()] to create one; [with_filters()],
#'   [with_defaults()], and [with_ns()] to change one; [shinyfilters-dplyr]
#'   for the dplyr verbs.
#'
#' @name shinyfilters-class
#' @examples
#' filters <- shinyfilters(nyc_flights)
#' filters <- with_filters(filters, origin = "radio")
#' filters
#'
#' names(filters)
#'
#' # Some of the filters
#' filters[c(origin, dest)]
#' filters[starts_with("d")]
#'
#' # The input for one column
#' filters$origin
#'
#' # The inputs for several columns
#' filters[[c(origin, delayed)]]
#'
#' if (interactive()) {
#'   library(shiny)
#'
#'   ui <- fluidPage(
#'     sidebarLayout(
#'       sidebarPanel(
#'         wellPanel(filters[c(date, origin)]),
#'         filters[!c(date, origin)]
#'       ),
#'       mainPanel(verbatimTextOutput("flights"))
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     res <- shinyfilters_server(filters)
#'     output$flights <- renderPrint(res$filtered)
#'   }
#'
#'   shinyApp(ui, server)
#' }
NULL

class_shinyfilters <- new_class(
	"shinyfilters",
	package = "shinyfilters",
	properties = list(
		data = new_property(
			class = class_data.frame,
			setter = function(self, value) {
				if (._is_sealed(self)) {
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
				if (._is_sealed(self)) {
					cli_abort("Use {.topic with_defaults} to set @args")
				}
				self@args <- value
				self
			}
		),
		ns = new_property(
			class = class_any,
			setter = function(self, value) {
				if (._is_sealed(self)) {
					cli_abort("Use {.topic with_ns} to set @ns")
				}
				self@ns <- value
				self
			}
		),
		overrides = new_property(
			class = class_list,
			setter = function(self, value) {
				if (._is_sealed(self)) {
					cli_abort(c(
						"@overrides is only allowed to be modified internally.",
						"i" = "See {.topic with_filters} for the user-facing function."
					))
				}
				self@overrides <- value
				self
			}
		),
		added = new_property(
			class = class_character,
			setter = function(self, value) {
				if (._is_sealed(self)) {
					cli_abort(c(
						"@added is only allowed to be modified internally.",
						"i" = "See {.topic with_filters} for the user-facing function."
					))
				}
				self@added <- value
				self
			}
		),
		replaced = new_property(
			class = class_character,
			setter = function(self, value) {
				if (._is_sealed(self)) {
					cli_abort(c(
						"@replaced is only allowed to be modified internally.",
						"i" = "See {.topic with_filters} for the user-facing function."
					))
				}
				self@replaced <- value
				self
			}
		)
	),
	constructor = function(
		data,
		args = list(),
		ns = NULL,
		overrides = list(),
		added = character(),
		replaced = character()
	) {
		._private()
		# Not `._seal(new_object(...))`: `new_object()` finds the class through
		# the function that called it.
		object <- new_object(
			S7_object(),
			data = data,
			args = args,
			ns = ns,
			overrides = overrides,
			added = added,
			replaced = replaced
		)
		._seal(object)
	},
	validator = function(self) {
		# properties are validated in the class validation to support S7 < 0.2.0

		# args
		if (length(self@args) != 0) {
			if (is.null(names(self@args)) || any(names(self@args) == "")) {
				return("@args must have all elements named")
			}
			if (anyDuplicated(names(self@args))) {
				return("@args must have unique names")
			}
		}

		# ns
		if (is.function(self@ns) && !._is_valid_ns_function(self@ns)) {
			return("@ns must be created using shiny::NS()")
		}
	}
)

## Modify ####
# A copy of `config` with some of its properties replaced. `ns = NULL` removes
# the namespace.
._modify <- function(
	config,
	data = config@data,
	args = config@args,
	ns = config@ns,
	overrides = config@overrides,
	added = config@added,
	replaced = config@replaced
) {
	._private()
	class_shinyfilters(
		data = data,
		args = args,
		ns = ns,
		overrides = overrides,
		added = added,
		replaced = replaced
	)
}
