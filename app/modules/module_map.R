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
      column(
        width = 3,
        box(
          title       = HTML("Filter Parameters"),
          status      = "success",
          width       = NULL,
          solidHeader = FALSE,
          collapsible = FALSE,
          collapsed   = FALSE,
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
        valueBoxOutput(outputId = ns("box_species"), width = NULL),
        valueBoxOutput(outputId = ns("box_occurrence"), width = NULL)
      ),
      tabBox(
        title = NULL,
        width = 9,
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
                       login_result,
                       countries,
                       input_country) {
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      
      # 0 - Setup ---------------------------------------------------------------
      
      # * 2. Species ------------------------------------------------------------
      
      factors <- eventReactive(input_country(), {
        req(login_result())
        timestamp("factors")
        
        factors <- DBI::dbGetQuery(
          conn = connection_bq,
          glue::glue(
            "SELECT DISTINCT scientificName, vernacularName
            FROM `personal-cloud-397320.Biodiversity.Occurrence`
            WHERE country = '{country}';",
            country = input_country()
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
          input_country()
        ), {
          req(login_result(), input_country())
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
            country = input_country()
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

      # 4 - Box -----------------------------------------------------------------
      
      output$box_species <- renderValueBox({
        
        data_box <- if (input$specie_name == "Vernacular Name") {
          filtered_data()$vernacularName %>% unique() %>% length()
        } else {
          filtered_data()$scientificName %>% unique() %>% length()
        }
        
        valueBox(
          value = format(data_box, big.mark = ","),
          subtitle = "Total Species",
          icon = icon("leaf"),
          color = "green"
        )
      })
      
      output$box_occurrence <- renderValueBox({
        
        data_box <- filtered_data() %>% nrow()
        
        valueBox(
          value = format(data_box, big.mark = ","),
          subtitle = "Total Occurrence",
          icon = icon("eye"),
          color = "green"
        )
      })
      

      # 5 - Input Validator -----------------------------------------------------

      iv <- InputValidator$new()
      iv$add_rule("country", sv_required(message = "You must select a country"))
      
    }
  )
}
