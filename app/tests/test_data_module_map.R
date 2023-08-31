library(shiny)
library(shinytest)
library(testthat)

# Carga tu módulo aquí si es necesario

# Define una función para ejecutar la aplicación de Shiny y realizar la prueba
test_my_module <- function() {
  
  library(shiny)
  library(shinytest)
  library(testthat)
  app <- ShinyDriver$new("app/")
  
  # Define el input correspondiente (input$country) para la prueba
  app$setInputs(country = "Poland")
  
  app$open()
  
  app$waitForElement(selector = "#module_login")
  app$set_inputs(`login-user` = "appsilon")
  app$set_inputs(`login-password` = "testing")
  app$click("login-login")
  
  # Espera a que los resultados estén listos
  app$waitForElement(selector = ".leaflet")
  
  # Ejecuta la función data()
  data <- app$getReactiveValue("data")
  
  # Realiza la prueba usando testthat
  expect_equal(nrow(data), 48461)
  
  app$stop()
}

# Ejecuta la prueba
test_my_module()
