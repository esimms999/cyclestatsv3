#' Run the cyclestatsv3 Shiny Application
#'
#' Main entry point. Initialises data then launches the app.
#'
#' @param on_start Passed to [shiny::shinyApp()].
#' @param options Named list of options passed to [shiny::shinyApp()].
#' @param enable_bookmarking Passed to [shiny::shinyApp()].
#' @param ui_pattern Passed to [shiny::shinyApp()].
#' @param ... Additional arguments passed as golem options.
#'
#' @export
run_app <- function(
  on_start = NULL,
  options = list(),
  enable_bookmarking = NULL,
  ui_pattern = "/",
  ...
) {
  cyclestats_init()

  golem::with_golem_options(
    app = shiny::shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = on_start,
      options = options,
      enableBookmarking = enable_bookmarking,
      uiPattern = ui_pattern
    ),
    golem_opts = list(...)
  )
}
