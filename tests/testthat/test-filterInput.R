# tests/testthat/test-filterInput.R

# Helpers ####
expect_shiny_input <- function(shiny_input) {
	function(...) {
		args <- list(...)
		res_shinyfilters <- do.call(filterInput, args)
		args_get_filter_input <- args
		if (is.character(args$x)) {
			args_get_filter_input$textbox <- FALSE
		}
		args_shiny <- c(
			do.call(args_filter_input, args_get_filter_input),
			args[names(args) != "x"]
		)
		args_allowed <- formalArgs(shiny_input)
		if (identical(shiny_input, shiny::selectizeInput)) {
			args_allowed_all <- union(
				args_allowed,
				formalArgs(shiny::selectInput)
			)
			args_in_select_only <- c("selectize")
			args_allowed <- setdiff(args_allowed_all, args_in_select_only)
		}
		args_shiny <- args_shiny[names(args_shiny) %in% args_allowed]
		res_shiny <- do.call(shiny_input, args_shiny)

		expect_identical(res_shinyfilters, res_shiny)
	}
}

expect_shiny_selectInput <- expect_shiny_input(shiny::selectInput)
expect_shiny_selectizeInput <- expect_shiny_input(shiny::selectizeInput)
expect_shiny_textInput <- expect_shiny_input(shiny::textInput)
expect_shiny_textAreaInput <- expect_shiny_input(shiny::textAreaInput)
expect_shiny_radioButtons <- expect_shiny_input(shiny::radioButtons)
expect_shiny_numericInput <- expect_shiny_input(shiny::numericInput)
expect_shiny_sliderInput <- expect_shiny_input(shiny::sliderInput)
expect_shiny_dateRangeInput <- expect_shiny_input(shiny::dateRangeInput)
expect_shiny_dateInput <- expect_shiny_input(shiny::dateInput)

# Logical Paths ####

## All NA's
test_that("filterInput() throws error when supplied vector is all NA", {
	expect_snapshot(error = TRUE, {
		filterInput(x = choices_chr_na, inputId = "", label = "")
		filterInput(x = choices_cpx_na, inputId = "", label = "")
		filterInput(x = choices_rel_na, inputId = "", label = "")
		filterInput(x = choices_int_na, inputId = "", label = "")
	})
})

## Select Input ####

### factor + `selectize` not provided ####
test_that("factor, default settings -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_fct,
		inputId = "",
		label = ""
	)
})

### list + `selectize` not provided ####
test_that("list, default settings -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_lst,
		inputId = "",
		label = ""
	)
})

### logical + `selectize` not provided ####
test_that("logical, default settings -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_log,
		inputId = "",
		label = ""
	)
})


### factor + `selectize = FALSE` ####
test_that("factor, selectize = FALSE -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_fct,
		inputId = "",
		label = "",
		selectize = FALSE
	)
})

### list + `selectize = FALSE` ####
test_that("list, selectize = FALSE -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_lst,
		inputId = "",
		label = "",
		selectize = FALSE
	)
})

### logical + `selectize = FALSE` ####
test_that("logical, selectize = FALSE -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_log,
		inputId = "",
		label = "",
		selectize = FALSE
	)
})

### character + `textbox` not provided + `selectize` not provided ####
test_that("character, defaults -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_chr,
		inputId = "",
		label = ""
	)
})

### character + `textbox` not provided + `selectize = FALSE` ####
test_that("character, selectize = FALSE -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_chr,
		inputId = "",
		label = "",
		selectize = FALSE
	)
})

### character + `textbox = FALSE` + `selectize` not provided ####
test_that("character, textbox = FALSE -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = FALSE
	)
})

### character + `textbox = FALSE` + `selectize = FALSE` ####
test_that("character, textbox = FALSE, selectize = FALSE -> shiny::selectInput", {
	expect_shiny_selectInput(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = FALSE,
		selectize = FALSE
	)
})

## Selectize Input ####

### factor or list + `selectize = TRUE` ####
test_that("factor + `selectize = TRUE` -> shiny::selectizeInput", {
	expect_shiny_selectizeInput(
		x = choices_fct,
		inputId = "",
		label = "",
		selectize = TRUE
	)
})

### list + `selectize = TRUE` ####
test_that("list + `selectize = TRUE` -> shiny::selectizeInput", {
	expect_shiny_selectizeInput(
		x = choices_lst,
		inputId = "",
		label = "",
		selectize = TRUE
	)
})

