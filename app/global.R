# 1 - renv & Config File ---------------------------------------------------

renv::consent(provided = TRUE); renv::restore();

# 2 - Libraries ------------------------------------------------------------

library(renv)
library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(shinydashboardPlus)
library(sever)
library(fresh)
library(leaflet)
library(DT)
library(pool)
library(bigrquery)
library(tibble)
library(dplyr)

# 3 - Connections ---------------------------------------------------------

bigrquery::bq_auth(
  path = ifelse(
    dir.exists("gcp"),
    "gcp/service_credential_bigquery.json",
    "app/gcp/service_credential_bigquery.json"
  )
)

pool_bq <- pool::dbPool(
  drv = bigrquery::bigquery(),
  project = "personal-cloud-397320",
  bigint = "integer"
)

# 4 - Modules -------------------------------------------------------------

invisible(lapply(list.files(path = "modules", full.names = TRUE), source))
