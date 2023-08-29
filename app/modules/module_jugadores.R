# Exportar funciones ------------------------------------------------------

#' @export jugadores_ui
#' @export jugadores_server
NULL

#' Module UI: jugadores
#'
#' @param id
jugadores_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(
        width = 12,
        tabBox(
          id = ns("tab"),
          width = NULL,
          title = tagList(
            div(
              actionButton(
                inputId = ns("nuevo"),
                label = "Nuevo Jugador",
                icon = icon("plus"),
                style = "background-color:forestgreen; color:white"
              )
              ,
              actionButton(
                inputId = ns("editar"),
                label = "Editar",
                icon = icon("pencil"),
                style = "background-color:cornflowerblue; color:white"
              ),
              actionButton(
                inputId = ns("delete"),
                label   =  "Eliminar",
                icon    = icon("trash"),
                style   = "background-color:indianred; color:white"
              ),
              # descargar_ui(ns("descargar"), "Descargar Info"),
              style = "display: -webkit-box;"
            )
          ),
          tabPanel(
            title = "Jugadores",
            div(
              style = 'overflow-x: scroll;font-size:90%',
              DT::DTOutput(ns('tabla'))
            )
          )
        )
      )
    )
  )
}

#' @title Module Server: jugadores
#'
#' @description `r lifecycle::badge('experimental')`
#' @param id
#'
#' @return modulo pendencias serverside
jugadores_server <- function(id) {
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      
      # 1 - Obtengo la data -----------------------------------------------------
      
      data <- reactive({
        datasets::mtcars
      })
      # 3 - Genero tabla --------------------------------------------------------
      
      output$tabla <- DT::renderDT({
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
      
      # 4 - Botones -------------------------------------------------------------
      
      # * 2. Descargo data ------------------------------------------------------
      
      # descargar_server(
      #   id   = "descargar",
      #   data = reactive({
      #     if (length(input$tabla_rows_all) > 0) {
      #       data() %>%
      #         slice(input$tabla_rows_all) %>%
      #         list()
      #     } else {
      #       NULL
      #     }
      #   }),
      #   name = reactive("Jugadores"),
      #   namesheet = reactive("Jugadores"),
      #   tableStyle = "TableStyleMedium9"
      # )
      
      # 5 - Refresh -------------------------------------------------------------
      
    }
  )
}