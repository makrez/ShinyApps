server <- function(input, output, session){
  
  plot_list <<- list()
  
  clusters <- reactive({
    if (input$sequencer == "MiSeq/v2") {
      15*10^6
    } else if  (input$sequencer == "MiSeq/v3") {
      25*10^6
    } else if (input$sequencer == "MiSeq/v2 Micro"){
      4*10^6
    } else if (input$sequencer == "MiSeq/v2 Nano"){
      1*10^6
    } else if (input$sequencer == "NextSeq/ High Output"){
      400*10^6
    } else if (input$sequencer == "NextSeq/ Mid Output"){
      130*10^6
    }
  })
  
  output_bases <- reactive ({
    input$read_length * clusters()
  })
  
  t_coverage <- reactive({
    input$target_coverage
  })
  
  # output$selected_sequencer <-renderUI(
  #   if (input$sequencer == "MiSeq"){  
  #   tagList(
  #       numericInput("duplicates", "Duplicates %", value = 2),
  #       numericInput("read_length", "Total Read Length (e.g. 500 for 2x250)", 
  #                    value = 500)
  #     )}  else if  (input$sequencer == "NextSeq") {
  #   tagList(
  #     sliderInput("n", "N", 1, 1000, 500),
  #     textInput("label", "Label"),
  #     sliderInput("n", "N", 1, 1000, 500),
  #     textInput("label", "Label")
  #   )})
  
  genome_size <- reactive({
    input$genome_size * 10^6
  })
  
  df_const <- reactive({
    df <- tibble(
      max_output = output_bases(), # constant from machine, dropdown
      genome_size = genome_size(), # constant, numericInput
      on_target = input$on_target_slider, # constant, sliderInput
      duplicates = input$duplicates
    )
    return(df)
  })
  
  df_calculated <- reactive({
    df <- tibble(
      number_of_samples = c(1:1000),
      max_output = rep(df_const()$max_output, 1000),
      genome_size = rep(df_const()$genome_size, 1000),
      on_target = rep(df_const()$on_target, 1000),
      duplicates = rep(df_const()$duplicates)
    )
    
    df <- df %>% 
      mutate(coverage = (max_output * (on_target/100)*(1-(duplicates/100)))/(genome_size * number_of_samples))
    print(head(df))
    return(df)
  })
  
  ylim_maximum <- reactive({
    t <- df_calculated() %>% 
      filter(coverage <= t_coverage() + 20) %>%
      #filter(coverage >= t_coverage - 20) %>%
      select(coverage) %>% 
      arrange(desc(coverage)) %>% 
      mutate(coverage = round(coverage + 3, digits = 0)) %>% 
      head(n=1) %>% 
      pull
    return(t)
  })
  
  xlim_maximum <- reactive({
    val <- df_calculated() %>% filter(coverage >= t_coverage()) %>% 
      filter(number_of_samples == max(number_of_samples)) %>% 
      pull(number_of_samples) + 20
    return(val)
  })
  
  xlim_minimum <- reactive({
    val <- df_calculated() %>% filter(coverage >= t_coverage()) %>% 
      filter(number_of_samples == max(number_of_samples)) %>% 
      pull(number_of_samples) - 20
    if (val < 0){
      val <- 0
    }
    return(val)
  })

  output$limit <- renderText({
    as.character(ylim_maximum())
  })
  
  output$coverage_plot <- renderPlotly({
    g <- ggplot(data =df_calculated(), aes(x=number_of_samples, y = coverage)) +
      geom_line() +
      scale_x_continuous(limits = c(xlim_minimum(), xlim_maximum()), expand = c(0,0))+
      scale_y_continuous(limits =  c(0, ylim_maximum()))+
      geom_hline(yintercept = input$target_coverage, colour = "red")
    
    plot_list[["report"]] <<- expr(plot(!!g))
    
    plotly::ggplotly(g)%>% 
      layout(height = input$plotHeight, autosize=TRUE)
  })
  
  # Best sample number
  
  calculated_number_of_samples <- reactive({
    val <- df_calculated() %>% filter(coverage >= t_coverage()) %>% 
      filter(number_of_samples == max(number_of_samples)) %>% 
      pull(number_of_samples)
    return(val)
  })
  
  output$best_samplenumber <- renderText({
    string <- paste("Maximum number of Samples:", calculated_number_of_samples())
    return(string)
  })
  
  # Report generation
  
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
    calculated_number_of_samples <<- isolate(calculated_number_of_samples())
    print(calculated_number_of_samples)
      
      # Set up parameters to pass to Rmd document
      params <- list(sequencer = input$sequencer,
                     author = input$author,
                     on_target = input$on_target_slider,
                     target_coverage = input$target_coverage,
                     duplicates = input$duplicates,
                     project = input$project,
                     projectid = input$projectid,
                     calculated_number_of_samples = calculated_number_of_samples)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )

}