# Development Setup

This article walks through everything needed to set up a local
development environment for `cyclestatsv2` after cloning the repository.

## Prerequisites

- R \>= 4.1.0
- RStudio (recommended)
- Git

## 1. Clone and Open the Project

Clone the repository and open `cyclestatsv2.Rproj` in RStudio. Opening
the `.Rproj` file ensures the working directory, build tools, and
package settings are all configured correctly.

## 2. Install devtools

If `devtools` is not already installed:

``` r

install.packages("devtools")
```

## 3. Install All Dependencies

``` r

devtools::install_dev_deps()
```

This installs everything declared in `DESCRIPTION` — runtime
dependencies (`Imports`), optional dependencies (`Suggests`), and
build-time tools such as `roxygen2`, `testthat`, `lintr`, and `styler`.
It is safe to re-run at any time; already-installed packages are
skipped.

## 4. Build and Install the Package

Use **Build → Install** in RStudio, or run:

``` r

devtools::install()
```

## 5. Add the Data File

The app reads from a Strava bulk export. Place your `activities.csv` at:

    inst/extdata/activities.csv

To obtain this file, log in to Strava and go to **My Account → Download
or Delete Your Account → Request Your Archive**. The resulting zip
contains `activities.csv`.

The app expects the standard Strava export column layout and retains
only rows where `Activity Type == "Ride"`. Distances are converted from
kilometres to miles automatically.

## 6. Run the App

During development, load the package from source rather than the
installed copy:

``` r

pkgload::load_all()
run_app()
```

Alternatively, open `app.R` and click the **Run App** button in RStudio.
This also calls
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
under the hood via golem.

## Common Development Tasks

The `dev/` scripts follow the standard golem workflow:

| Script            | Purpose                                   |
|-------------------|-------------------------------------------|
| `dev/01_start.R`  | One-time project setup                    |
| `dev/02_dev.R`    | Add modules, dependencies, and run checks |
| `dev/03_deploy.R` | Deploy to Posit Connect / shinyapps.io    |

### Documenting and checking

``` r

# Regenerate documentation from roxygen2 comments
devtools::document()

# Run R CMD CHECK
devtools::check()

# Lint the codebase
lintr::lint_package()

# Auto-format code
styler::style_pkg()
```

### Testing

``` r

devtools::test()
```

### Deploying

``` r

rsconnect::deployApp()
```

## Docker

The included `Dockerfile` packages the app and all its dependencies into
a self-contained image based on `rocker/r-ver`. The app listens on port
3838 inside the container.

### Prerequisites

- Docker installed and running — [Docker
  Desktop](https://www.docker.com/products/docker-desktop/) on
  Windows/macOS, or the [Docker
  Engine](https://docs.docker.com/engine/install/) on Linux
- A [Docker Hub](https://hub.docker.com/) account with push access to
  `esimms999/cyclestatsv2`
- The data file present at `inst/extdata/activities.csv` before building
  — it is copied into the image at build time

### Build the image

Run from the repository root (where the `Dockerfile` lives):

``` bash
docker build -t esimms999/cyclestatsv2:latest .
```

To tag a specific version alongside `latest`:

``` bash
docker build -t esimms999/cyclestatsv2:latest -t esimms999/cyclestatsv2:2.00 .
```

### Push to Docker Hub

Log in (only required once per session), then push:

``` bash
docker login
docker push esimms999/cyclestatsv2:latest
```

If you also tagged a version:

``` bash
docker push esimms999/cyclestatsv2:2.00
```

### Run a container

Pull and run from Docker Hub:

``` bash
docker run --rm -p 3838:3838 esimms999/cyclestatsv2:latest
```

Then open <http://localhost:3838> in a browser. The `--rm` flag removes
the container automatically when it stops. To run it in the background
instead:

``` bash
docker run -d --name cyclestatsv2 -p 3838:3838 esimms999/cyclestatsv2:latest
```

Stop and remove the background container when done:

``` bash
docker stop cyclestatsv2 && docker rm cyclestatsv2
```
