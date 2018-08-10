# This is a rudimentary shiny app that connects to a local gemini database
# The goal is to generate this app for users to interactively query the database
# For more feature requests email alper.celik@sickkids.ca

# this is a two file shiny app the other one is called server.R


######### TODO 
# move tabs around, add another value box with # of affected genes
# impact distribution pie

library(shiny)
library(shinyWidgets)
library(RSQLite)
library(DBI)
library(DT)
library(plyr)
library(reshape2)
library(shinyBS)
library(stringr)
library(tm)
library(shinyFiles) #needs to be the dev version
library(shinydashboard)
library(shinytoastr)
library(billboarder)
library(highcharter)
library(shinycssloaders)
library(dashboardthemes)
library(plotly)
library(ggplot2)

print("ui loaded")

source("dbDT.R")


ui<-dashboardPage(
  dashboardHeader(title = "geminR"
                  #dropdownMenuOutput("files")
  ),
  dashboardSidebar(
    wellPanel(
    selectInput("db_select", "Select Database", 
                choices = c("ibd_6sample.db", "661d-ensemble.db"), 
                selected = NULL),
    actionButton("load", label = "Load")), 
    bsTooltip(id = "load", "Load Database"),
    br(),
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"), selected=TRUE),
      menuItem("Variants Table/Search", tabName = "variants", icon = icon("search")),
      menuItem("Review Jobs", tabName = "jobs", icon = icon("gears"))
    )
  ),
  dashboardBody(
    useToastr(),
    shinyDashboardThemes(theme = "poor_mans_flatly"),
    tabItems(
      tabItem(tabName = "dashboard",
              box(title = "Basic Database Stats", width = 12, 
                  withSpinner(
                    uiOutput("overview")
                  )
              )),
      tabItem(tabName = "variants",
              fluidRow(
                tabBox(title = "Search Variants", width = 3, 
                       tabPanel("Gemini Built in Analysis", 
                                tagList(
                                  fluidRow(
                                    pickerInput(
                                      inputId = "built_in",
                                      label = "Select built in tool", 
                                      choices = c("De novo mutations",
                                                  "Non-mendelian transmission", "Autosomal recessive", 
                                                  "Autosomal dominant", "X-linked recessive", 
                                                  "X-linked dominant", "X-linked de novo", 
                                                  "Gene wise filtering", "KEGG pathways", 
                                                  "Interactions", "Filter LoF variants", 
                                                  "Filter by region", "Filter by window", 
                                                  "Calculate genetic burden", "ROH (runs of homozygosity)", 
                                                  "Get somatic variants", "Report actionable mutations", 
                                                  "Get gene fusions", "Compound Heterozygotes"), 
                                      options = list(size=10)
                                    )),
                                  fluidRow(
                                    uiOutput("gemini_tools"),
                                    tagList(
                                      uiOutput("gemini_filter"),
                                      uiOutput("gemini_filter_param")
                                    ), 
                                    
                                    tagList(
                                      textInput(inputId="job_name_gem", label = "Job Name"), 
                                      actionButton("submit_gem", "Submit Job")
                                    ))
                                )),
                       tabPanel("SQL/Gemini queries", 
                                uiOutput("sql_tools_columns"), 
                                uiOutput("sql_filters"),
                                checkboxInput("is_manual", "Enter manual SQL query"), 
                                uiOutput("advSQL"),
                                actionButton("submit_sql", "Submit Query")
                       )
                ),
                box(title="Variant Browser", width = 9, 
                    tagList(
                      uiOutput("variant_table_params"),
                      uiOutput("col_select"),
                      dbDTUI("db_query_table")
                    )#put columns selection, page navigation, statesave, export
                )
              )
      ),
      tabItem(tabName = "jobs", 
              fluidRow(
                # The gemini built in tools are different than just submittin SQL queries
                # I assume they are some elaborate queries, I looked around for the exact queries
                # in the github page but did not find them. So i will 
                box(title = "Submitted Jobs", solidHeader = T,width=12, 
                           DTOutput("jobstable"))
                )
              )
    )
  ))




