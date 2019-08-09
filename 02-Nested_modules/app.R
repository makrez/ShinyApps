library(shiny)
library(shinydashboard)
library(ggplot2)
library(shinydashboardPlus)
innerUI <- function(id){
  ns <- NS(id)
  fluidRow(
    plotOutput(ns("plot"))
  )
}

inner <- function(input, output, session){
  dat <- mtcars
  output$plot <-  renderPlot({
    ggplot(data = dat, aes(x=mpg, y=cyl)) + geom_point()
  })
}

outerUI <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      widgetUserBox(
        title = "title",
        width = 12,
        type = 2,
        src = "",
        color = "blue",
        innerUI(ns("inner1")),
        box(
          solidHeader = FALSE,
          title = "Testing nested modules",
          background = NULL,
          width = 12,
          status = "danger",
          footer = fluidRow(
            column(
              width = 6,
              descriptionBlock(
                number = "", 
                number_color = "green", 
                number_icon = "fa fa-caret-up",
                header = "", 
                text = "", 
                right_border = TRUE,
                margin_bottom = FALSE
              )
            ),
            column(
              width = 6,
              descriptionBlock(
                number = "", 
                number_color = "red", 
                number_icon = "fa fa-caret-down",
                header = "", 
                text = "", 
                right_border = FALSE,
                margin_bottom = FALSE
              )
            )
          )
        ),
        footer = "The footer here!"
      ))
  )
}

outer <- function(input, output, session){
  callModule(inner, "inner1")
}
ui <- shinyUI(
  dashboardPagePlus(
    dashboardHeader(),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Upper Level", 
                 tabName = "tab_upper", 
                 icon = icon("dashboard")),
        menuItem("Nested Module",
                 tabName = "tab_nested",
                 icon = icon("dashboard"))
      )),
    dashboardBody(
      tabItems(
        tabItem(tabName = "tab_upper",
                innerUI("first"),
                innerUI("second")
        ),
        tabItem(tabName = "tab_nested",
                outerUI("first"),
                outerUI("second"))
      )
  ))
)

server <- function(input, output) {
  # get historical data
  callModule(inner,"first")
  callModule(inner,"second")
  callModule(outer, "first")
  callModule(outer, "second")
}

shinyApp(server = server, ui = ui)

