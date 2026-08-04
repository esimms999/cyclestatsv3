# Run the cyclestatsv2 Shiny Application

Main entry point. Initialises data then launches the app.

## Usage

``` r
run_app(
  on_start = NULL,
  options = list(),
  enable_bookmarking = NULL,
  ui_pattern = "/",
  ...
)
```

## Arguments

- on_start:

  Passed to
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

- options:

  Named list of options passed to
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

- enable_bookmarking:

  Passed to
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

- ui_pattern:

  Passed to
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

- ...:

  Additional arguments passed as golem options.
