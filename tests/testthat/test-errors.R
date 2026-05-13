# apply_filters ####
test_that("apply_filters: unknown filter_combine_method", {
	expect_error(
		apply_filters(
			test_df,
			list(chr_col = "i"),
			filter_combine_method = "unk"
		),
		'Unknown `filter_combine_method` value: unk'
	)
})

test_that("apply_filters: filter_combine_method must be function", {
	expect_error(
		apply_filters(
			test_df,
			list(chr_col = "i"),
			filter_combine_method = 123
		),
		"Argument `filter_combine_method` must be a function\\."
	)
})

# arg_name_input_id ####
## invalid implementation ####
### returns NULL ####
test_that("arg_name_input_id: implementation returns NULL", {
	method(arg_name_input_id, ClassCharacter) <- function(x) NULL
	expect_error(
		filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule")),
		"The result of `arg_name_input_id\\(x\\)` cannot be `NULL` when `ns` is provided"
	)
})

# args_filter_input ####
## invalid args_* provided ####
test_that("args_filter_input validates args_unique must be list", {
	expect_error(
		args_filter_input(choices_chr, args_unique = "not_a_list"),
		"Supplied arguments must be a list\\."
	)
})

test_that("args_filter_input validates args_sort must be list", {
	expect_error(
		args_filter_input(choices_chr, args_sort = "not_a_list"),
		"Supplied arguments must be a list\\."
	)
})

test_that("args_filter_input validates args_unique list is named", {
	lst <- list(1, b = 2)
	expect_error(
		args_filter_input(choices_chr, args_unique = lst),
		"All supplied arguments must be named\\."
	)
})

test_that("args_filter_input validates args_sort list is named", {
	lst <- list(1, b = 2)
	expect_error(
		args_filter_input(choices_chr, args_sort = lst),
		"All supplied arguments must be named\\."
	)
})

test_that("args_filter_input validates args_unique names are unique", {
	lst <- list(a = 1, b = 2)
	names(lst) <- c("a", "a")
	expect_error(
		args_filter_input(choices_chr, args_unique = lst),
		"All argument names must be unique\\."
	)
})

test_that("args_filter_input validates args_sort names are unique", {
	lst <- list(a = 1, b = 2)
	names(lst) <- c("a", "a")
	expect_error(
		args_filter_input(choices_chr, args_sort = lst),
		"All argument names must be unique\\."
	)
})

## invalid choices_asis provided ####
test_that("args_filter_input: choices_asis must be TRUE for list", {
	expect_error(
		args_filter_input(choices_lst, choices_asis = FALSE),
		"Argument `choices_asis` must be TRUE when `x` is a list\\."
	)
})

## invalid extension implemented ####
### not a list
test_that("args_filter_input: extension does not return list", {
	method(args_filter_input, ClassCharacter) <- function(x) "not a list"
	expect_error(
		filterInput(ClassCharacter(letters)),
		"Value must be a NULL or a list."
	)
})

### list is not named
test_that("args_filter_input: extension does not return named list", {
	method(args_filter_input, ClassCharacter) <- function(x) list("not named")
	expect_error(
		filterInput(ClassCharacter(letters)),
		"All list elements must be named."
	)

	method(args_filter_input, ClassCharacter) <- function(x) {
		list("not named", named = "named")
	}
	expect_error(
		filterInput(ClassCharacter(letters)),
		"All list elements must be named."
	)
})

### list is not uniquely named
test_that("args_filter_input: extension does not return uniquely named list", {
	method(args_filter_input, ClassCharacter) <- function(x) {
		# jarl-ignore duplicated_arguments: testing for error
		list(entry = "a", entry = "b")
	}
	expect_error(
		filterInput(ClassCharacter(letters)),
		"All list names must be unique."
	)
})

# call_filter_input ####
test_that("call_filter_input errors for data.frames", {
	expect_error(
		call_filter_input(test_df, shiny::selectInput),
		"call_filter_input\\(\\) is not implemented for data\\.frames\\."
	)
})

# call_update_filter_input ####
test_that("call_update_filter_input errors for data.frames", {
	expect_error(
		call_update_filter_input(test_df, shiny::updateSelectInput),
		"call_update_filter_input\\(\\) is not implemented for data\\.frames\\."
	)
})

# get_filter_logical ####
## column nopt found
test_that("get_filter_logical: column not found", {
	expect_error(
		get_filter_logical(test_df, "i", column = "nonexistent"),
		"Column `nonexistent` not found in `x`\\."
	)
})

## invalid column_name argument ####
test_that("get_filter_logical: column argument is non-empty string", {
	expect_error(
		get_filter_logical(test_df, "i", column = NA_character_),
		"`column` must be a non-empty string"
	)

	expect_error(
		get_filter_logical(test_df, "i", column = ""),
		"`column` must be a non-empty string"
	)
})

