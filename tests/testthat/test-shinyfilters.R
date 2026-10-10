test_that("shinyfilters() applies `ns` to input ids", {
	res <- filterInput(shinyfilters(
		data.frame(stringsAsFactors = FALSE, a = letters),
		ns = shiny::NS("m")
	))
	expect_match(as.character(res), 'id="m-a"', fixed = TRUE)
})

test_that("shinyfilters(): `ns` must be result of shiny::NS()", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		shinyfilters(
			data.frame(stringsAsFactors = FALSE, a = letters),
			ns = function(x) x
		)
	})
})

test_that("shinyfilters() without overrides matches filterInput(<data.frame>)", {
	expect_identical(
		filterInput(shinyfilters(df_config)),
		filterInput(
			df_config,
			range = TRUE,
			selectize = TRUE,
			multiple = TRUE,
			slider = TRUE
		)
	)
})

test_that("column and argument names don't partial-match the configuration", {
	df <- data.frame(stringsAsFactors = FALSE, c = c("a", "b"), con = 1:2)
	cfg <- shinyfilters(df)
	expect_identical(
		with_filters(cfg, c = "radio", con = "slider"),
		with_filters(with_filters(cfg, "c" = "radio"), "con" = "slider")
	)
	expect_identical(with_defaults(cfg, c = 1)@args, c(cfg@args, list(c = 1)))
})

test_that("with_filters() call forms are equivalent", {
	cfg <- shinyfilters(df_config, slider = TRUE)
	expected <- filterInput(with_filters(cfg, x = "radio"))
	col <- "x"
	expect_identical(
		filterInput(with_filters(cfg, col ~ "radio")),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, x ~ "radio")),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, x = "radio")),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, x = shiny::radioButtons)),
		expected
	)
})

test_that("a shiny input is matched as it is now, not as it was when built", {
	upgraded <- function(inputId, label, choices, ...) {
		shiny::selectInput(inputId, label, choices, ...)
	}
	local_mocked_bindings(selectInput = upgraded)
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_filters(cfg, letters = upgraded),
		with_filters(cfg, letters = "select")
	)
	expect_snapshot(print(cfg), variant = snapshot_variant())
})

test_that("with_filters() takes `cols ~ input` formulas", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(
			cfg,
			x ~ shiny::radioButtons,
			letters ~ "selectize"
		)),
		filterInput(with_filters(cfg, x = "radio", letters = "selectize"))
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			everything() ~ "selectize",
			x = "radio",
			a_very_very_long_name ~ "slider" ~ list(value = range(.x))
		)),
		filterInput(with_filters(
			with_filters(cfg, everything() ~ "selectize"),
			x = "radio",
			a_very_very_long_name = "slider" ~ list(value = range(.x))
		))
	)
})

test_that("with_filters() selects columns with tidyselect", {
	cfg <- shinyfilters(df_config, slider = FALSE)
	expected <- filterInput(shinyfilters(df_config))
	expect_identical(
		filterInput(with_filters(cfg, where(is.numeric) ~ "slider")),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, c(x, a_very_very_long_name) ~ "slider")),
		expected
	)
})

test_that("numeric + radio / select / selectize -> choices in numeric order", {
	res <- filterInput(with_filters(shinyfilters(df_config), x = "radio"))
	expect_identical(
		res[[3]],
		shiny::radioButtons("x", "x", choices = c(2L, 9L, 10L))
	)
	res <- filterInput(with_filters(shinyfilters(df_config), x = "select"))
	expect_identical(
		res[[3]],
		shiny::selectInput("x", "x", choices = c(2L, 9L, 10L), multiple = TRUE)
	)
	res <- filterInput(with_filters(shinyfilters(df_config), x = "selectize"))
	expect_identical(
		res[[3]],
		shiny::selectizeInput(
			"x",
			"x",
			choices = c(2L, 9L, 10L),
			multiple = TRUE
		)
	)
})

