# Exportar funciones ------------------------------------------------------

#' @export login_ui
#' @export login_server
NULL

#' Module UI: Login
#'
#' @param id Id
login_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    uiOutput(ns("modal_login"))
  )
}

#' Module Server: Login
#'
#' @param id Id
#' @param connection_bq S4. BigQuery connection
#'
#' @return Objeto S4 UserData
login_server <- function(id,
                         connection_bq) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      
      # 1 - Devolucion ----------------------------------------------------------
      
      return_values <- reactiveVal()
      
      # 2 - UI ------------------------------------------------------------------
      
      output$modal_login <- renderUI({
        showModal(
          div(
            modalDialog(
              title     = NULL,
              easyClose = FALSE,
              size      = "s",
              fade      = FALSE,
              footer    = NULL,
              textInput(
                inputId = ns("user"),
                label   = tagList(icon("user", class = "fa-solid fa-user"), "User"),
                width   = "100%"
              ),
              passwordInput(
                inputId = ns("password"),
                label   = tagList(icon("lock"), "Password"),
                width   = "100%"
              ),
              div(
                actionButton(
                  inputId = ns("login"),
                  label   = "Ingresar",
                  icon    = icon("sign-in-alt"),
                  style   = "background-color:forestgreen; color:white"
                ),
                align = "right"
              )
            ),
            tags$script(
              glue::glue(
                "document.getElementById('module_login').addEventListener('keyup', function(event) {{
                 if (event.keyCode === 13) {{
                   document.getElementById('{ns('login')}').click();
                 }}
               }});"
              )
            ),
            id = "module_login"
          )
        )
      })
      
      # * 1 - Cancelar ----------------------------------------------------------
      
      # observeEvent(input$cancel, {
      #   session$reload()
      # })
      
      # 3 - Login ---------------------------------------------------------------
      
      observeEvent(input$login, {
        shinyjs::disable("login")
        
        if (input$user == "" || input$password == "") {
          sendSweetAlert(
            session = session,
            title   = "Mmm...",
            text    = HTML("You should write an user and a password to login!"),
            type    = "warning",
            html    = TRUE
          )
          shinyjs::enable("login")
          req(input$user, input$password)
        }
        
        data <- DBI::dbGetQuery(
          conn = connection_bq,
          glue::glue(
            "SELECT 
              User, 
              Password
            FROM `personal-cloud-397320.Biodiversity.Users`
            WHERE
              User = '{user}' AND
              Password = '{password}';",
            user = input$user,
            password = input$password
          )
        )
        
        if (rlang::is_null(data) || nrow(data) == 0) {
          sendSweetAlert(
            session = session,
            title = "Mmm...",
            text  = HTML("User and/or password incorrect"),
            type  = "warning",
            html  = TRUE
          )
          return_values(NULL)
        } else {
          sendSweetAlert(
            session = session,
            title   = "Welcome!",
            type    = "success"
          )
          
          removeModal()
          
          return_values(data)
        }
        
        shinyjs::enable("login")
      })
      
      # 5 - Return values -------------------------------------------------------
      
      return(return_values)
    }
  )
}