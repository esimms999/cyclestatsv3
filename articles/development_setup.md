# Development Setup

This article walks through everything needed to set up a local
development environment for `cyclestatsv3` after cloning the repository.

## Prerequisites

- R \>= 4.1.0
- RStudio (recommended)
- Git

## 1. Clone and Open the Project

Clone the repository and open `cyclestatsv3.Rproj` in RStudio. Opening
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

The app reads from a pre-downloaded [Ride with
GPS](https://ridewithgps.com/) export.

To obtain this file, run `data-raw/get_data.R`. It authenticates against
the Ride with GPS API using your API key and auth token, paginates
through all of your trips, and writes the processed result to
`inst/extdata/activities.rds`. The script retains only cycling
activities and converts distances from meters to miles automatically.

### Set up your API credentials

`data-raw/get_data.R` reads your Ride with GPS API key and auth token
from the `RWGPS_API_KEY` and `RWGPS_AUTH_TOKEN` environment variables —
it does not contain any credentials itself. Store these in a
project-level `.Renviron` file, which is excluded from version control
by `.gitignore` and must never be committed.

**1. Open (or create) the project’s `.Renviron` file:**

``` r

usethis::edit_r_environ("project")
```

**2. Add your credentials, one per line, with no quotes and no spaces
around `=`:**

    RWGPS_API_KEY=your-api-key-here
    RWGPS_AUTH_TOKEN=your-auth-token-here

**3. Save the file, then restart R** (Session → Restart R) so the new
environment variables are loaded.

**4. Verify they’re picked up:**

``` r

Sys.getenv("RWGPS_API_KEY")
Sys.getenv("RWGPS_AUTH_TOKEN")
```

You can find your API key and auth token in your [Ride with
GPS](https://ridewithgps.com/) account settings under API access. If
`RWGPS_API_KEY` or `RWGPS_AUTH_TOKEN` are missing when
`data-raw/get_data.R` runs, the script stops with an error rather than
proceeding without credentials.

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
  `esimms999/cyclestatsv3`
- The data file present at `inst/extdata/activities.rds` before building
  — it is copied into the image at build time

### Build the image

Run from the repository root (where the `Dockerfile` lives):

``` bash
docker build -t esimms999/cyclestatsv3:latest .
```

To tag a specific version alongside `latest`:

``` bash
docker build -t esimms999/cyclestatsv3:latest -t esimms999/cyclestatsv3:2.00 .
```

### Push to Docker Hub

Log in (only required once per session), then push:

``` bash
docker login
docker push esimms999/cyclestatsv3:latest
```

If you also tagged a version:

``` bash
docker push esimms999/cyclestatsv3:2.00
```

### Run a container

Pull and run from Docker Hub:

``` bash
docker run --rm -p 3838:3838 esimms999/cyclestatsv3:latest
```

Then open <http://localhost:3838> in a browser. The `--rm` flag removes
the container automatically when it stops. To run it in the background
instead:

``` bash
docker run -d --name cyclestatsv3 -p 3838:3838 esimms999/cyclestatsv3:latest
```

Stop and remove the background container when done:

``` bash
docker stop cyclestatsv3 && docker rm cyclestatsv3
```