test_that("global `radio = TRUE` doesn't apply to numeric columns", {
	res <- filterInput(shinyfilters(df_config, radio = TRUE))
	expect_identical(
		res[[3]],
		filterInput(df_config$x, inputId = "x", label = "x", slider = TRUE)
	)
})

test_that("`radio = TRUE` turns off the `selectize` default", {
	res <- filterInput(shinyfilters(df_config, radio = TRUE))
	expect_identical(
		res[[1]],
		shiny::radioButtons("letters", "letters", choices = c("a", "b", "c"))
	)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(shinyfilters(df_config, radio = TRUE, selectize = TRUE))
	})
})

test_that("factor + radio keeps level order", {
	res <- filterInput(with_filters(shinyfilters(df_config), factors = "radio"))
	expect_identical(
		res[[2]],
		shiny::radioButtons(
			"factors",
			"factors",
			choices = factor(c("lo", "hi"), c("lo", "hi"))
		)
	)
})

test_that("keyword override replaces conflicting global flags", {
	res <- filterInput(with_filters(
		shinyfilters(df_config, selectize = TRUE),
		letters = "radio"
	))
	expect_identical(
		res[[1]],
		filterInput(
			df_config$letters,
			inputId = "letters",
			label = "letters",
			radio = TRUE
		)
	)
	res <- filterInput(
		with_filters(shinyfilters(df_config), letters = "select", x = "select"),
		selectize = FALSE
	)
	expect_identical(
		res[[1]],
		shiny::selectInput(
			"letters",
			"letters",
			choices = c("a", "b", "c"),
			selectize = FALSE,
			multiple = TRUE
		)
	)
	expect_identical(
		res[[3]],
		shiny::selectInput(
			"x",
			"x",
			choices = c(2L, 9L, 10L),
			selectize = FALSE,
			multiple = TRUE
		)
	)
	res <- filterInput(with_filters(
		shinyfilters(df_config, selectize = FALSE),
		letters = "selectize",
		x = "selectize"
	))
	expect_identical(
		res[[1]],
		shiny::selectizeInput(
			"letters",
			"letters",
			choices = c("a", "b", "c"),
			multiple = TRUE
		)
	)
	expect_identical(
		res[[3]],
		shiny::selectizeInput(
			"x",
			"x",
			choices = c(2L, 9L, 10L),
			multiple = TRUE
		)
	)
})

test_that("`selectize = FALSE` is the same wherever it is set", {
	expected <- filterInput(
		df_config,
		range = TRUE,
		selectize = FALSE,
		multiple = TRUE,
		slider = TRUE
	)
	cfg <- shinyfilters(df_config, selectize = FALSE)
	expect_identical(filterInput(cfg), expected)
	expect_identical(
		filterInput(with_defaults(shinyfilters(df_config), selectize = FALSE)),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, c(letters, factors) ~ "select")),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, letters = shiny::selectInput)),
		expected
	)
})

test_that("area -> shiny::textAreaInput", {
	res <- filterInput(with_filters(shinyfilters(df_config), letters = "area"))
	expect_identical(res[[1]], shiny::textAreaInput("letters", "letters"))
})

test_that("date / numeric / select -> the input a column has by default", {
	df <- data.frame(
		stringsAsFactors = FALSE,
		chr = c("b", "a"),
		fct = factor(c("hi", "lo")),
		lgl = c(TRUE, FALSE),
		num = c(2.5, 1.5),
		dte = as.Date("2024-01-01") + 0:1,
		dtm = as.POSIXct("2024-01-01", tz = "UTC") + 0:1 * 86400
	)
	cfg <- shinyfilters(
		df,
		textbox = TRUE,
		selectize = TRUE,
		slider = TRUE,
		range = TRUE
	)
	keywords <- with_filters(
		cfg,
		c(chr, fct, lgl) ~ "select",
		num = "numeric",
		c(dte, dtm) ~ "date"
	)
	expect_identical(filterInput(keywords), filterInput(df, multiple = TRUE))
	expect_identical(
		with_filters(
			cfg,
			c(chr, fct, lgl) ~ shiny::selectInput,
			num = shiny::numericInput,
			c(dte, dtm) ~ shiny::dateInput
		),
		keywords
	)
})

