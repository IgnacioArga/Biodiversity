#' Module UI: timeline
#'
#' @param id
timeline_ui <- function(id) {

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
            shiny::tagAppendAttributes(style = 'width: 100%;'),
          hr(),
          radioGroupButtons(
            inputId = ns("period"),
            label = "Period:",
            choices = c("Time Line", "Annual", "Monthly"),
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
          )
        ),
        valueBoxOutput(outputId = ns("box_species"), width = NULL),
        valueBoxOutput(outputId = ns("box_occurrence"), width = NULL)
      ),
      column(
        width = 9,
        plotlyOutput(outputId = ns("plot_date")),
        hr(),
        plotlyOutput(outputId = ns("plot_time"))
      )
    )
  )
}

#' @title Module Server: timeline
#'
#' @param id
#' @param connection_bq S4. BigQuery connection
#' @param login_result Dataframe. Login information, verify if it is null or not.
#' @param countries Reactive. List of countries.
#' @param input_country Character. Country selected.
#'
#' @return modulo pendencias serverside
timeline_server <- function(id,
                           connection_bq,
                           login_result,
                           countries,
                           input_country) {

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      # 0 - Setup ---------------------------------------------------------------

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

          progressSweetAlert(
            session     = session,
            id          = "progress_data",
            title       = tagList("Loading Plot...", loadingState()),
            display_pct = TRUE,
            value       = 0,
            striped     = TRUE,
            status      = "primary"
          )

          date <- DBI::dbGetQuery(
            conn = connection_bq,
            glue::glue(
              "SELECT
                country,
                scientificName,
                vernacularName,
                DATE_TRUNC(eventDate, MONTH) as eventDate,
                count(1) AS Amount
              FROM `personal-cloud-397320.Biodiversity.Occurrence`
              WHERE
                country = '{country}' AND
                eventDate IS NOT NULL
              GROUP BY
                country,
                scientificName,
                vernacularName,
                DATE_TRUNC(eventDate, MONTH);",
            country = input_country()
            )
          )

          time <- DBI::dbGetQuery(
            conn = connection_bq,
            glue::glue(
              "WITH data_time as (
                SELECT
                  country,
                  scientificName,
                  vernacularName,
                  SUBSTR(eventTime, 1, 2) || '' AS hour
                FROM `personal-cloud-397320.Biodiversity.Occurrence`
                WHERE
                  country = '{country}' AND
                  eventTime IS NOT NULL
              )
              SELECT
                country,
                scientificName,
                vernacularName,
                hour,
                count(1) AS Amount
              FROM data_time
              GROUP BY
                country,
                scientificName,
                vernacularName,
                hour;",
              country = input_country()
            )
          )

          data <- list(
            date = date,
            time = time
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
            list(
              date = data()$date %>% filter(vernacularName == input$specie),
              time = data()$time %>% filter(vernacularName == input$specie)
            )
          } else {
            list(
              date = data()$date %>% filter(scientificName == input$specie),
              time = data()$time %>% filter(scientificName == input$specie)
            )
          }

        })

      # 2 - Plot ----------------------------------------------------------------

      # * 1. Date ---------------------------------------------------------------

      output$plot_date <- renderPlotly({
        
        data <- filtered_data()$date %>% {
          data <- .
          if (input$period == "Time Line") {
            data %>% mutate(Period = eventDate)
          } else if (input$period == "Annual") {
            data %>% mutate(Period = lubridate::year(eventDate))
          } else {
            data %>% mutate(Period = lubridate::month(eventDate, label = TRUE, abbr = FALSE, locale = "us"))
          }
        } %>%
          group_by(Period) %>%
          summarise(
            Amount = sum(Amount)
          )

        plot_ly(
          data = data,
          x    = ~Period,
          y    = ~Amount,
          type = "bar"
        ) %>%
          layout(
            title = input$period,
            yaxis = list(title = "Total Amount"),
            hovermode = "closest"
          )
      })

      # * 2. Time ---------------------------------------------------------------
       
      output$plot_time <- renderPlotly({
        
        data <- filtered_data()$time %>% 
          mutate(hour = as.factor(hour)) %>% 
          group_by(hour) %>%
          summarise(
            Amount = sum(Amount)
          )
        
        plot_ly(
          data = data,
          x    = ~hour,
          y    = ~Amount,
          type = "bar"
        ) %>%
          layout(
            title = "Hour",
            yaxis = list(title = "Total Amount"),
            hovermode = "closest"
          )
      })
      
      # 4 - Box -----------------------------------------------------------------

      output$box_species <- renderValueBox({

        data_box <- if (input$specie_name == "Vernacular Name") {
          filtered_data()$date$vernacularName %>% unique() %>% length()
        } else {
          filtered_data()$date$scientificName %>% unique() %>% length()
        }

        valueBox(
          value = format(data_box, big.mark = ","),
          subtitle = "Total Species",
          icon = icon("leaf"),
          color = "green"
        )
      })

      output$box_occurrence <- renderValueBox({

        data_box <- filtered_data()$date$Amount %>% sum()

        valueBox(
          value = format(data_box, big.mark = ","),
          subtitle = "Total Occurrences",
          icon = icon("eye"),
          color = "green"
        )
      })
    }
  )
}
