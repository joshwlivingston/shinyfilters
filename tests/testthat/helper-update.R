# Records the input messages a mock session is sent. Returns a function that
# lists them.
record_messages <- function(session) {
	messages <- list()
	session$sendInputMessage <- function(inputId, message) {
		messages[[length(messages) + 1L]] <<- list(
			inputId = inputId,
			message = message
		)
	}
	function() messages
}

# The input messages `code` sends
update_messages <- function(code, session = shiny::MockShinySession$new()) {
	sent <- record_messages(session)
	shiny::withReactiveDomain(session, code)
	sent()
}