test_that("overrides work on columns with NA", {
	df <- data.frame(stringsAsFactors = FALSE, a = c(NA, 3L, 1L))
	res <- filterInput(with_filters(shinyfilters(df), a = "radio"))
	expect_identical(res[[1]], shiny::radioButtons("a", "a", choices = c(1L, 3L)))
})

test_that("every column overridden, and one-column data frames", {
	res <- filterInput(with_filters(
		shinyfilters(df_config),
		everything() ~ "radio"
	))
	expect_length(res, ncol(df_config))
	res <- filterInput(with_filters(
		shinyfilters(data.frame(stringsAsFactors = FALSE, a = 1:3)),
		a = "slider"
	))
	expect_identical(
		res[[1]],
		filterInput(1:3, inputId = "a", label = "a", slider = TRUE)
	)
})

test_that("`ns` applies to keyword, function, and default inputs", {
	my_select <- function(inputId, label, choices) {
		shiny::selectInput(inputId, label, choices)
	}
	cfg <- shinyfilters(df_config, ns = shiny::NS("m"))
	cfg <- with_filters(cfg, x = "radio", letters = my_select)
	html <- as.character(filterInput(cfg))
	for (col in names(df_config)) {
		expect_match(html, sprintf('id="m-%s"', col), fixed = TRUE)
	}
})

test_that("with_filters(): last write wins", {
	cfg <- shinyfilters(df_config)
	specific_last <- with_filters(cfg, where(is.numeric) ~ "slider")
	specific_last <- filterInput(with_filters(specific_last, x = "radio"))
	expect_identical(
		specific_last[[3]],
		filterInput(with_filters(cfg, x = "radio"))[[3]]
	)
	class_last <- with_filters(cfg, x = "radio")
	class_last <- filterInput(with_filters(
		class_last,
		where(is.numeric) ~ "slider"
	))
	expect_identical(
		class_last[[3]],
		filterInput(
			df_config$x,
			inputId = "x",
			label = "x",
			slider = TRUE
		)
	)
})

test_that("with_filters() adds and replaces columns", {
	cfg <- shinyfilters(df_config)
	added <- with_filters(cfg, y = x^2, flag = TRUE, z = y + 1)
	expect_identical(
		as.data.frame(added),
		transform(df_config, y = x^2, flag = TRUE, z = x^2 + 1)
	)

	replaced <- with_filters(with_filters(cfg, x = "radio"), x = x / 2)
	expect_identical(as.data.frame(replaced)$x, df_config$x / 2)
	expect_identical(
		filterInput(replaced),
		filterInput(with_filters(
			shinyfilters(as.data.frame(replaced)),
			x = "radio"
		))
	)
})

test_that("print() marks columns added by with_filters()", {
	cfg <- with_filters(shinyfilters(df_config), y = x * 2)
	expect_snapshot(variant = snapshot_variant(), {
		print(cfg)
		print(cfg["y"])
		print(cfg["x"])
	})
})

test_that("print() marks columns replaced by with_filters()", {
	cfg <- with_filters(shinyfilters(df_config), x = x / 2, letters = letters)
	expect_snapshot(variant = snapshot_variant(), {
		print(cfg)
		print(cfg["x"])
		print(cfg["letters"])
	})
})

test_that("print() keeps a recomputed added column marked as added", {
	cfg <- with_filters(shinyfilters(df_config), y = x * 2, y = y + 1)
	out <- capture.output(print(cfg))
	expect_match(out, "Filter added by", fixed = TRUE, all = FALSE)
	expect_no_match(out, "Column replaced by", fixed = TRUE)
})

