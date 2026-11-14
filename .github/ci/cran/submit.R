# Builds the package with its PDF manual and submits it, with
# cran-comments.md, through CRAN's web form. CRAN then emails the maintainer
# to confirm. upload_cran() is internal to devtools; cran/action.yml pins the
# devtools version.

built <- pkgbuild::build(".", tempdir(), manual = TRUE)
devtools:::upload_cran(".", built)
