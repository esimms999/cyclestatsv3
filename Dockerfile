FROM rocker/r-ver:4.6.0

# System libraries required by R package dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libuv1 \
    && rm -rf /var/lib/apt/lists/*

# Use Posit Package Manager for pre-built Linux binaries (faster installs)
RUN echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))' \
    >> /usr/local/lib/R/etc/Rprofile.site

# Install remotes and fs (required by golem::favicon())
RUN Rscript -e "install.packages(c('remotes', 'fs'))"

# Cache dependency installation separately from app source.
# Only DESCRIPTION is copied here so this layer is reused when
# only the app code changes (not its dependencies).
COPY DESCRIPTION /build/cyclestatsv3/DESCRIPTION
RUN Rscript -e "remotes::install_deps( \
      '/build/cyclestatsv3', \
      dependencies = c('Depends', 'Imports', 'LinkingTo') \
    )"

# Copy full source and install the package
COPY . /build/cyclestatsv3
RUN R CMD INSTALL /build/cyclestatsv3

EXPOSE 3838

CMD ["Rscript", "-e", \
     "cyclestatsv3::run_app(options = list(host = '0.0.0.0', port = 3838))"]