test_that("print() markers are one column wide in UTF-8 output", {
	withr::local_options(cli.unicode = TRUE, cli.num_colors = 1)
	cfg <- shinyfilters(df_config, slider = FALSE)
	cfg <- with_filters(cfg, y = x * 2, x = x / 2)
	cfg <- with_filters(cfg, letters = "radio")
	out <- capture.output(print(cfg))
	legend <- grep(" Filter ", out, fixed = TRUE, value = TRUE)
	expect_length(legend, 4)
	expect_all_equal(nchar(sub(" Filter .*", "", legend), type = "width"), 1L)
})

test_that("print() lines up rows with and without a marker", {
	cfg <- with_filters(shinyfilters(df_config), letters = "radio")
	out <- capture.output(print(cfg))
	rows <- grep("<(chr|fct|int|dbl)>", out, value = TRUE)
	expect_length(rows, 4)
	expect_length(unique(as.integer(regexpr("<", rows, fixed = TRUE))), 1)
})

test_that("print() shows one marker per row", {
	cfg <- shinyfilters(df_config, selectize = FALSE)
	cfg <- with_filters(cfg, y = x * 2, x = x / 2, z = letters)
	cfg <- with_filters(cfg, a_very_very_long_name = a_very_very_long_name + 1)
	cfg <- with_filters(cfg, x = "radio", a_very_very_long_name = numericInput)
	expect_snapshot(print(cfg), variant = snapshot_variant())
})

test_that("print() handles long names", {
	data <- nyc_flights
	data$awpirgbeqaprkjgbaepirgfbawpirgbeqaprkjgbaepirgfbawpirgbe <- data$carrier
	data$carrier <- NULL
	filters <- shinyfilters(data, range = TRUE, selectize = TRUE)
	filters <- with_ns(filters, "sidebar-mod")
	filters <- with_filters(
		filters,
		on_time = !delayed,
		origin = shiny::radioButtons,
		dep_delay ~
			list(value = urgfjkbhqaewpqaedoufikljshygbqaeoliurgfjkbhqaewp(.x))
	)
	expect_snapshot(print(filters), variant = snapshot_variant())
})

test_that("filterInput(<shinyfilters>, ...) merges with global arguments", {
	expect_identical(
		filterInput(shinyfilters(df_config, slider = FALSE), slider = TRUE),
		filterInput(shinyfilters(df_config))
	)
	expect_identical(
		filterInput(shinyfilters(df_config), ns = shiny::NS("m")),
		filterInput(shinyfilters(df_config, ns = shiny::NS("m")))
	)
})

test_that("range override on Date and POSIXct columns", {
	df <- data.frame(
		stringsAsFactors = FALSE,
		dte = as.Date("2024-01-01") + 0:1,
		dtm = as.POSIXct("2024-01-01", tz = "UTC") + 0:1 * 86400
	)
	res <- filterInput(with_filters(shinyfilters(df), everything() ~ "range"))
	expect_identical(
		res[[1]],
		filterInput(df$dte, inputId = "dte", label = "dte", range = TRUE)
	)
	expect_identical(
		res[[2]],
		filterInput(df$dtm, inputId = "dtm", label = "dtm", range = TRUE)
	)
})

test_that("radio override on Date and POSIXct columns -> dates as choices", {
	df <- data.frame(dte = as.Date("2024-01-02") - c(0, 1, 1))
	df$dtm <- as.POSIXct(
		c("2024-01-02 10:00", "2024-01-01 09:00", "2024-01-01 17:30"),
		tz = "UTC"
	)
	cfg <- with_filters(shinyfilters(df), everything() ~ "radio")
	res <- filterInput(cfg)
	dates <- as.Date("2024-01-01") + 0:1
	expect_identical(res[[1]], shiny::radioButtons("dte", "dte", choices = dates))
	expect_identical(res[[2]], shiny::radioButtons("dtm", "dtm", choices = dates))
	# A choice filters the columns, which keep their types
	expect_identical(
		apply_filters(cfg, list(dte = "2024-01-01", dtm = "2024-01-01")),
		df[2:3, ]
	)
})

