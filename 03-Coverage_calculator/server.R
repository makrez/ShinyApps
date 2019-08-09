server <- function(input, output, session){
  
  max_output_select <- reactive({
    if (input$sequencer == "MiSeq v2 kit") {
      12000000*250
    } else if  (input$sequencer == "MiSeq v3 kit") {
      12000000*300
    }
  })
  
  df_const <- reactive({
    df <- tibble(
      max_output = max_output_select(), # constant from machine, dropdown
      genome_size = input$genome_size, # constant, numericInput
      on_target = input$on_target_slider # constant, sliderInput
    )
    return(df)
  })
  
  df_calculated <- reactive({
    df <- tibble(
      number_of_samples = c(1:1000),
      max_output = rep(df_const()$max_output, 1000),
      genome_size = rep(df_const()$genome_size, 1000),
      on_target = rep(df_const()$on_target, 1000)
    )
    
    df <- df %>% 
      mutate(coverage = (max_output * (on_target/100))/(genome_size * number_of_samples))
    return(df)
  })
  
  ylim_maximum <- reactive({
    t <- df_calculated() %>% 
      filter(number_of_samples >= input$x_minimum) %>%
      filter(number_of_samples <= input$x_maximum) %>%
      select(coverage) %>% 
      arrange(desc(coverage)) %>% 
      mutate(coverage = round(coverage + 3, digits = 0)) %>% 
      head(n=1) %>% 
      pull
    return(t)
  })

  output$limit <- renderText({
    as.character(ylim_maximum())
  })
  output$coverage_plot <- renderPlotly({
    g <- ggplot(data =df_calculated(), aes(x=number_of_samples, y = coverage)) +
      geom_line() +
      scale_x_continuous(limits = c(input$x_minimum, input$x_maximum), expand = c(0,0))+
      ylim(c(0, ylim_maximum()))+
      geom_hline(yintercept = input$target_coverage, colour = "red")
    
    plotly::ggplotly(g)%>% 
      layout(height = input$plotHeight, autosize=TRUE)
  })

}