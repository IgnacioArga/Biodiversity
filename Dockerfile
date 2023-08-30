FROM rocker/shiny:4.0.5
# librerias extra
RUN apt-get update && apt-get install -y \
    libmariadbclient-dev \
    libssl-dev \
    libsodium-dev \
    curl \
    gnupg \
    libxml2-dev
# descargar drivers para MSSQL    
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

# control de versionado de R
ENV RENV_VERSION 0.17.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
COPY renv.lock renv.lock
RUN R -e 'renv::consent(provided = TRUE);renv::restore();'

# configuracion de servidor de shiny
COPY shiny-customized.config /etc/shiny-server/shiny-server.conf
RUN rm -rf /srv/shiny-server/*
COPY app/ /srv/shiny-server/