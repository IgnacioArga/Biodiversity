# SERVER ####

# Aplicacion ####

function(input, output, session) {
  # Reconectar
  session$allowReconnect(FALSE)
  
  sever(
    html = sever_default(
      title    = "Ups...",
      subtitle = "Se desconectó la sesión.",
      button   = "Reconectar"
    )
  )
  

  # 1 - Login ---------------------------------------------------------------

  login_result <- login_server(
    id            = "login",
    connection_bq = pool_bq
  )
  
  # include text above login modal
  observeEvent(input$login_user, {
    shinyjs::runjs(
      'let h1Element = document.createElement("h1");
      let h3Element = document.createElement("h3");
      let dialog = document.querySelector("#shiny-modal");
      
      h1Element.textContent = "Welcome to the Global Biodiversity Information Facility report ";
      h3Element.innerHTML = "Follow me in  <a target=\\”_blank\\” href=\\"https://www.linkedin.com/in/ignacio-arganaraz-arriazu/?locale=en_US\\"> <i class=\\"fa-brands fa-linkedin\\"></i></a> <a target=\\”_blank\\” href=\\"https://github.com/IgnacioArga\\"> <i class=\\"fa-brands fa-github\\"></i></a>";
      
      h1Element.style.textAlign = "center";
      h3Element.style.textAlign = "center";
      
      dialog.insertBefore(h1Element, dialog.firstChild);
      dialog.insertBefore(h3Element, dialog.firstChild.nextSibling);'
    )
  },ignoreNULL = FALSE, once = TRUE)
  
  observe({
    req(login_result())
    shinyjs::runjs(
      'document.querySelector(".skin-black .wrapper").setAttribute("style", "visibility:visible");
      document.querySelector(".skin-black .main-sidebar").setAttribute("style", "visibility:visible")'
    )
  })

  # 2 - Body ----------------------------------------------------------------

  # * 2.0 Render Menu -------------------------------------------------------

  output$menu <- renderMenu({
    req(login_result())
    
    shinyjs::show("map_1_show")
    
    sidebarMenu(
      menuItem(
        text = 'map', 
        icon = icon('users'),
        menuSubItem(text = 'map 1', tabName = 'map_1', icon = icon('users'))
      ),
      div(
        actionBttn(
          inputId = 'data_source',
          label   = a(
            href   = 'https://www.gbif.org/',
            target = '_blank',
            HTML("<i class='fa fa-database' role='presentation' aria-label='database icon'></i> Data Source")
          ),
          style = 'bordered',
          size  = 'xs',
          block = TRUE
        ),
        align = 'center'
      )
    )
  })
  
  # 1 - Map --------------------
  
  # * 1. map 1 --------------------------------------------------------
  
  map_server(
    id            = "map_1_mod",
    connection_bq = pool_bq,
    login_result  = login_result
  )
  
  
}
