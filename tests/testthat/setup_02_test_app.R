library(shiny)

app_shiny <- local({
	._app_shiny_cache <- NULL
	function() {
		if (is.null(._app_shiny_cache)) {
			# jarl-ignore undesirable_operator: undesired rule
			._app_shiny_cache <<- shinyApp(
				ui = fluidPage(
					sidebarLayout(
						sidebarPanel(
							filterInput(test_df)
						),
						mainPanel()
					)
				),
				server = function(input, output, session) {}
			)
		}
		._app_shiny_cache
	}
})
