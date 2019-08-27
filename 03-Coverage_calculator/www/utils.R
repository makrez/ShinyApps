library(shinydashboard)
library(shiny)
library(here)
library(ggplot2)
library(tidyverse)
library(plotly)

# Texts

## General Information

general_information_txt = "This is a coverage calculator"
on_target_reads_txt = "For shotgun sequencing, this can usually be set to 100%. If you are interested in sequencing organellar genomes, the % of
                      organellar DNA from the total DNA should be estimated. For plastid sequencing, this value is often at around 5%, but can 
                      vary with species or plant parts etc."
