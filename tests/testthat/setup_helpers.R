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
