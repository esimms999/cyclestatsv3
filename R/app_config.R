# Helper to resolve paths within the installed package.
.app_pkg <- "cyclestats"
app_sys <- function(...) {
  system.file(..., package = .app_pkg)
}
