# UI ----------------------------------------------------------------------

dashboardPage(
  skin = "black",
  title = "GBIF Report",
  freshTheme = create_theme(
    adminlte_global(
      content_bg  = "#fcfcfc",
      box_bg      = "#ffffff",
      info_box_bg = "#ffffff"
    ),
    adminlte_sidebar(
      dark_bg                  = "#396c3b",
      dark_hover_bg            = "#2b5230", 
      dark_color               = "#d6d2d9"
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
  
  # Head ----------------------------------------------------------------
  
  header = dashboardHeader(
    title = div(
      tags$i(
        class = "fa-solid fa-seedling",
        style = "color: #55862d;"
      ),
      "GBIF Report"
    ),
    leftUi = tagList(
      dropdownButton(
        circle = FALSE,
        status = "success",
        size = "default",
        label = "Change Location",
        icon = icon("plane-departure"),
        selectizeInput(
          inputId = "country",
          label   = "Country:",
          choices = NULL
        )
      )
    )
  ),
  
  # Sidebar ---------------------------------------------------------
  
  sidebar = dashboardSidebar(
    includeCSS("www/styles.css"),
    useShinyjs(),
    useSweetAlert(),
    useSever(),
    tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico")),
    use_googlefont("Roboto"),
    sidebarMenuOutput("menu")
  ),
  
  # Body ------------------------------------------------------------------
  
  body = dashboardBody(
    login_ui("login"),
    tabItems(
      tabItem(
        tabName = "map",
        map_ui(id = "map_mod")
      ),
      tabItem(
        tabName = "timeline",
        timeline_ui(id = "timeline_mod")
      )
    )
  )# cierra el body del dashboard
)# cierra el dashboard page
