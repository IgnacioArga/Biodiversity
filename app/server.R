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
      let divElement = document.createElement("div");
      
      let dialog = document.querySelector("#shiny-modal");
      
      h1Element.textContent = "Welcome to the Global Biodiversity Information Facility Report";
      h3Element.innerHTML = "Find me on  <a target=\\”_blank\\” href=\\"https://www.linkedin.com/in/ignacio-arganaraz-arriazu/?locale=en_US\\"> <i class=\\"fa-brands fa-linkedin\\"></i></a> <a target=\\”_blank\\” href=\\"https://github.com/IgnacioArga\\"> <i class=\\"fa-brands fa-github\\"></i></a>";
      divElement.innerHTML = "Autor: <a target=\\”_blank\\” href=\\"https://unsplash.com/es/@hansjurgen007\\">Hans-Jurgen Mager</a>"; 
      
      h1Element.style.textAlign = "center";
      h3Element.style.textAlign = "center";
      divElement.classList.add("img_caption");
      
      dialog.insertBefore(h1Element, dialog.firstChild);
      dialog.insertBefore(h3Element, dialog.firstChild.nextSibling);
      dialog.insertBefore(divElement, dialog.lastChild.nextSibling);'
    )
  },ignoreNULL = FALSE, once = TRUE)
  
  observe({
    req(login_result())
    shinyjs::runjs(
      'document.querySelector(".skin-black .wrapper").setAttribute("style", "visibility:visible");
      document.querySelector(".skin-black .main-sidebar").setAttribute("style", "visibility:visible")'
    )
  })
  
  # 2 - Render Menu -------------------------------------------------------
  
  output$menu <- renderMenu({
    req(login_result())
    
    sidebarMenu(
      menuItem(
        text    = 'Species Locations', 
        icon    = icon('map-location-dot'),
        tabName = 'map'
      ),
      menuItem(
        text    = 'Time Line', 
        icon    = icon('chart-line'),
        tabName = 'timeline'
      ),
      hr(),
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
      ),
      div(
        actionBttn(
          inputId = 'linkedin',
          label   = a(
            href   = 'https://www.linkedin.com/in/ignacio-arganaraz-arriazu/?locale=en_US',
            target = '_blank',
            HTML("<i class='fa-brands fa-linkedin'></i> LinkedIn")
          ),
          style = 'bordered',
          size  = 'xs',
          block = TRUE
        ),
        align = 'center'
      ),
      div(
        actionBttn(
          inputId = 'github',
          label   = a(
            href   = 'https://github.com/IgnacioArga/Biodiversity',
            target = '_blank',
            HTML("<i class='fa-brands fa-github'></i> Github Repo")
          ),
          style = 'bordered',
          size  = 'xs',
          block = TRUE
        ),
        align = 'center'
      ),
      div(
        actionBttn(
          inputId = 'appsilon',
          label   = a(
            href   = 'https://appsilon.com/',
            target = '_blank',
            HTML("<img src='images/appsilon.png' style='height: 30px'></img> Appsilon Page")
          ),
          style = 'bordered',
          size  = 'xs',
          block = TRUE
        ),
        align = 'center'
      )
    )
  })
  

  # 3 - Data ----------------------------------------------------------------

  countries <- reactive({
    req(login_result())
    
    iv$enable()
    
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
      conn = pool_bq,
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
    
    Sys.sleep(0.2)
    closeSweetAlert(session = session)
    
    return(countries)
  })
  

  # 4 - Tabs ----------------------------------------------------------------

  # * 1. Map ----------------------------------------------------------------
  
  map_server(
    id            = "map_mod",
    connection_bq = pool_bq,
    login_result  = login_result,
    countries     = countries,
    input_country = reactive(input$country)
  )

  # * 2. Time Line ----------------------------------------------------------

  timeline_server(
    id            = "timeline_mod",
    connection_bq = pool_bq,
    login_result  = login_result,
    countries     = countries,
    input_country = reactive(input$country)
  )
  
  # 5 - Input Validator -----------------------------------------------------
  
  iv <- InputValidator$new()
  iv$add_rule("country", sv_required(message = "You must select a country"))
}