test_that("radio override on a column of any other class -> its text as choices", {
	df <- data.frame(id = 1:3)
	df$dur <- as.difftime(c(3, 1, 1), units = "mins")
	cfg <- with_filters(shinyfilters(df), dur = "radio")
	expect_identical(
		cfg$dur,
		shiny::radioButtons("dur", "dur", choices = c("1", "3"))
	)
	expect_identical(apply_filters(cfg, list(dur = "1")), df[2:3, ])
})

test_that("radio override on logical columns", {
	df <- data.frame(stringsAsFactors = FALSE, lgl = c(TRUE, FALSE))
	res <- filterInput(with_filters(shinyfilters(df), lgl = "radio"))
	expect_identical(
		res[[1]],
		filterInput(df$lgl, inputId = "lgl", label = "lgl", radio = TRUE)
	)
})

test_that("function overrides receive args_filter_input() output", {
	my_numeric <- function(inputId, label, value, min, max) {
		shiny::numericInput(inputId, label, value, min, max)
	}
	res <- filterInput(with_filters(shinyfilters(df_config), x = my_numeric))
	expect_identical(
		res[[3]],
		filterInput(df_config$x, inputId = "x", label = "x")
	)
})

test_that("errors from a function override name the column", {
	broken <- function(inputId, label, ...) {
		rlang::abort("Not today.", call = NULL)
	}
	cfg <- with_filters(shinyfilters(df_config), x = broken)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(cfg)
		cfg$x
	})
})

test_that("a function override can use shiny::req()", {
	needs_input <- function(inputId, label, ...) {
		shiny::req(FALSE)
	}
	cfg <- with_filters(shinyfilters(df_config), x = needs_input)
	expect_error(filterInput(cfg), class = "shiny.silent.error")
})

test_that("shinyfilters() and with_filters() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		shinyfilters(1:3)
		shinyfilters(df_config[0, ])
		shinyfilters(df_config, TRUE)
		with_filters(df_config, x = "radio")
		with_filters(cfg)
		with_filters(cfg, x)
		with_filters(cfg, x, "radio", "slider")
		with_filters(cfg, x = "radio", "letters")
		with_filters(cfg, nope = "radio")
		with_filters(cfg, nope, "radio")
		with_filters(cfg, where(is.logical), "radio")
		with_filters(cfg, x = "radioo")
		with_filters(cfg, nope ~ "radio")
		with_filters(cfg, where(is.logical) ~ "radio")
		with_filters(cfg, x ~ "radioo")
		with_filters(cfg, ~"radio")
		with_filters(cfg, x, c("radio", "slider"))
		with_filters(cfg, x ~ 1)
		with_filters(cfg, x, TRUE)
		with_filters(cfg, x, radio)
		with_filters(cfg, x, range)
		with_filters(cfg, x = numeric)
		with_filters(cfg, y = nope * 2)
		with_filters(cfg, y = 1:2)
		with_filters(cfg, y = NULL)
		filterInput(with_filters(cfg, factors = "slider"))
		filterInput(with_filters(cfg, a_very_very_long_name = "range"))
		filterInput(with_filters(cfg, x = shiny::dateInput))
		filterInput(with_filters(
			shinyfilters(data.frame(a = as.Date("2024-01-01"))),
			a = shiny::numericInput
		))
		filterInput(with_filters(
			shinyfilters(data.frame(stringsAsFactors = FALSE, a = NA_integer_)),
			a = "radio"
		))
		filterInput(shinyfilters(data.frame(
			stringsAsFactors = FALSE,
			a = NA_integer_
		)))
	})
})

