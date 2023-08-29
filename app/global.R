# 1 - renv & Config File ---------------------------------------------------

renv::consent(provided = TRUE); renv::restore();

config <- config::get(
  file = ifelse(
    file.exists("config"),
    "config.yml",
    "app/config.yml"
  )
)

# 2 - Libraries ------------------------------------------------------------

libraries <- list(
  "Reproduccion" = list("renv", "config"),
  "Shiny Core"   = list("shiny", "shinydashboard"),
  "Shiny Extras" = list("shinyjs", "shinyWidgets", "shinydashboardPlus", "sever", "fresh"),
  "Tables"       = list("DT"),
  "DDBB"         = list("pool", "bigrquery"),
  "Tidyverse"    = list("tibble", "dplyr")
)

purrr::walk(
  .x = c(libraries, recursive = TRUE, use.names = FALSE),
  .f = function(x) {
    library(
      package        = x,
      character.only = TRUE,
      warn.conflicts = !quietly,
      quietly        = quietly
    )
  }
)

rm("libraries")

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
  project = config$bigquery$project,
  bigint = "integer"
)

# 4 - Modules -------------------------------------------------------------

