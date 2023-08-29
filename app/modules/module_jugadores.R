#' # Exportar funciones ------------------------------------------------------
#' 
#' #' @export map_ui
#' #' @export map_server
#' NULL
#' 
#' #' Module UI: map
#' #'
#' #' @param id
#' map_ui <- function(id) {
#'   
#'   ns <- NS(id)
#'   
#'   tagList(
#'     fluidRow(
#'       box(
#'         title       = HTML("Chooce Specie and Country"),
#'         status      = "danger",
#'         width       = 4,
#'         solidHeader = FALSE,
#'         collapsible = FALSE,
#'         collapsed   = FALSE,
#'         selectizeInput(
#'           inputId =  ns("specie"),
#'           label   = "Specie:",
#'           choices = NULL
#'         ) %>%
#'           shiny::tagAppendAttributes(style = 'width: 100%;'),
#'         selectizeInput(
#'           inputId =  ns("country"),
#'           label   = "Country:",
#'           choices = NULL
#'         # ) %>%
#'           shiny::tagAppendAttributes(style = 'width: 100%;')
#'       ),
#'       tabBox(
#'         title = NULL,
#'         width = 8,
#'         tabPanel(
#'           title =  "Map",
#'           leafletOutput(outputId = ns("map"), height = "80vh")
#'         ),
#'         tabPanel(
#'           title =  "Detail",
#'           DT::DTOutput(outputId = ns("tabla"))
#'         )
#'       )
#'     )
#'   )
#' }
#' 
#' #' @title Module Server: map
#' #'
#' #' @param id
#' #' @param connection_bq S4. BigQuery connection
#' #'
#' #' @return modulo pendencias serverside
#' map_server <- function(id,
#'                        connection_bq) {
#'   
#'   moduleServer(
#'     id = id,
#'     module = function(input, output, session) {
#'       ns <- session$ns
#'       
#' 
#'       # 0 - Factors -------------------------------------------------------------
#'       
#'       factors <- reactive({
#'         start <- Sys.time()
#'         scientificName <- DBI::dbGetQuery(
#'           conn = connection_bq,
#'           glue::glue(
#'             "SELECT DISTINCT scientificName
#'             FROM `personal-cloud-397320.Biodiversity.Occurrence`;"
#'           )
#'         )
#'         
#'         vernacularName <- DBI::dbGetQuery(
#'           conn = connection_bq,
#'           glue::glue(
#'             "SELECT DISTINCT vernacularName
#'             FROM `personal-cloud-397320.Biodiversity.Occurrence`;"
#'           )
#'         )
#'         
#'         country <- DBI::dbGetQuery(
#'           conn = connection_bq,
#'           glue::glue(
#'             "SELECT DISTINCT country
#'             FROM `personal-cloud-397320.Biodiversity.Occurrence`;"
#'           )
#'         )
#'         end <- Sys.time()
#'         difftime(end,start)
#'         list(
#'           scientificName = scientificName,
#'           vernacularName = vernacularName,
#'           country        = country
#'         )
#'         
#'       })
#'       
#'       # 1 - Obtengo la data -----------------------------------------------------
#'       
#'       data <- reactive({
#'         
#'         data <- DBI::dbGetQuery(
#'           conn = connection_bq,
#'           glue::glue(
#'             "SELECT scientificName, vernacularName, longitudeDecimal, latitudeDecimal, count(1) AS Amount
#'             FROM `personal-cloud-397320.Biodiversity.Occurrence`
#'             WHERE country = '{country}' AND vernacularName = '{specie}'
#'             GROUP BY scientificName, vernacularName, longitudeDecimal, latitudeDecimal;",
#'             specie  = factors()$vernacularName,
#'             country = factors()$country
#'           )
#'         )
#'         
#'         return(data)
#'         
#'       })
#'       # 3 - Genero tabla --------------------------------------------------------
#'       
#'       output$tabla <- DT::renderDT({
#'         shiny::validate(
#'           shiny::need(
#'             !rlang::is_null(data()) && nrow(data()) > 0,
#'             'No existen datos...'
#'           )
#'         )
#'         
#'         DT::datatable(
#'           data(),
#'           selection = "single",
#'           rownames = FALSE,
#'           filter = 'top',
#'           style = "bootstrap",
#'           options = list(
#'             searchHighlight = TRUE,
#'             dom = 'tipr',
#'             pageLength = 20
#'           )
#'         )
#'       }, server = FALSE)
#'       
#'       # 5 - Refresh -------------------------------------------------------------
#'       
#'     }
#'   )
#' }