### logical + `selectize = TRUE` ####
test_that("logical + `selectize = TRUE` -> shiny::selectizeInput", {
	expect_shiny_selectizeInput(
		x = choices_log,
		inputId = "",
		label = "",
		selectize = TRUE
	)
})

### character + `textbox` not provided + `selectize = TRUE` ####
test_that("character + `textbox not provided` + `selectize = TRUE` -> shiny::selectizeInput", {
	expect_shiny_selectizeInput(
		x = choices_chr,
		inputId = "",
		label = "",
		selectize = TRUE
	)
})

### character + `textbox = FALSE` + `selectize = TRUE` ####
test_that("character + `textbox = FALSE` + `selectize = TRUE` -> shiny::selectizeInput", {
	expect_shiny_selectizeInput(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = FALSE,
		selectize = TRUE
	)
})

## Text Input ####
### character + `textbox = TRUE` + `area` not provided ####
test_that("character + `textbox = TRUE` + `area` not provided -> shiny::textInput", {
	expect_shiny_textInput(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = TRUE
	)
})

### character + `textbox = TRUE` + `area = FALSE` ####
test_that("character + `textbox = TRUE` + `area = FALSE` -> shiny::textInput", {
	expect_shiny_textInput(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = TRUE,
		area = FALSE
	)
})

## Text Area Input ####
### character + `textbox = TRUE` + `area = TRUE` ####
test_that("character + `textbox = TRUE` + `area = TRUE` -> shiny::textAreaInput", {
	expect_shiny_textAreaInput(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = TRUE,
		area = TRUE
	)
})

## Radio Buttons ####
### factor or list + `radio = TRUE` ####
test_that("factor + `radio = TRUE` -> shiny::radioButtons", {
	expect_shiny_radioButtons(
		x = choices_fct,
		inputId = "",
		label = "",
		radio = TRUE
	)
})

### list + `radio = TRUE` ####
test_that("list + `radio = TRUE` -> shiny::radioButtons", {
	expect_shiny_radioButtons(
		x = choices_lst,
		inputId = "",
		label = "",
		radio = TRUE
	)
})

### logical + `radio = TRUE` ####
test_that("logical + `radio = TRUE` -> shiny::radioButtons", {
	expect_shiny_radioButtons(
		x = choices_log,
		inputId = "",
		label = "",
		radio = TRUE
	)
})

### character + `textbox` not provided + `radio = TRUE` ####
test_that("character + `textbox not provided` + `radio = TRUE` -> shiny::radioButtons", {
	expect_shiny_radioButtons(
		x = choices_chr,
		inputId = "",
		label = "",
		radio = TRUE
	)
})

### character + `textbox = FALSE` + `radio = TRUE` ####
test_that("character + `textbox = FALSE` + `radio = TRUE` -> shiny::radioButtons", {
	expect_shiny_radioButtons(
		x = choices_chr,
		inputId = "",
		label = "",
		textbox = FALSE,
		radio = TRUE
	)
})

## Numeric Input ####
### numeric + `slider` not provided ####
test_that("numeric + `slider` not provided -> shiny::numericInput", {
	expect_shiny_numericInput(
		x = choices_num,
		inputId = "",
		label = ""
	)
})

### numeric + `slider = FALSE` ####
test_that("numeric + `slider = FALSE` -> shiny::numericInput", {
	expect_shiny_numericInput(
		x = choices_num,
		inputId = "",
		label = "",
		slider = FALSE
	)
})

## Slider Input ####
### numeric + `slider = TRUE` ####
test_that("numeric + `slider = TRUE` -> shiny::sliderInput", {
	expect_shiny_sliderInput(
		x = choices_num,
		inputId = "",
		label = "",
		slider = TRUE
	)
})

## Date Range Input ####
### Date ####
test_that("Date + `range = TRUE` -> shiny::dateRangeInput", {
	expect_shiny_dateRangeInput(
		x = choices_dte,
		inputId = "",
		label = "",
		range = TRUE
	)
})

### POSIXct ####
test_that("POSIXct + `range = TRUE` -> shiny::dateRangeInput", {
	expect_shiny_dateRangeInput(
		x = choices_psc,
		inputId = "",
		label = "",
		range = TRUE
	)
})

