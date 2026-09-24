# apply_filters ####
test_that("apply_filters: unknown filter_combine_method", {
	expect_snapshot(error = TRUE, {
		apply_filters(
			test_df,
			list(chr_col = "i"),
			filter_combine_method = "unk"
		)
	})
})

test_that("apply_filters: filter_combine_method must be function", {
	expect_snapshot(error = TRUE, {
		apply_filters(
			test_df,
			list(chr_col = "i"),
			filter_combine_method = 123
		)
	})
})

# arg_name_input_id ####
## invalid implementation ####
### returns NULL ####
test_that("arg_name_input_id: implementation returns NULL", {
	method(arg_name_input_id, ClassCharacter) <- function(x) NULL
	expect_snapshot(error = TRUE, {
		filterInput(ClassCharacter(letters), ns = shiny::NS("mymodule"))
	})
})

# args_filter_input ####
## invalid args_* provided ####
test_that("args_filter_input validates args_unique must be list", {
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_chr, args_unique = "not_a_list")
	})
})

test_that("args_filter_input validates args_sort must be list", {
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_chr, args_sort = "not_a_list")
	})
})

test_that("args_filter_input validates args_unique list is named", {
	lst <- list(1, b = 2)
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_chr, args_unique = lst)
	})
})

test_that("args_filter_input validates args_sort list is named", {
	lst <- list(1, b = 2)
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_chr, args_sort = lst)
	})
})

test_that("args_filter_input validates args_unique names are unique", {
	lst <- list(a = 1, b = 2)
	names(lst) <- c("a", "a")
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_chr, args_unique = lst)
	})
})

test_that("args_filter_input validates args_sort names are unique", {
	lst <- list(a = 1, b = 2)
	names(lst) <- c("a", "a")
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_chr, args_sort = lst)
	})
})

## invalid choices_asis provided ####
test_that("args_filter_input: choices_asis must be TRUE for list", {
	expect_snapshot(error = TRUE, {
		args_filter_input(choices_lst, choices_asis = FALSE)
	})
})

## invalid extension implemented ####
### not a list
test_that("args_filter_input: extension does not return list", {
	method(args_filter_input, ClassCharacter) <- function(x) "not a list"
	expect_snapshot(error = TRUE, {
		filterInput(ClassCharacter(letters))
	})
})

### list is not named
test_that("args_filter_input: extension does not return named list", {
	method(args_filter_input, ClassCharacter) <- function(x) list("not named")
	expect_snapshot(error = TRUE, {
		filterInput(ClassCharacter(letters))
	})

	method(args_filter_input, ClassCharacter) <- function(x) {
		list("not named", named = "named")
	}
	expect_snapshot(error = TRUE, {
		filterInput(ClassCharacter(letters))
	})
})

### list is not uniquely named
test_that("args_filter_input: extension does not return uniquely named list", {
	method(args_filter_input, ClassCharacter) <- function(x) {
		# jarl-ignore duplicated_arguments: testing for error
		list(entry = "a", entry = "b")
	}
	expect_snapshot(error = TRUE, {
		filterInput(ClassCharacter(letters))
	})
})

# call_filter_input ####
test_that("call_filter_input errors for data.frames", {
	expect_snapshot(error = TRUE, {
		call_filter_input(test_df, shiny::selectInput)
	})
})

# call_update_filter_input ####
test_that("call_update_filter_input errors for data.frames", {
	expect_snapshot(error = TRUE, {
		call_update_filter_input(test_df, shiny::updateSelectInput)
	})
})

# get_filter_logical ####
## column nopt found
test_that("get_filter_logical: column not found", {
	expect_snapshot(error = TRUE, {
		get_filter_logical(test_df, "i", column = "nonexistent")
	})
})

## invalid column_name argument ####
test_that("get_filter_logical: column argument is non-empty string", {
	expect_snapshot(error = TRUE, {
		get_filter_logical(test_df, "i", column = NA_character_)
		get_filter_logical(test_df, "i", column = "")
	})
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
	expect_snapshot(error = TRUE, {
		apply_filters(df, list(x = letters[1:5]))
	})
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
	expect_snapshot(error = TRUE, {
		apply_filters(df, list(x = letters[1:5]))
	})
})

# filterInput ####
## `radio` and `selectize` both TRUE ####
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

## S7 method not found ####
test_that("filterInput: method not found for S7 object passed as list", {
	obj <- ClassList(as.list(letters))
	expect_snapshot(error = TRUE, {
		filterInput(obj)
	})
})

## argument supplied that is provided by args_filter_input() ####
test_that("filterInput: arg supplied that is provided by args_filter_input()", {
	expect_snapshot(error = TRUE, {
		filterInput(letters, choices = letters)
		filterInput(choices_dte, min = min(choices_dte))
	})
})

# `ns` ####
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

# serverFilterInput ####
test_that("serverFilterInput() with reactive() throws error when missing required columns", {
	testServer(app_shiny(), {
		input_list <- reactive(list(chr_col = "a", num_col = 5))
		expect_snapshot(error = TRUE, {
			._prepare_input(input_list, x = test_df)
		})
	})
})

test_that("serverFilterInput() with reactive() warns when extra columns provided", {
	testServer(app_shiny(), {
		input_list <- reactive({
			out <- vector("list", ncol(test_df))
			names(out) <- get_input_ids(test_df)
			c(out, list(unsupported = "x"))
		})
		expect_snapshot(invisible(._prepare_input(input_list, x = test_df)))
	})
})

# updateFilterInput ####
test_that("updateFilterInput: radio and selectize cannot both be TRUE", {
	expect_snapshot(error = TRUE, {
		updateFilterInput(
			choices_chr,
			inputId = "test",
			radio = TRUE,
			selectize = TRUE
		)
	})
})
