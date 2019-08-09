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
    div(id = "input_row1",
        # numericInput("select_sequencer", "Output in bps", value = (12000000*250)),
        selectInput("sequencer", "Sequencer",choices = c("MiSeq v2 kit",
                                                         "MiSeq v3 kit")),
        numericInput("genome_size", "Genome Size", value=(170000)),
        sliderInput("on_target_slider",
                    "On Target Reads",
                    value = 5,
                    min = 1,
                    max = 10,
                    step = 0.5)),
    div(id="input2_row2",
        numericInput("x_minimum", "X Min", value = 0),
        numericInput("x_maximum", "X Max", value = 100),
        numericInput("target_coverage", "Target Coverage", value = 40)),
    plotlyOutput("coverage_plot")
  )
)