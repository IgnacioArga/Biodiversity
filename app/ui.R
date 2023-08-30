# UI ----------------------------------------------------------------------

dashboardPage(
  skin = "black",
  title = "GBIF Report",
  freshTheme = create_theme(
    adminlte_global(
      content_bg  = "#fcfcfc !important",
      box_bg      = "#ffffff !important",
      info_box_bg = "#ffffff !important"
    ),
    adminlte_sidebar(
      dark_bg                  = "#396c3b",  # Verde predominante
      dark_hover_bg            = "#2b5230",  # Verde más oscuro para el hover
      dark_color               = "#d6d2d9",
      dark_submenu_bg          = "#000000",  # Verde oscuro para los submenús
      dark_submenu_color       = "#b2b2b2",
      dark_submenu_hover_color = "#ffffff"
    ),
    adminlte_color(
      light_blue = "#31749B",
      red        = "#D13823",
      green      = "#008F4F",
      aqua       = "#00A3CC",
      yellow     = "#D5880B",
      blue       = "#005A8F",
      navy       = "#000A14",
      teal       = "#2EB2B2",
      olive      = "#348360",
      lime       = "#00E061",
      orange     = "#F57200",
      fuchsia    = "#D30DA5",
      purple     = "#524F92",
      maroon     = "#B61651",
      black      = NULL,
      gray_lte   = "#C4C9D4"
    )
  ),
  
  # Cabecera ----------------------------------------------------------------
  
  header = dashboardHeader(
    title = div(
      tags$i(
        class = "fa-solid fa-seedling",
        style = "color: #55862d;"
      ),
      "GBIF Report"
    )
  ),
  
  # Barra Izquierda ---------------------------------------------------------
  
  sidebar = dashboardSidebar(
    includeCSS("www/styles.css"),
    useShinyjs(),
    useSweetAlert(),
    useSever(),
    tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico")),
    use_googlefont("Quicksand"),
    sidebarMenuOutput("menu")
  ),
  
  # Cuerpo ------------------------------------------------------------------
  
  body = dashboardBody(
    login_ui("login"),  
    # CONTENIDO TABS --------------------
    
    # 2 - map -----------------------------------------------------------
    
    # * 1. map 1 --------------------------------------------------------
    
    tabItem(
      tabName = "map_1",
      hidden(
        div(
          id = "map_1_show",
          map_ui(id = "map_1_mod")
        )
      )
    )
  )# cierra el body del dashboard
)# cierra el dashboard page
