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
          inputId =  ns("country"),
          label   = "Country:",
          choices = NULL
        ) %>%
          shiny::tagAppendAttributes(style = 'width: 100%;'),
        hr(),
        radioGroupButtons(
          inputId = ns("specie_name"),
          label = "Specie:",
          choices = c("Scientific Name", "Vernacular Name"),
          checkIcon = list(
            yes = tags$i(
              class = "fa fa-check-square", 
              style = "color: steelblue"
            ),
            no = tags$i(
              class = "fa fa-square-o", 
              style = "color: steelblue"
            )
          )
        ),
        selectizeInput(
          inputId  =  ns("specie"),
          label    = NULL,
          choices  = NULL
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
#' @param login_result S4. BigQuery connection
#'
#' @return modulo pendencias serverside
map_server <- function(id,
                       connection_bq,
                       login_result) {
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      
      # 0 - Setup ---------------------------------------------------------------
      
      # * 1. Countries ----------------------------------------------------------

      countries <- reactive({
        req(login_result())
        timestamp("countries")
        
        progressSweetAlert(
          session     = session,
          id          = "progress_update_country",
          title       = tagList("Looking for countries...", loadingState()),
          display_pct = TRUE,
          value       = 0,
          striped     = TRUE,
          status      = "primary"
        )
        countries <- DBI::dbGetQuery(
          conn = connection_bq,
          "SELECT DISTINCT country
          FROM `personal-cloud-397320.Biodiversity.Occurrence`;"
        )
        updateSelectizeInput(
          session  = session,
          inputId  = "country",
          choices  = countries$country,
          selected = "Poland",
          options  = list(
            placeholder  = "Select Country...",
            onInitialize = I('function() { this.setValue(""); }'),
            maxItems     = 1,
            highlight    = FALSE
          ),
          server = TRUE
        )
        updateProgressBar(
          session = session,
          id      = "progress_update_country",
          value   = 100,
          status  = "success"
        )
        
        Sys.sleep(0.5)
        closeSweetAlert(session = session)
        
        return(countries)
      })

      # * 2. Species ------------------------------------------------------------
      
      factors <- eventReactive(input$country, {
        req(login_result())
        timestamp("factors")
        
        factors <- DBI::dbGetQuery(
          conn = connection_bq,
          glue::glue(
            "SELECT DISTINCT scientificName, vernacularName
            FROM `personal-cloud-397320.Biodiversity.Occurrence`
            WHERE country = '{country}';",
            country = input$country
          )
        )
        
        list(
          scientificName = unique(factors$scientificName),
          vernacularName = unique(factors$vernacularName)
        )
      })
      
      
      observeEvent(
        list(
          input$specie_name, 
          factors()
        ), {
          req(login_result(), factors())
          timestamp("input$specie_name, countries()")
          
          
          progressSweetAlert(
            session     = session,
            id          = "progress_update_specie",
            title       = tagList("Looking for species...", loadingState()),
            display_pct = TRUE,
            value       = 0,
            striped     = TRUE,
            status      = "primary"
          )
          
          if (input$specie_name == "Scientific Name") {
            updateSelectizeInput(
              session  = session,
              inputId  = "specie",
              choices  = factors()$scientificName,
              selected = character(0),
              options  = list(
                placeholder  = "Select Specie...",
                onInitialize = I('function() { this.setValue(""); }'),
                maxItems     = 1,
                highlight    = FALSE
              ),
              server = TRUE
            )
          } else {
            updateSelectizeInput(
              session  = session,
              inputId  = "specie",
              choices  = factors()$vernacularName,
              selected = character(0),
              options  = list(
                placeholder  = "Select Specie...",
                onInitialize = I('function() { this.setValue(""); }'),
                highlight    = FALSE
              ),
              server = TRUE
            )
          }
          
          updateProgressBar(
            session = session,
            id      = "progress_update_specie",
            value   = 100,
            status  = "success"
          )
          
          Sys.sleep(0.5)
          closeSweetAlert(session = session)
          
        }, ignoreInit = FALSE)
      
      
      # 1 - Obtengo la data -----------------------------------------------------
      
      data <- eventReactive(
        list(
          countries(),
          input$country
        ), {
          req(login_result(), input$country)
          timestamp("data")
          progressSweetAlert(
            session     = session,
            id          = "progress_data",
            title       = tagList("Loading Map...", loadingState()),
            display_pct = TRUE,
            value       = 0,
            striped     = TRUE,
            status      = "primary"
          )
          
          # specie <- if (input$specie_name == "Vernacular Name") {
          #   if (rlang::is_null(input$specie) || input$specie == "") {
          #     ""
          #   } else {  
          #     glue::glue_collapse(
          #       glue::glue(
          #         " AND vernacularName IN ('{specie}')", 
          #         specie = glue::glue_collapse(input$specie, sep = "', '")
          #       )
          #     )
          #   }
          # } else {
          #   if (rlang::is_null(input$specie) || input$specie == "") {
          #     ""
          #   } else {  
          #     glue::glue_collapse(
          #       glue::glue(
          #         " AND scientificName IN ('{specie}')", 
          #         specie = glue::glue_collapse(input$specie, sep = "', '")
          #       )
          #     )
          #   }
          # }
          
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
              country = '{country}'
            GROUP BY 
              country, 
              scientificName, 
              vernacularName, 
              longitudeDecimal, 
              latitudeDecimal;",
            country = input$country
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
      
      filtered_data <- eventReactive(
        list(
          data(),
          input$specie
        ), {
          
          if (rlang::is_null(input$specie) || input$specie == "") {
            data()
          } else if (input$specie_name == "Vernacular Name") {
            data() %>%
              filter(vernacularName == input$specie)
          } else {
            data() %>%
              filter(scientificName == input$specie)
          }
          
          
        })
      

      # 2 - Map -----------------------------------------------------------------

      output$map <- renderLeaflet({
        timestamp("map")
        leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          addCircleMarkers(
            data           = filtered_data(),
            lng            = ~longitudeDecimal,
            lat            = ~latitudeDecimal,
            clusterOptions = filtered_data()
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
        timestamp("table")
        shiny::validate(
          shiny::need(
            !rlang::is_null(filtered_data()) && nrow(filtered_data()) > 0,
            'No existen datos...'
          )
        )
        
        DT::datatable(
          filtered_data(),
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
      }, server = TRUE)

      # 5 - Input Validator -----------------------------------------------------

      iv <- InputValidator$new()
      iv$add_rule("country", sv_required(message = "You must select a country"))
      
    }
  )
}