### POSIXlt ####
test_that("POSIXlt + `range = TRUE` -> shiny::dateRangeInput", {
	expect_shiny_dateRangeInput(
		x = choices_psl,
		inputId = "",
		label = "",
		range = TRUE
	)
})

## Date Input ####
### Date ####
test_that("Date + `range = FALSE` -> shiny::dateInput", {
	expect_shiny_dateInput(
		x = choices_dte,
		inputId = "",
		label = "",
		range = FALSE
	)
})

test_that("Date + `range` not provided -> shiny::dateInput", {
	expect_shiny_dateInput(
		x = choices_dte,
		inputId = "",
		label = ""
	)
})

### POSIXct ####
test_that("POSIXct + `range = FALSE` -> shiny::dateInput", {
	expect_shiny_dateInput(
		x = choices_psc,
		inputId = "",
		label = "",
		range = FALSE
	)
})

test_that("POSIXct + `range` not provided -> shiny::dateInput", {
	expect_shiny_dateInput(
		x = choices_psc,
		inputId = "",
		label = ""
	)
})

### POSIXlt ####
test_that("POSIXlt + `range = FALSE` -> shiny::dateInput", {
	expect_shiny_dateInput(
		x = choices_psl,
		inputId = "",
		label = "",
		range = FALSE
	)
})

test_that("POSIXlt + `range` not provided -> shiny::dateInput", {
	expect_shiny_dateInput(
		x = choices_psl,
		inputId = "",
		label = ""
	)
})

# data.frames ####

test_that("data.frame with mixed types returns htmltools::tagList", {
	res <- filterInput(test_df)
	expect_s3_class(res, "shiny.tag.list")
})

test_that("data.frame with mixed types creates correct number of inputs", {
	res <- filterInput(test_df)
	# Should have 4 inputs (one per column)
	expect_equal(length(res), ncol(test_df))
})

test_that("data.frame list has correct names", {
	res <- filterInput(test_df)
	# The names should match the column names
	expect_equal(names(res), get_input_ids(test_df))
})

test_that("data.frame chr_col (character) -> shiny::selectInput", {
	res <- filterInput(test_df)
	args_shiny_chr <- c(
		list(
			inputId = get_input_ids(test_df[, "chr_col", drop = FALSE]),
			label = get_input_labels(test_df[, "chr_col", drop = FALSE])
		),
		args_filter_input(test_df$chr_col)
	)
	expect_identical(
		res$chr_col,
		do.call(shiny::selectInput, args_shiny_chr)
	)
})

test_that("data.frame fct_col (factor) -> shiny::selectInput", {
	res <- filterInput(test_df)
	args_shiny_fct <- c(
		list(
			inputId = get_input_ids(test_df[, "fct_col", drop = FALSE]),
			label = get_input_labels(test_df[, "fct_col", drop = FALSE])
		),
		args_filter_input(test_df$fct_col)
	)
	expect_identical(
		res$fct_col,
		do.call(shiny::selectInput, args_shiny_fct)
	)
})

test_that("data.frame num_col (numeric) -> shiny::numericInput", {
	res <- filterInput(test_df)
	args_shiny_num <- c(
		list(
			inputId = get_input_ids(test_df[, "num_col", drop = FALSE]),
			label = get_input_labels(test_df[, "num_col", drop = FALSE])
		),
		args_filter_input(test_df$num_col)
	)
	expect_identical(
		res$num_col,
		do.call(shiny::numericInput, args_shiny_num)
	)
})

test_that("data.frame dte_col (Date) -> shiny::dateInput", {
	res <- filterInput(test_df)
	args_shiny_dte <- c(
		list(
			inputId = get_input_ids(test_df[, "dte_col", drop = FALSE]),
			label = get_input_labels(test_df[, "dte_col", drop = FALSE])
		),
		args_filter_input(test_df$dte_col)
	)
	expect_identical(
		res$dte_col,
		do.call(shiny::dateInput, args_shiny_dte)
	)
})

# ns argument ####

## Vector inputs with ns ####

test_that("character + ns -> shiny::selectInput with namespaced inputId", {
	ns <- shiny::NS("mymodule")
	res <- filterInput(
		x = choices_chr,
		inputId = "my_input",
		label = "Label",
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("my_input"),
			label = "Label"
		),
		args_filter_input(choices_chr)
	)
	expect_identical(res, do.call(shiny::selectInput, args_shiny))
})

