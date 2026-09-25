# defaults ####
## list ####
test_that("args_filter_input() returns provided list as choices argument", {
	expect_identical(
		args_filter_input(choices_lst_with_na),
		list(choices = choices_lst_with_na)
	)
})

## factor, logical ####
test_that("args_filter_input() (factor, logical) returns sorted, unique values as choices argument", {
	expect_identical(
		args_filter_input(choices_fct_with_na),
		list(choices = unique(sort(choices_fct_with_na)))
	)
	expect_identical(
		args_filter_input(choices_log_with_na),
		list(choices = unique(sort(choices_log_with_na)))
	)
})


## character ####
test_that("args_filter_input() default returns sorted, unique values as choices argument", {
	expect_identical(
		args_filter_input(choices_chr_with_na),
		list(choices = unique(sort(choices_chr_with_na)))
	)
})

test_that("args_filter_input() (character) with textbox = FALSE returns sorted, unique values as choices argument", {
	expect_identical(
		args_filter_input(choices_chr_with_na, textbox = FALSE),
		list(choices = unique(sort(choices_chr_with_na)))
	)
})

test_that("args_filter_input() with textbox = TRUE returns NULL for character vectors", {
	expect_null(
		args_filter_input(choices_chr_with_na, textbox = TRUE)
	)
})

## numeric ####
test_that("args_filter_input() returns min, max, and max for numeric vectors", {
	expect_identical(
		args_filter_input(choices_num_with_na),
		list(
			min = min(choices_num_with_na, na.rm = TRUE),
			max = max(choices_num_with_na, na.rm = TRUE),
			value = max(choices_num_with_na, na.rm = TRUE)
		)
	)
})

## Date ####
test_that("args_filter_input() returns min, max, max for Date vectors", {
	expect_identical(
		args_filter_input(choices_dte_with_na),
		list(
			min = min(choices_dte_with_na, na.rm = TRUE),
			max = max(choices_dte_with_na, na.rm = TRUE),
			value = max(choices_dte_with_na, na.rm = TRUE)
		)
	)
})

## POSIXt ####
### POSIXct ####
test_that("args_filter_input() returns min and max Dates for POSIXct vectors", {
	expect_identical(
		args_filter_input(choices_psc_with_na),
		list(
			min = min(as.Date(choices_psc_with_na), na.rm = TRUE),
			max = max(as.Date(choices_psc_with_na), na.rm = TRUE),
			value = max(as.Date(choices_psc_with_na), na.rm = TRUE)
		)
	)
})

### POSIXlt ####
test_that("args_filter_input() returns min and max Dates for POSIXlt vectors", {
	expect_identical(
		args_filter_input(choices_psl_with_na),
		list(
			min = min(as.Date(choices_psl_with_na), na.rm = TRUE),
			max = max(as.Date(choices_psl_with_na), na.rm = TRUE),
			value = max(as.Date(choices_psl_with_na), na.rm = TRUE)
		)
	)
})

# args_filter_input() with unique() and sort() arguments ####

test_that("args_filter_input() removes duplicates from list with numeric values", {
	result <- args_filter_input(test_lst_with_duplicates)
	expected <- list(choices = test_lst_with_duplicates)
	expect_identical(result, expected)
})

test_that("args_filter_input() removes duplicates from list with NA values", {
	result <- args_filter_input(test_lst_with_na)
	expected <- list(choices = test_lst_with_na)
	expect_identical(result, expected)
})

test_that("args_filter_input() respects choices_asis = TRUE prevents sorting", {
	duplicated_chr <- c("a", "b", "a", "c", "b")
	result <- args_filter_input(duplicated_chr, choices_asis = TRUE)
	expected <- list(choices = duplicated_chr)
	expect_identical(result, expected)
})

test_that("args_filter_input() passes decreasing to sort for character", {
	result <- args_filter_input(
		choices_chr_with_na,
		args_sort = list(decreasing = TRUE)
	)
	expected <- list(
		choices = unique(sort(choices_chr_with_na, decreasing = TRUE))
	)
	expect_identical(result, expected)
})

test_that("args_filter_input() passes decreasing to sort for factor", {
	result <- args_filter_input(
		choices_fct_with_na,
		args_sort = list(decreasing = TRUE)
	)
	expected <- list(
		choices = unique(sort(choices_fct_with_na, decreasing = TRUE))
	)
	expect_identical(result, expected)
})

