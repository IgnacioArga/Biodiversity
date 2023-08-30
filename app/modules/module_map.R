# Exportar funciones ------------------------------------------------------

#' @export map_ui
#' @export map_server
NULL

#' Module UI: map
#'
#' @param id
map_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      box(
        title       = HTML("Chooce Specie and Country"),
        status      = "danger",
        width       = 4,
        solidHeader = FALSE,
        collapsible = FALSE,
        collapsed   = FALSE,
        selectizeInput(
          inputId =  ns("specie"),
          label   = "Specie:",
          choices = NULL
        ) %>%
          shiny::tagAppendAttributes(style = 'width: 100%;'),
        selectizeInput(
          inputId =  ns("country"),
          label   = "Country:",
          choices = NULL
        ) %>%
          shiny::tagAppendAttributes(style = 'width: 100%;')
      ),
      tabBox(
        title = NULL,
        width = 8,
        tabPanel(
          title =  "Map",
          leafletOutput(outputId = ns("map"), height = "80vh")
        ),
        tabPanel(
          title =  "Table",
          DT::DTOutput(outputId = ns("table"))
        )
      )
    )
  )
}

#' @title Module Server: map
#'
#' @param id
#' @param connection_bq S4. BigQuery connection
#'
#' @return modulo pendencias serverside
map_server <- function(id,
                       connection_bq) {
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      
      
      # 0 - Factors -------------------------------------------------------------
      
      factors <- reactive({
        factors <- DBI::dbGetQuery(
          conn = connection_bq,
          glue::glue(
            "SELECT DISTINCT scientificName, vernacularName, country
            FROM `personal-cloud-397320.Biodiversity.Occurrence`;"
          )
        )
        
        list(
          scientificName = unique(factors$scientificName),
          vernacularName = unique(factors$vernacularName),
          country        = unique(factors$country)
        )
        
      })
      
      # 1 - Obtengo la data -----------------------------------------------------
      
      data <- reactive({
        
        progressSweetAlert(
          session     = session,
          id          = "progress_data",
          title       = tagList("Looking for species...", loadingState()),
          display_pct = TRUE,
          value       = 0,
          striped     = TRUE,
          status      = "primary"
        )
        
        data <- DBI::dbGetQuery(
          conn = connection_bq,
          glue::glue(
            "SELECT 
              country, 
              scientificName, 
              vernacularName, 
              longitudeDecimal, 
              latitudeDecimal, 
              count(1) AS Amount
            FROM `personal-cloud-397320.Biodiversity.Occurrence`
            WHERE 
              country = '{country}' AND 
              vernacularName = '{specie}'
            GROUP BY 
              country, 
              scientificName, 
              vernacularName, 
              longitudeDecimal, 
              latitudeDecimal;",
            specie  = factors()$vernacularName[[1]][1],
            country = factors()$country[[1]][1]
          )
        )
        
        updateProgressBar(
          session = session,
          id      = "progress_data",
          value   = 100,
          status  = "success"
        )
        
        Sys.sleep(0.5)
        closeSweetAlert(session = session)
        
        return(data)
        
      })
      

      # 2 - Map -----------------------------------------------------------------

      output$map <- renderLeaflet({
        leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addCircleMarkers(
            data           = data(),
            lng            = ~longitudeDecimal,
            lat            = ~latitudeDecimal,
            clusterOptions = data()
          ) %>%
          addMeasure(
            position          = "bottomleft",
            primaryLengthUnit = "meters",
            primaryAreaUnit   = "sqmeters",
            activeColor       = "#3D535D",
            completedColor    = "#7D4479"
          )
      })
      
      
      # 3 - Table ---------------------------------------------------------------
      
      output$table <- DT::renderDT({
        shiny::validate(
          shiny::need(
            !rlang::is_null(data()) && nrow(data()) > 0,
            'No existen datos...'
          )
        )
        
        DT::datatable(
          data(),
          selection = "single",
          rownames = FALSE,
          filter = 'top',
          style = "bootstrap",
          options = list(
            searchHighlight = TRUE,
            dom = 'tipr',
            pageLength = 20
          )
        )
      }, server = FALSE)
      
      # 5 - Refresh -------------------------------------------------------------
      
    }
  )
}