test_that("with_ns() adds, replaces, and removes the namespace", {
	cfg <- with_filters(shinyfilters(df_config, slider = TRUE), x = "radio")
	added <- with_ns(cfg, shiny::NS("m"))
	expect_identical(
		filterInput(added),
		filterInput(cfg, ns = shiny::NS("m"))
	)
	expect_identical(
		filterInput(with_ns(added, shiny::NS("other"))),
		filterInput(cfg, ns = shiny::NS("other"))
	)
	expect_identical(with_ns(added, NULL), cfg)
	expect_identical(with_ns(cfg, NULL), cfg)
})

test_that("with_ns() accepts a string", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_ns(cfg, "m")),
		filterInput(cfg, ns = shiny::NS("m"))
	)
	expect_identical(
		filterInput(with_ns(with_ns(cfg, "m"), "other")),
		filterInput(cfg, ns = shiny::NS("other"))
	)
})

test_that("with_ns() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_ns(df_config, shiny::NS("m"))
		with_ns(cfg, function(x) x)
		with_ns(cfg)
		with_ns(cfg, c("m", "n"))
		with_ns(cfg, NA_character_)
	})
})

test_that("with_defaults() adds, replaces, and removes defaults", {
	cfg <- with_filters(shinyfilters(df_config, slider = TRUE), x = "radio")
	expect_identical(
		with_defaults(shinyfilters(df_config, slider = FALSE), slider = TRUE),
		shinyfilters(df_config)
	)
	expect_identical(
		filterInput(with_defaults(cfg, selectize = FALSE)),
		filterInput(cfg, selectize = FALSE)
	)
	expect_identical(
		filterInput(with_defaults(cfg, slider = FALSE)),
		filterInput(cfg, slider = FALSE)
	)
	expect_identical(
		with_defaults(cfg, slider = NULL),
		with_filters(shinyfilters(df_config, slider = FALSE), x = "radio")
	)
	expect_identical(with_defaults(cfg), cfg)
	expect_identical(
		with_defaults(cfg, slider = FALSE),
		with_defaults(cfg, slider = NULL)
	)
	expect_identical(
		shinyfilters(df_config, slider = FALSE, width = FALSE)@args,
		list(range = TRUE, selectize = TRUE, multiple = TRUE, width = FALSE)
	)
	expect_identical(
		shinyfilters(df_config, slider = FALSE, select = FALSE)@args,
		list(range = TRUE, selectize = TRUE, multiple = TRUE, select = FALSE)
	)
	expect_identical(
		with_defaults(
			shinyfilters(df_config, options = list(a = 1)),
			options = list(b = 2)
		),
		shinyfilters(df_config, options = list(b = 2))
	)
})

test_that("with_defaults() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_defaults(df_config, slider = TRUE)
		with_defaults(cfg, TRUE)
		with_defaults(cfg, ns = shiny::NS("m"))
	})
})

test_that("print() shows the namespace with_ns() sets", {
	cfg <- shinyfilters(df_config, ns = shiny::NS("m"))
	expect_snapshot(variant = snapshot_variant(), {
		print(with_ns(cfg, shiny::NS("other")))
		print(with_ns(cfg, NULL))
	})
})

test_that("print() shows each column's input", {
	my_select <- function(inputId, label, choices) {
		shiny::selectInput(inputId, label, choices)
	}
	cfg <- shinyfilters(df_config, slider = TRUE, ns = shiny::NS("m"))
	cfg <- with_filters(cfg, x = "radio", letters = my_select)
	expect_snapshot(variant = snapshot_variant(), {
		print(shinyfilters(df_config))
		print(cfg)
		print(with_filters(shinyfilters(df_config), factors = "slider"))
		print(with_filters(shinyfilters(df_config), letters = shiny::radioButtons))
		print(shinyfilters(df_config, args_unique = "bad"))
		print(shinyfilters(data.frame(stringsAsFactors = FALSE, x = "a")))
	})
})

test_that("print() shows the defaults that differ from shinyfilters()'s", {
	expect_snapshot(variant = snapshot_variant(), {
		print(shinyfilters(df_config, slider = FALSE, width = "200px"))
		print(shinyfilters(df_config, radio = TRUE))
		print(shinyfilters(df_config, selectize = FALSE, multiple = FALSE))
		print(with_defaults(shinyfilters(df_config), range = NULL, textbox = TRUE))
	})
})

