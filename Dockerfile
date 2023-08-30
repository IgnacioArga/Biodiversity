FROM rocker/shiny:4.0.5

# --- Se instalan las librerias propias de Ubuntu --- #

RUN apt-get update && apt-get install -y \
    libmariadbclient-dev \
    libssl-dev \
    libsodium-dev \
    curl \
    gnupg

RUN apt-get install -y libgdal-dev default-libmysqlclient-dev libmysqlclient-dev

# --- Se descargan drivers para SQL Server y se actualizan librerias --- #

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update -qq && \
    ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    mssql-tools \
    unixodbc-dev
    
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

RUN ["/bin/bash", "-c", "source ~/.bashrc "]

# --- Configuracion Shiny --- #

COPY shiny-customized.config /etc/shiny-server/shiny-server.conf

# --- Instalo renv y copio lock.file --- #

USER shiny

RUN rm -rf /srv/*

WORKDIR /srv/shiny-server

ENV RENV_VERSION 0.17.3
RUN R -e "install.packages(c('remotes','jsonlite'), repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

COPY renv.lock renv.lock

RUN R -e 'renv::activate();renv::consent(provided = TRUE);renv::restore()'

# --- Copia aplicacion --- #

COPY --chown=shiny:shiny app/ /srv/shiny-server/