test_that("args_filter_input() passes na.last to sort for character with NA", {
	result <- args_filter_input(
		choices_chr_with_na,
		args_sort = list(na.last = TRUE)
	)
	expected <- list(choices = unique(sort(choices_chr_with_na, na.last = TRUE)))
	expect_identical(result, expected)
})

test_that("args_filter_input() passes na.last to sort for factor with NA", {
	result <- args_filter_input(
		choices_fct_with_na,
		args_sort = list(na.last = FALSE)
	)
	expected <- list(choices = unique(sort(choices_fct_with_na, na.last = FALSE)))
	expect_identical(result, expected)
})

test_that("args_filter_input() passes multiple sort args for character with NA", {
	result <- args_filter_input(
		choices_chr_with_na,
		args_sort = list(
			decreasing = TRUE,
			na.last = FALSE
		)
	)
	expected <- list(
		choices = unique(sort(
			choices_chr_with_na,
			decreasing = TRUE,
			na.last = FALSE
		))
	)
	expect_identical(result, expected)
})

# server = TRUE ####
test_that("args_filter_input() with server = TRUE returns empty string for choices (character)", {
	result <- args_filter_input(choices_chr_with_na, server = TRUE)
	expected <- list(choices = "")
	expect_identical(result, expected)
})

test_that("args_filter_input() with server = TRUE returns empty string for choices (factor)", {
	result <- args_filter_input(choices_fct_with_na, server = TRUE)
	expected <- list(choices = "")
	expect_identical(result, expected)
})

test_that("args_filter_input() with server = TRUE returns empty string for choices (logical)", {
	result <- args_filter_input(choices_log_with_na, server = TRUE)
	expected <- list(choices = "")
	expect_identical(result, expected)
})

test_that("args_filter_input() with server = TRUE returns empty string for choices (list)", {
	result <- args_filter_input(choices_lst_with_na, server = TRUE)
	expected <- list(choices = "")
	expect_identical(result, expected)
})

# Errors ####
### invalid args_* provided ####
test_that("args_filter_input validates args_unique must be list", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_chr, args_unique = "not_a_list")
	})
})

test_that("args_filter_input validates args_sort must be list", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_chr, args_sort = "not_a_list")
	})
})

test_that("args_filter_input validates args_unique list is named", {
	lst <- list(1, b = 2)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_chr, args_unique = lst)
	})
})

test_that("args_filter_input validates args_sort list is named", {
	lst <- list(1, b = 2)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_chr, args_sort = lst)
	})
})

test_that("args_filter_input validates args_unique names are unique", {
	lst <- list(a = 1, b = 2)
	names(lst) <- c("a", "a")
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_chr, args_unique = lst)
	})
})

test_that("args_filter_input validates args_sort names are unique", {
	lst <- list(a = 1, b = 2)
	names(lst) <- c("a", "a")
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_chr, args_sort = lst)
	})
})

### invalid choices_asis provided ####
test_that("args_filter_input: choices_asis must be TRUE for list", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(choices_lst, choices_asis = FALSE)
	})
})

### invalid extension implemented ####
#### not a list
test_that("args_filter_input: extension does not return list", {
	method(args_filter_input, ClassCharacter) <- function(x) "not a list"
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(ClassCharacter(letters))
	})
})

#### list is not named
test_that("args_filter_input: extension does not return named list", {
	method(args_filter_input, ClassCharacter) <- function(x) list("not named")
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(ClassCharacter(letters))
	})

	method(args_filter_input, ClassCharacter) <- function(x) {
		list("not named", named = "named")
	}
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(ClassCharacter(letters))
	})
})

#### list is not uniquely named
test_that("args_filter_input: extension does not return uniquely named list", {
	method(args_filter_input, ClassCharacter) <- function(x) {
		# jarl-ignore duplicated_arguments: testing for error
		list(entry = "a", entry = "b")
	}
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(ClassCharacter(letters))
	})
})

test_that("args_filter_input: method not found for S7 object passed as list", {
	obj <- ClassList(as.list(letters))
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		args_filter_input(obj)
	})
})