test_that("print() doesn't show an input named like the error marker as an error", {
	local_reproducible_output(crayon = TRUE)
	x_select <- function(inputId, label, choices) NULL
	cfg <- with_filters(shinyfilters(df_config), letters = x_select)
	expect_no_match(
		capture.output(print(cfg)),
		cli::col_red("x_select"),
		fixed = TRUE
	)
})

test_that("print() shows a datetime column's type", {
	df <- data.frame(
		dte = as.Date("2024-01-01") + 0:1,
		dtm = as.POSIXct("2024-01-01", tz = "UTC") + 0:1 * 86400
	)
	expect_snapshot(print(shinyfilters(df)), variant = snapshot_variant())
})

test_that("print() resolves custom methods", {
	ClassRadio <- S7::new_class("ClassRadio", S7::class_character)
	ClassCustom <- S7::new_class("ClassCustom", S7::class_character)
	S7::method(filterInput, ClassRadio) <- function(x, ...) {
		call_filter_input(x, shiny::radioButtons, ...)
	}
	S7::method(filterInput, ClassCustom) <- function(x, ...) {
		shiny::tags$div()
	}
	df <- structure(
		list(
			radio = ClassRadio(c("a", "b")),
			custom = ClassCustom(c("a", "b"))
		),
		class = "data.frame",
		row.names = 1:2
	)
	expect_snapshot(print(shinyfilters(df)), variant = snapshot_variant())
})

test_that("print() names the input of a method that changes it", {
	ClassTagged <- S7::new_class("ClassTagged", S7::class_character)
	S7::method(filterInput, ClassTagged) <- function(x, ...) {
		input <- call_filter_input(x, shiny::radioButtons, ...)
		htmltools::tagQuery(input)$addClass("wide")$allTags()
	}
	df <- structure(
		list(tagged = ClassTagged(c("a", "b"))),
		class = "data.frame",
		row.names = 1:2
	)
	expect_snapshot(print(shinyfilters(df)), variant = snapshot_variant())
})

test_that("`$`, `[[`, and names() access columns", {
	cfg <- with_filters(shinyfilters(df_config, ns = shiny::NS("m")), x = "radio")
	res <- filterInput(cfg)
	expect_identical(cfg$x, res[[3]])
	expect_identical(cfg[["letters"]], res[[1]])
	expect_identical(cfg[[4]], res[[4]])
	expect_identical(
		cfg[[c("letters", "x")]],
		filterInput(cfg[c("letters", "x")])
	)
	expect_identical(names(cfg), names(df_config))
	expect_identical(utils::.DollarNames(cfg, "^a_"), "a_very_very_long_name")
})

test_that("`$` and `[[` error on unknown columns", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		cfg$nope
		cfg[["nope"]]
		cfg[[9]]
		cfg[[c("x", "nope")]]
	})
})

test_that("a config placed in a UI that htmltools inspects errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		htmltools::tagGetAttribute(cfg["x"], "class")
		suppressMessages(htmltools::tagQuery(htmltools::div(cfg["x"]))$find(".a"))
	})
	expect_no_error(htmltools::tagGetAttribute(cfg[["x"]], "class"))
	expect_no_error(htmltools::tagQuery(htmltools::div(cfg[["x"]]))$find(".a"))
})

test_that("a config placed in bslib::accordion() errors", {
	skip_if_not_installed("bslib")
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		bslib::accordion(cfg["x"])
		suppressMessages(bslib::accordion(bslib::accordion_panel("A", cfg["x"])))
	})
	expect_no_error(bslib::accordion(bslib::accordion_panel("A", cfg[["x"]])))
})

test_that("str() shows a config's structure", {
	cfg <- shinyfilters(df_config)
	expect_output(str(cfg), "<shinyfilters::shinyfilters>", fixed = TRUE)
})

