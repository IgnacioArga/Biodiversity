FROM rocker/shiny:4.0.5

# --- Se instalan las librerias propias de Ubuntu --- #

RUN apt-get update && apt-get install -y \
    libmariadbclient-dev \
    libssl-dev \
    libsodium-dev \
    curl \
    gnupg

RUN apt-get install -y libgdal-dev default-libmysqlclient-dev libmysqlclient-dev

# --- Configuracion Shiny --- #

COPY shiny-customized.config /etc/shiny-server/shiny-server.conf

# --- Google Cloud CLI --- #

ARG ARG_PROJECT_ID
ENV PROJECT_ID $ARG_PROJECT_ID-y
    
RUN mkdir gcp

COPY app/gcp gcp

# --- Instalo renv y copio lock.file --- #

RUN rm -rf /srv/*

ENV RENV_VERSION 0.17.3
RUN R -e "install.packages(c('remotes','jsonlite'), repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

COPY renv.lock renv.lock

# --- Actualizo librerias --- #

RUN R -e 'renv::activate();renv::consent(provided = TRUE);renv::restore()'

# --- Copia aplicacion --- #

COPY --chown=shiny:shiny app/ /srv/shiny-server/
COPY --chown=shiny:shiny NEWS.md /srv/shiny-server/www/
