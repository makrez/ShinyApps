source(here::here("www/utils.R"))

ui <-   dashboardPage(
  dashboardHeader(
    disable = TRUE
  ),
  dashboardSidebar(
    disable = TRUE
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    # fluidRow(
    #   div(class="infobox",
    #   tabBox(
    #     title = "Infobox",
    #     # The id lets us use input$tabset1 on the server to find the current tab
    #     id = "tabset1", height = "250px",
    #     tabPanel("General Information", general_information_txt),
    #     tabPanel("On Target Reads", on_target_reads_txt)
    #   ))
    # ),
    tabsetPanel(
      tabPanel("Main",
               div(class = "controls",
                   div(class = "params_row1",
                       div(class = "params_row1_e1",
                           numericInput("duplicates", "Duplicates %", value = 2)),
                       div(class = "params_row1_e2",
                           numericInput("read_length", "Total Read Length (e.g. 500 for 2x250)", 
                                        value = 500)),
                       div(class = "params_row1_e3",
                           numericInput("target_coverage", "Target Coverage", value = 40))),
                   div(class = "params_row2",
                       div(class = "params_row2_e1",
                           selectInput("sequencer", "Sequencer/Kit",choices = c("MiSeq/v2",
                                                                                "MiSeq/v3",
                                                                                "MiSeq/v2 Micro",
                                                                                "MiSeq/v2 Nano",
                                                                                "NextSeq/ High Output",
                                                                                "NextSeq/ Mid Output"))),
                       div(class = "params_row2_e2",
                           numericInput("genome_size", "Genome Size (in Mbps)", value=(10))),
                       div(class = "params_row2_e3",
                           sliderInput("on_target_slider",
                                       "On Target Reads",
                                       value = 100,
                                       min = 1,
                                       max = 100,
                                       step = 0.5)))),
    div(class = "dashboard_text_sequencer",
    verbatimTextOutput("best_samplenumber")),
    plotlyOutput("coverage_plot")
  ),
  tabPanel("Report",
           textInput("author", "Author"),
           textInput("project", "Project"),
           textInput("projectid", "Project ID"),
           downloadButton("report", "Generate report")),
  tabPanel("Documentation",
           includeMarkdown(here::here("www/documentation.Rmd")))
  )
  )
)