test_that("`[` returns a config with the selected columns", {
	cfg <- with_filters(shinyfilters(df_config, slider = TRUE), x = "radio")
	sub <- cfg[c("x", "letters")]
	expect_identical(names(sub), c("x", "letters"))
	expect_identical(filterInput(sub)[[1]], filterInput(cfg)[[3]])
	expect_identical(filterInput(sub)[[2]], filterInput(cfg)[[1]])
	expect_identical(names(cfg[3:4]), c("x", "a_very_very_long_name"))
	expect_identical(cfg[], cfg)
	expect_identical(names(cfg[-1]), names(df_config)[-1])
	expect_identical(names(cfg[c("x", "x")]), "x")
	expect_identical(names(cfg[c(x, letters)]), c("x", "letters"))
	expect_identical(
		names(cfg[where(is.numeric)]),
		c("x", "a_very_very_long_name")
	)
	cols <- c("factors", "x")
	expect_identical(names(cfg[all_of(cols)]), cols)
	x <- "letters"
	expect_identical(names(cfg[x]), "x")
	expect_identical(names(cfg[all_of(x)]), "letters")
	expect_snapshot(
		print(cfg[c("letters", "x")]),
		variant = snapshot_variant()
	)
})

test_that("`[` errors on unknown columns", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		cfg["nope"]
		cfg[9]
		cfg[TRUE]
		cfg[0]
		cfg[character(0)]
		cfg[, "x"]
		cfg[1, 2]
		cfg[[1, 2]]
		cfg[factros]
		cfg[t]
	})
})

test_that("a shinyfilters object's properties are read-only", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		cfg@data <- df_config
		cfg@args <- list(slider = TRUE)
		cfg@ns <- shiny::NS("m")
		cfg@overrides <- list()
		cfg@added <- character()
		cfg@replaced <- character()
		S7::set_props(cfg, ns = shiny::NS("m"))
	})
})

test_that("a changed shinyfilters object is still read-only", {
	cfg <- shinyfilters(df_config)
	namespaced <- with_ns(cfg, "m")
	defaulted <- with_defaults(cfg, slider = FALSE)
	overridden <- with_filters(cfg, x = "radio")
	selected <- cfg["x"]
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		namespaced@ns <- NULL
		defaulted@args <- list()
		overridden@overrides <- list()
		selected@data <- df_config
	})
})

test_that("functions that change a shinyfilters object are internal", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		call_as_user(S7::S7_class(cfg), data = df_config)
		call_as_user(._modify, cfg, data = df_config)
		call_as_user(._config_filtered, cfg, df_config)
		call_as_user(._set_overrides, cfg, list(x = list(input = identity)))
		call_as_user(._set_column, cfg, "y", rlang::quo(x * 2), NULL, "f")
		call_as_user(
			._override_cols,
			cfg,
			rlang::quo(x),
			rlang::quo("radio"),
			NULL,
			"f"
		)
		call_as_user(._select_columns, cfg, rlang::quo(x), "x", NULL)
	})
})

test_that("a shinyfilters object changed through its attributes is invalid", {
	unnamed <- shinyfilters(df_config)
	attr(unnamed, "args") <- list(TRUE)
	duplicated <- shinyfilters(df_config)
	attr(duplicated, "args") <- list(slider = TRUE, slider = FALSE)
	custom_ns <- shinyfilters(df_config)
	attr(custom_ns, "ns") <- function(id) id
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		S7::validate(unnamed)
		S7::validate(duplicated)
		S7::validate(custom_ns)
		with_defaults(unnamed, slider = TRUE)
	})
})

test_that("the `ns` property defaults to NULL", {
	expect_null(
		shinyfilters(data.frame(stringsAsFactors = FALSE, a = 1:3))@ns
	)
})

test_that("double bracket with no arguments suppliued returns the object", {
	cfg <- shinyfilters(df_config)
	expect_identical(cfg[[]], cfg)
})