test_that("factor + ns -> shiny::selectInput with namespaced inputId", {
	ns <- shiny::NS("test_module")
	res <- filterInput(
		x = choices_fct,
		inputId = "factor_input",
		label = "Select",
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("factor_input"),
			label = "Select"
		),
		args_filter_input(choices_fct)
	)
	expect_identical(res, do.call(shiny::selectInput, args_shiny))
})

test_that("logical + ns -> shiny::selectInput with namespaced inputId", {
	ns <- shiny::NS("logic_mod")
	res <- filterInput(
		x = choices_log,
		inputId = "logical_input",
		label = "Pick",
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("logical_input"),
			label = "Pick"
		),
		args_filter_input(choices_log)
	)
	expect_identical(res, do.call(shiny::selectInput, args_shiny))
})

test_that("numeric + ns -> shiny::numericInput with namespaced inputId", {
	ns <- shiny::NS("num_module")
	res <- filterInput(
		x = choices_num,
		inputId = "numeric_input",
		label = "Number",
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("numeric_input"),
			label = "Number"
		),
		args_filter_input(choices_num)
	)
	expect_identical(res, do.call(shiny::numericInput, args_shiny))
})

test_that("Date + ns -> shiny::dateInput with namespaced inputId", {
	ns <- shiny::NS("date_mod")
	res <- filterInput(
		x = choices_dte,
		inputId = "date_input",
		label = "Date",
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("date_input"),
			label = "Date"
		),
		args_filter_input(choices_dte)
	)
	expect_identical(res, do.call(shiny::dateInput, args_shiny))
})

test_that("character + textbox = TRUE + ns -> shiny::textInput with namespaced inputId", {
	ns <- shiny::NS("text_module")
	res <- filterInput(
		x = choices_chr,
		inputId = "text_input",
		label = "Text",
		textbox = TRUE,
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("text_input"),
			label = "Text"
		),
		args_filter_input(choices_chr, textbox = TRUE)
	)
	expect_identical(res, do.call(shiny::textInput, args_shiny))
})

test_that("character + textbox = TRUE + area = TRUE + ns -> shiny::textAreaInput with namespaced inputId", {
	ns <- shiny::NS("textarea_mod")
	res <- filterInput(
		x = choices_chr,
		inputId = "textarea_input",
		label = "Area",
		textbox = TRUE,
		area = TRUE,
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("textarea_input"),
			label = "Area"
		),
		args_filter_input(choices_chr, textbox = TRUE)
	)
	expect_identical(res, do.call(shiny::textAreaInput, args_shiny))
})

test_that("factor + radio = TRUE + ns -> shiny::radioButtons with namespaced inputId", {
	ns <- shiny::NS("radio_module")
	res <- filterInput(
		x = choices_fct,
		inputId = "radio_input",
		label = "Radio",
		radio = TRUE,
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("radio_input"),
			label = "Radio"
		),
		args_filter_input(choices_fct)
	)
	expect_identical(res, do.call(shiny::radioButtons, args_shiny))
})

test_that("factor + selectize = TRUE + ns -> shiny::selectizeInput with namespaced inputId", {
	ns <- shiny::NS("selectize_mod")
	res <- filterInput(
		x = choices_fct,
		inputId = "selectize_input",
		label = "Selectize",
		selectize = TRUE,
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("selectize_input"),
			label = "Selectize"
		),
		args_filter_input(choices_fct)
	)
	expect_identical(res, do.call(shiny::selectizeInput, args_shiny))
})

test_that("numeric + slider = TRUE + ns -> shiny::sliderInput with namespaced inputId", {
	ns <- shiny::NS("slider_mod")
	res <- filterInput(
		x = choices_num,
		inputId = "slider_input",
		label = "Slider",
		slider = TRUE,
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("slider_input"),
			label = "Slider"
		),
		args_filter_input(choices_num)
	)
	expect_identical(res, do.call(shiny::sliderInput, args_shiny))
})

test_that("Date + range = TRUE + ns -> shiny::dateRangeInput with namespaced inputId", {
	ns <- shiny::NS("daterange_mod")
	res <- filterInput(
		x = choices_dte,
		inputId = "daterange_input",
		label = "Date Range",
		range = TRUE,
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("daterange_input"),
			label = "Date Range"
		),
		args_filter_input(choices_dte, range = TRUE)
	)
	expect_identical(res, do.call(shiny::dateRangeInput, args_shiny))
})

