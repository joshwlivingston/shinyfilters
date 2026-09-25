# arg_name_input_id() ####
test_that("arg_name_input_id() returns 'inputId' for all types", {
	expect_identical(arg_name_input_id("a"), "inputId")
	expect_identical(arg_name_input_id(1), "inputId")
	expect_identical(arg_name_input_id(Sys.Date()), "inputId")
	expect_identical(arg_name_input_id(Sys.time()), "inputId")
	expect_identical(arg_name_input_id(factor("a")), "inputId")
	expect_identical(arg_name_input_id(TRUE), "inputId")
	expect_identical(arg_name_input_id(list(a = 1)), "inputId")
})

# arg_name_input_label() ####
test_that("arg_name_input_label() returns 'label' for all types", {
	expect_identical(arg_name_input_label("a"), "label")
	expect_identical(arg_name_input_label(1), "label")
	expect_identical(arg_name_input_label(Sys.Date()), "label")
	expect_identical(arg_name_input_label(Sys.time()), "label")
	expect_identical(arg_name_input_label(factor("a")), "label")
	expect_identical(arg_name_input_label(TRUE), "label")
	expect_identical(arg_name_input_label(list(a = 1)), "label")
})

# arg_name_input_value() ####
## character ####
test_that("arg_name_input_value() returns 'selected' for character by default", {
	expect_identical(arg_name_input_value("a"), "selected")
})

test_that("arg_name_input_value() with textbox = FALSE returns 'selected' for character", {
	expect_identical(arg_name_input_value("a", textbox = FALSE), "selected")
})

test_that("arg_name_input_value() with textbox = TRUE returns 'value' for character", {
	expect_identical(arg_name_input_value("a", textbox = TRUE), "value")
})

## numeric ####
test_that("arg_name_input_value() returns 'value' for numeric", {
	expect_identical(arg_name_input_value(1), "value")
})

## Date ####
test_that("arg_name_input_value() returns 'value' for Date by default", {
	expect_identical(arg_name_input_value(Sys.Date()), "value")
})

test_that("arg_name_input_value() with range = TRUE returns c('start', 'end') for Date", {
	expect_identical(
		arg_name_input_value(Sys.Date(), range = TRUE),
		c("start", "end")
	)
})

## POSIXt ####
test_that("arg_name_input_value() returns 'value' for POSIXt by default", {
	expect_identical(arg_name_input_value(Sys.time()), "value")
})

test_that("arg_name_input_value() with range = TRUE returns c('start', 'end') for POSIXt", {
	expect_identical(
		arg_name_input_value(Sys.time(), range = TRUE),
		c("start", "end")
	)
})

## factor ####
test_that("arg_name_input_value() returns 'selected' for factor", {
	expect_identical(arg_name_input_value(factor("a")), "selected")
})

## logical ####
test_that("arg_name_input_value() returns 'selected' for logical", {
	expect_identical(arg_name_input_value(TRUE), "selected")
})

## list ####
test_that("arg_name_input_value() returns 'selected' for list", {
	expect_identical(arg_name_input_value(list(a = 1)), "selected")
})

## data.frame ####
test_that("arg_name_input_value() returns list with 'selected' for character columns", {
	df <- data.frame(col1 = c("a", "b"), col2 = c("x", "y"))
	result <- arg_name_input_value(df)
	expected <- list(col1 = "selected", col2 = "selected")
	expect_identical(result, expected)
})

test_that("arg_name_input_value() returns list with 'value' for numeric columns", {
	df <- data.frame(col1 = 1:3, col2 = 4:6)
	result <- arg_name_input_value(df)
	expected <- list(col1 = "value", col2 = "value")
	expect_identical(result, expected)
})

test_that("arg_name_input_value() returns list with mixed types for data.frame", {
	df <- data.frame(
		chr_col = c("a", "b"),
		num_col = c(1, 2),
		fct_col = factor(c("x", "y")),
		dte_col = as.Date(c("2020-01-01", "2020-01-02"))
	)
	result <- arg_name_input_value(df)
	expected <- list(
		chr_col = "selected",
		num_col = "value",
		fct_col = "selected",
		dte_col = "value"
	)
	expect_identical(result, expected)
})

# Errors ####
### invalid implementation ####
#### returns NULL ####
test_that("arg_name_input_id: implementation returns NULL", {
	method(arg_name_input_id, ClassCharacter) <- function(x) NULL
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule"))
	})
})
