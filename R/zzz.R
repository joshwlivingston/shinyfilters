DISPATCH_KEYWORDS <- NULL
TRANSFORMS <- NULL
TRANSFORMS_BY_FUN <- NULL
ARGUMENT_KEYWORDS <- NULL

.onLoad <- function(libname, pkgname) {
	methods_register()

	DISPATCH_KEYWORDS <<- setNames(
		nm = c(
			"area",
			"radio",
			"range",
			"selecitze",
			"slider",
			"textbox"
		)
	)

	TRANSFORMS_BY_FUN <<-
		setNames(
			list(
				function(x) to_chr(x), # textAreaInput
				function(x) to_chr(x), # radioButtons
				function(x) as.Date(x), # dateRangeInput
				function(x) to_chr(x), # selectizeInput
				function(x) to_dbl(x), # sliderInput
				function(x) to_chr(x) # textInput
			),
			c(
				obj_address(textAreaInput),
				obj_address(radioButtons),
				obj_address(dateRangeInput),
				obj_address(selectizeInput),
				obj_address(sliderInput),
				obj_address(textInput)
			)
		)

	TRANSFORMS <<- list(
		"area" = as_character,
		"radio" = as_character,
		"range" = function(x) as.Date(x),
		"selecitze" = as_character,
		"slider" = as_numeric,
		"textbox" = as_character
	)

	ARGUMENT_KEYWORDS <<- c(
		"choices_asis",
		"args_unique",
		"args_sort"
	)
}
