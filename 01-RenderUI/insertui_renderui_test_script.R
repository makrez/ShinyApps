## This script is for testing inserui and removeui 

## Test data

library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)

########################################################################################
######                          USER INTERFACE                                    ######
########################################################################################

ui <- dashboardPage(
  dashboardHeader(),
  
  dashboardSidebar(
    actionButton("add", "Add"),
    radioButtons("add_elements", "Elements", c("Element1",	"Element2")),
    actionButton("remove", "Remove"),
    hr(),
    actionButton("add2", "Add"),
    radioButtons("add_plots", "Plots", c("Plot1", "Plot2")),
    actionButton("remove_plots", "Remove"),
    hr(),
    div(style = "position:absolute;right:4em;", downloadButton("report", "Generate report"))
  ),
  dashboardBody(
    fluidRow(
      tags$div(id="placeholder")
  )
  )
)

########################################################################################
######                          SERVER FUNCTIONS                                  ######
########################################################################################


server <- function(input, output, session) {

# Test data set
  
a<-(letters)
b<-rnorm(length(letters), 4,2)
c<-rnorm(length(letters), 10,15)
d<-c(1:10,20:30,45:49)

data<-data.frame(a,b,c,d)
names(data)<-c("name","v1","v2","v3")

# Initialize empty vectors

inserted<- c()
inserted_plots <- c()

### Elements ###

observeEvent(input$add, {
  id_add <- paste0(input$add, input$add_elements)
  insertUI(selector = '#placeholder', where = "afterEnd",
           ui= switch(input$add_elements,
                      'Element1'= plotOutput(id_add),
                      'Element2' = plotOutput(id_add))
  )

  output[[id_add]] <- 
    if (input$add_elements == "Element1") renderPlot({ 
      plot(data[,1],data[,2])
      })
    else if (input$add_elements == "Element2") renderPlot({
      g<-ggplot(data=data, aes(x=data[,1], y=data[,4])) + geom_point()
      plot(g)
    })
  inserted <<- c(id_add,inserted)
})

### Remove Elements ###
observeEvent(input$remove, {
  removeUI(
    ## pass in appropriate div id
    selector = paste0('#', inserted[length(inserted)])
  )
  inserted <<- inserted[-length(inserted)]
})

### Plots ###

observeEvent(input$add2, {
  id_plots <- paste0(input$add2, input$add_plots)
  insertUI(selector = '#placeholder', where = "afterEnd",
           ui= switch(input$add_plots,
                      'Plot1'= plotOutput(id_plots),
                      'Plot2' = plotOutput(id_plots))
  )
  
  output[[id_plots]] <- 
    if (input$add_plots == "Plot1") renderPlot({ 
      plot(data[,3],data[,4])
    })
  else if (input$add_plots == "Plot2") renderPlot({
  plot(data[,2],data[,4])
    })
  inserted_plots <<- c(id_plots,inserted_plots)
})

### Remove Plots ###
observeEvent(input$remove_plots, {
  removeUI(
    ## pass in appropriate div id
    selector = paste0('#', inserted_plots[length(inserted_plots)])
  )
  inserted_plots <<- inserted_plots[-length(inserted_plots)]
})

}

shinyApp(ui = ui, server = server)