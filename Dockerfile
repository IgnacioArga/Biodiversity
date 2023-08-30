FROM rocker/shiny:4.0.5

# --- Se instalan las librerias propias de Ubuntu --- #

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libsodium-dev \
    curl \
    gnupg
    
RUN apt-get install -y libgdal-dev 

# --- Configuracion Shiny --- #

COPY shiny-customized.config /etc/shiny-server/shiny-server.conf

# --- Instalo renv y copio lock.file --- #

RUN rm -rf /srv/*

WORKDIR /srv/shiny-server
RUN sudo chmod 777 /srv/shiny-server/renv/library/R-4.0/x86_64-pc-linux-gnu

ENV RENV_VERSION 0.17.3

RUN R -e "install.packages(c('remotes','jsonlite'), repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

COPY renv.lock renv.lock

# --- Actualizo librerias --- #

RUN R -e 'renv::activate();renv::consent(provided = TRUE);renv::restore()'

# --- Copia aplicacion --- #

COPY --chown=shiny:shiny app/ /srv/shiny-server/