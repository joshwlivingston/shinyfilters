library(S7)

library(shinyfilters)

# Setup ####
letters_shuffled <- sample(letters, 10, TRUE)
choices_fct <- as.factor(letters_shuffled)
choices_fct_with_na <- choices_fct
choices_fct_with_na[
	sample.int(length(choices_fct), sample.int((length(choices_fct) - 1), 1))
] <- NA

choices_lst <- as.list(letters_shuffled)
choices_lst_with_na <- choices_lst
choices_lst_with_na[
	sample.int(length(choices_lst), sample.int((length(choices_lst) - 1), 1))
] <- NA

choices_chr <- letters_shuffled
choices_chr_with_na <- choices_chr
choices_chr_with_na[
	sample.int(length(choices_chr), sample.int((length(choices_chr) - 1), 1))
] <- NA

choices_log <- sample(c(TRUE, FALSE), 10, TRUE)
choices_log_with_na <- choices_log
choices_log_with_na[sample.int(2, 1)] <- NA

choices_num <- 1:10
choices_num_with_na <- choices_num
choices_num_with_na[
	sample.int(length(choices_num), sample.int((length(choices_num) - 1), 1))
] <- NA

choices_dte <- sample(Sys.Date() + 0:9)
choices_dte_with_na <- choices_dte
choices_dte_with_na[
	sample.int(length(choices_dte), sample.int((length(choices_dte) - 1), 1))
] <- NA

choices_psc <- sample(Sys.time() + as.difftime(0:9, units = "days"))
choices_psc_with_na <- choices_psc
choices_psc_with_na[
	sample.int(length(choices_psc), sample.int((length(choices_psc) - 1), 1))
] <- NA

choices_psl <- sample(as.POSIXlt(Sys.time() + as.difftime(0:9, units = "days")))
choices_psl_with_na <- choices_psl
choices_psl_with_na[
	sample.int(length(choices_psl), sample.int((length(choices_psl) - 1), 1))
] <- NA

choices_chr_na <- rep(NA_character_, 10)
choices_cpx_na <- rep(NA_complex_, 10)
choices_rel_na <- rep(NA_real_, 10)
choices_int_na <- rep(NA_integer_, 10)

# Create test lists for unique.default testing
test_lst_with_duplicates <- list(a = 1, b = 2, c = 1, d = 3, e = 2)
test_lst_with_na <- list(a = 1, b = NA, c = 1, d = 3, e = NA)

# Create test data.frames for filterInput testing
must_use_radio <- new_S3_class(
	class = "must_use_radio",
	constructor = function(.data) .data
)
method(filterInput, must_use_radio) <- function(x, ...) {
	call_filter_input(x, shiny::radioButtons, ...)
}
method(updateFilterInput, must_use_radio) <- function(x, ...) {
	call_update_filter_input(x, shiny::updateRadioButtons, ...)
}
use_radio <- function(x) {
	structure(x, class = unique(c("must_use_radio", class(x))))
}

must_use_date_range <- new_S3_class(
	class = "must_use_date_range",
	constructor = function(.data) .data
)
method(filterInput, must_use_date_range) <- function(x, ...) {
	call_filter_input(x, shiny::dateRangeInput, ...)
}
method(updateFilterInput, must_use_date_range) <- function(x, ...) {
	call_update_filter_input(x, shiny::updateDateRangeInput, ...)
}
method(args_filter_input, must_use_date_range) <- function(x, ...) {
	max_x <- max(x, na.rm = TRUE)
	min_x <- min(x, na.rm = TRUE)
	list(min = min_x, max = max_x, start = min_x, end = max_x)
}
use_date_range <- function(x) {
	structure(x, class = unique(c("must_use_date_range", class(x))))
}

must_use_selectize <- new_S3_class(
	class = "must_use_selectize",
	constructor = function(.data) .data
)
method(filterInput, must_use_selectize) <- function(x, ...) {
	call_filter_input(x, shiny::selectizeInput, ...)
}
method(updateFilterInput, must_use_selectize) <- function(x, ...) {
	call_update_filter_input(x, shiny::updateSelectizeInput, ...)
}
use_selectize <- function(x) {
	structure(x, class = unique(c("must_use_selectize", class(x))))
}

must_use_slider <- new_S3_class(
	class = "must_use_slider",
	constructor = function(.data) .data
)
method(filterInput, must_use_slider) <- function(x, ...) {
	call_filter_input(x, shiny::sliderInput, ...)
}
method(updateFilterInput, must_use_slider) <- function(x, ...) {
	call_update_filter_input(x, shiny::updateSliderInput, ...)
}
use_slider <- function(x) {
	structure(x, class = unique(c("must_use_slider", class(x))))
}

must_use_textarea <- new_S3_class(
	class = "must_use_textarea",
	constructor = function(.data) .data
)
method(filterInput, must_use_textarea) <- function(x, ...) {
	call_filter_input(x, shiny::textAreaInput, ...)
}
method(updateFilterInput, must_use_textarea) <- function(x, ...) {
	call_update_filter_input(x, shiny::updateTextAreaInput, ...)
}
method(args_filter_input, must_use_textarea) <- function(x, ...) {
	return(NULL)
}
use_textarea <- function(x) {
	structure(x, class = unique(c("must_use_textarea", class(x))))
}

must_use_text <- new_S3_class(
	class = "must_use_text",
	constructor = function(.data) .data
)
method(filterInput, must_use_text) <- function(x, ...) {
	call_filter_input(x, shiny::textInput, ...)
}
method(updateFilterInput, must_use_text) <- function(x, ...) {
	call_update_filter_input(x, shiny::updateTextInput, ...)
}
method(args_filter_input, must_use_text) <- function(x, ...) {
	return(NULL)
}
use_text <- function(x) {
	structure(x, class = unique(c("must_use_text", class(x))))
}

# fmt: skip
test_df <- data.frame(
	stringsAsFactors = FALSE,
	chr_col            =                sample(choices_chr, 10, TRUE),
	chr_col_radio      = use_radio(     sample(choices_chr, 10, TRUE)),
	chr_col_selectize  = use_selectize( sample(choices_chr, 10, TRUE)),
	chr_col_textarea   = use_textarea(  sample(choices_chr, 10, TRUE)),
	chr_col_text       = use_text(      sample(choices_chr, 10, TRUE)),
	dte_col            =                sample(choices_dte, 10, TRUE),
	dte_col_date_range = use_date_range(sample(choices_dte, 10, TRUE)),
	fct_col            =                sample(choices_fct, 10, TRUE),
	log_col            =                sample(choices_log, 10, TRUE),
	num_col            =                sample(choices_num, 10, TRUE),
	num_col_slider     = use_slider(    sample(choices_num, 10, TRUE)),
	psc_col            =                sample(choices_psc, 10, TRUE),
	psl_col            =                sample(choices_psl, 10, TRUE)
)

# create list to filter `test_df`
filter_list <- list(chr_col = c("a", "b"))
