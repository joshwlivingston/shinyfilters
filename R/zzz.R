# nocov start
.onLoad <- function(libname, pkgname) {
	if ("S7_on_load" %in% getNamespaceExports("S7")) {
		getExportedValue("S7", "S7_on_load")()
	} else {
		S7::methods_register()
	}
}
# nocov end

# nocov start
.onUnload <- function(...) {
	if ("S7_on_unload" %in% getNamespaceExports("S7")) {
		getExportedValue("S7", "S7_on_unload")()
	}
}
# nocov end

if ("S7_on_build" %in% getNamespaceExports("S7")) {
	getExportedValue("S7", "S7_on_build")()
}
