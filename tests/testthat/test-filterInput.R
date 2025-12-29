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
expect_all_na_error <- function(x) {
	expect_error(filterInput(x = x))
}
test_that("filterInput() throws error when supplied vector is all NA", {
	expect_all_na_error(choices_chr_na)
	expect_all_na_error(choices_cpx_na)
	expect_all_na_error(choices_rel_na)
	expect_all_na_error(choices_int_na)
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
### logical ####

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
