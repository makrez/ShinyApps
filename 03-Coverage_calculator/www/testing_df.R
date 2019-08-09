df_test <- tibble(
    max_output = 10, # constant from machine, dropdown
    genome_size = 99, # constant, numericInput
    on_target = 10 # constant, sliderInput
  )

df <- tibble(
  number_of_samples = c(1:1000),
  max_output = rep(df_test$max_output, 1000),
  genome_size = rep(df_test$genome_size, 1000),
  on_target = rep(df_test$on_target, 1000)
)

df <- df %>% 
  mutate(coverage = (max_output * on_target)/(genome_size * number_of_samples))
df %>% 
  filter(number_of_samples >= 0) %>%
  filter(number_of_samples <= 100) %>%
  slice(max(coverage)) %>%
  select(coverage) %>%
  mutate(coverage = coverage + 3) %>% pull