## invalid implementation ####
### non-logical vector returned ####
test_that("get_filter_logical: non-logical vector returned", {
	method(get_filter_logical, list(ClassCharacter, class_character)) <- function(
		x,
		val
	) {
		integer(length(x))
	}
	df <- data.frame(x = ClassCharacter(letters))
	expect_error(
		apply_filters(df, list(x = letters[1:5])),
		"Filter on column `x` did not return a logical vector."
	)
})

### logical vector of invalid length returned ####
test_that("get_filter_logical: logical vector of invalid length", {
	method(get_filter_logical, list(ClassCharacter, class_character)) <- function(
		x,
		val
	) {
		logical(length(x) - 1L)
	}
	df <- data.frame(x = ClassCharacter(letters))
	expect_error(
		apply_filters(df, list(x = letters[1:5])),
		"Filter on column `x` returned a logical vector of length 25, but expected length 26."
	)
})

# filterInput ####
## `radio` and `selectize` both TRUE ####
test_that("filterInput: radio and selectize cannot both be TRUE", {
	expect_error(
		filterInput(
			choices_chr,
			inputId = "test",
			label = "Label",
			radio = TRUE,
			selectize = TRUE
		),
		"Arguments `radio` and `selectize` cannot both be TRUE\\."
	)
})

## S7 method not found ####
test_that("filterInput: method not found for S7 object passed as list", {
	obj <- ClassList(as.list(letters))
	expect_error(
		filterInput(obj),
		"No method found for `filterInput\\(\\)` for class `ClassList`\\."
	)
})

## argument supplied that is provided by args_filter_input() ####
test_that("filterInput: arg supplied that is provided by args_filter_input()", {
	expect_error(
		filterInput(letters, choices = letters),
		"The argument `choices` is not supported in when used with `character` objects."
	)

	expect_error(
		filterInput(choices_dte, min = min(choices_dte)),
		"The arguments\n( )+- `min`\n( )+- `max`\n( )+- `value`\nare not supported in when used with `Date` objects."
	)
})

# `ns` ####
test_that("ns must be result of shiny::NS()", {
	expect_error(
		filterInput(
			x = choices_chr,
			inputId = "my_input",
			label = "Label",
			ns = function(x) x
		),
		"`ns` must be the result of calling `shiny::NS\\(\\)`"
	)
})

test_that("ns requires inputId argument", {
	ns <- shiny::NS("mymodule")
	expect_error(
		filterInput(
			x = choices_chr,
			label = "Label",
			ns = ns
		),
		"Argument `inputId` is required when `ns` is provided"
	)
})

# serverFilterInput ####
test_that("serverFilterInput() with reactive() throws error when missing required columns", {
	skip_on_ci()
	skip_on_cran()
	expect_error(
		AppDriver$new(
			load_timeout = 1000L,
			shinyApp(
				ui = fluidPage(
					sidebarLayout(
						sidebarPanel(
							filterInput(test_df)
						),
						mainPanel()
					)
				),
				server = function(input, output, session) {
					input_list <- reactive({
						list(
							chr_col = "a",
							num_col = 5
						)
					})
					serverFilterInput(test_df, input = input_list)
				}
			)
		),
		"Missing required input values: `chr_col_radio`, `chr_col_selectize`, `chr_col_textarea`, `chr_col_text`, `dte_col`, `dte_col_date_range`, `fct_col`, `log_col`, `num_col_slider`, `psc_col`, `psl_col`"
	)
})

test_that("serverFilterInput() with reactive() warns when extra columns provided", {
	app <- AppDriver$new(
		app = shinyApp(
			ui = fluidPage(
				sidebarLayout(
					sidebarPanel(
						filterInput(test_df)
					),
					mainPanel()
				)
			),
			server = function(input, output, session) {
				input_list <- reactive({
					out <- vector("list", ncol(test_df))
					names(out) <- get_input_ids(test_df)
					out <- c(out, list(unsupported = "x"))
				})
				serverFilterInput(test_df, input = input_list)
			}
		)
	)
	# Get the app's logs which contain warnings
	logs <- app$get_logs()

	app$stop()

	# Check that the warning message appears in the logs
	expect_true(
		any(grepl(
			"Ignoring unsupported input values: `unsupported`",
			logs,
			fixed = TRUE
		))
	)
})

# updateFilterInput ####
test_that("updateFilterInput: radio and selectize cannot both be TRUE", {
	expect_error(
		updateFilterInput(
			choices_chr,
			inputId = "test",
			radio = TRUE,
			selectize = TRUE
		),
		"Arguments `radio` and `selectize` cannot both be TRUE\\."
	)
})