test_that("list + ns -> shiny::selectInput with namespaced inputId", {
	ns <- shiny::NS("list_mod")
	res <- filterInput(
		x = choices_lst,
		inputId = "list_input",
		label = "List",
		ns = ns
	)
	args_shiny <- c(
		list(
			inputId = ns("list_input"),
			label = "List"
		),
		args_filter_input(choices_lst)
	)
	expect_identical(res, do.call(shiny::selectInput, args_shiny))
})

## data.frame with ns ####

test_that("data.frame chr_col (character) + ns -> shiny::selectInput with namespaced inputId", {
	ns <- shiny::NS("df_module")
	res <- filterInput(test_df, ns = ns)
	args_shiny_chr <- c(
		list(
			inputId = ns(get_input_ids(test_df[, "chr_col", drop = FALSE])),
			label = get_input_labels(test_df[, "chr_col", drop = FALSE])
		),
		args_filter_input(test_df$chr_col)
	)
	expect_identical(
		res$chr_col,
		do.call(shiny::selectInput, args_shiny_chr)
	)
})

test_that("data.frame fct_col (factor) + ns -> shiny::selectInput with namespaced inputId", {
	ns <- shiny::NS("df_module")
	res <- filterInput(test_df, ns = ns)
	args_shiny_fct <- c(
		list(
			inputId = ns(get_input_ids(test_df[, "fct_col", drop = FALSE])),
			label = get_input_labels(test_df[, "fct_col", drop = FALSE])
		),
		args_filter_input(test_df$fct_col)
	)
	expect_identical(
		res$fct_col,
		do.call(shiny::selectInput, args_shiny_fct)
	)
})

test_that("data.frame num_col (numeric) + ns -> shiny::numericInput with namespaced inputId", {
	ns <- shiny::NS("df_module")
	res <- filterInput(test_df, ns = ns)
	args_shiny_num <- c(
		list(
			inputId = ns(get_input_ids(test_df[, "num_col", drop = FALSE])),
			label = get_input_labels(test_df[, "num_col", drop = FALSE])
		),
		args_filter_input(test_df$num_col)
	)
	expect_identical(
		res$num_col,
		do.call(shiny::numericInput, args_shiny_num)
	)
})

test_that("data.frame dte_col (Date) + ns -> shiny::dateInput with namespaced inputId", {
	ns <- shiny::NS("df_module")
	res <- filterInput(test_df, ns = ns)
	args_shiny_dte <- c(
		list(
			inputId = ns(get_input_ids(test_df[, "dte_col", drop = FALSE])),
			label = get_input_labels(test_df[, "dte_col", drop = FALSE])
		),
		args_filter_input(test_df$dte_col)
	)
	expect_identical(
		res$dte_col,
		do.call(shiny::dateInput, args_shiny_dte)
	)
})

# Errors ####
## call_filter_input ####
test_that("call_filter_input errors for data.frames", {
	expect_snapshot(error = TRUE, {
		call_filter_input(test_df, shiny::selectInput)
	})
})

### `radio` and `selectize` both TRUE ####
test_that("filterInput: radio and selectize cannot both be TRUE", {
	expect_snapshot(error = TRUE, {
		filterInput(
			choices_chr,
			inputId = "test",
			label = "Label",
			radio = TRUE,
			selectize = TRUE
		)
	})
})

### S7 method not found ####
test_that("filterInput: method not found for S7 object passed as list", {
	obj <- ClassList(as.list(letters))
	expect_snapshot(error = TRUE, {
		filterInput(obj)
	})
})

### argument supplied that is provided by args_filter_input() ####
test_that("filterInput: arg supplied that is provided by args_filter_input()", {
	expect_snapshot(error = TRUE, {
		filterInput(letters, choices = letters)
		filterInput(choices_dte, min = min(choices_dte))
	})
})

## `ns` ####
test_that("ns must be result of shiny::NS()", {
	expect_snapshot(error = TRUE, {
		filterInput(
			x = choices_chr,
			inputId = "my_input",
			label = "Label",
			ns = function(x) x
		)
	})
})

test_that("ns requires inputId argument", {
	ns <- shiny::NS("mymodule")
	expect_snapshot(error = TRUE, {
		filterInput(
			x = choices_chr,
			label = "Label",
			ns = ns
		)
	})
})
