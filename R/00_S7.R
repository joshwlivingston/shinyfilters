# R/00_S7.R
#
# For valid S7 method registration, S7 classes need to be defined first
class_reactivevalues <- new_S3_class(
	class = "reactivevalues",
	constructor = function(.data) NULL
)

class_reactiveExpr <- new_S3_class(
	class = "reactiveExpr",
	constructor = function(.data) NULL
)

class_tbl_df <- new_S3_class(
	class = "tbl_df",
	constructor = function(.data) NULL
)
