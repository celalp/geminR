# This is a rudimentary shiny app that connects to a local gemini database
# The goal is to generate this app for users to interactively query the database
# For more feature requests email alper.celik@sickkids.ca

# this is a two file shiny app the other one is called ui.R

####TODO 
# test toastr
# another tab for logs
# remove column filters
# get the sql ui going but doesnt have to be functionsl

library(shiny)
library(shinyWidgets)
library(RSQLite)
library(DBI)
library(DT)
library(plyr)
library(reshape2)
library(shinyBS)
library(stringr)
library(shinyFiles) #needs to be the dev version
library(shinydashboard)
library(shinytoastr)
library(billboarder)
library(highcharter)
library(shinycssloaders)
library(dashboardthemes)
library(plotly)
library(ggplot2)
library(tm)

print("server loaded")

source("utils.R")
source("inputs.R", local = F)
source("vars.R")
source("dbDT.R")

server <- function(input, output, session) {
  locations <- eventReactive(input$load , {
    db <- input$db_select
    db_loc <- paste0("/Users/Shared/dbs/", input$db_select)
    tryCatch({
      con <- dbConnect(drv = RSQLite::SQLite(), dbname = db_loc)
      toastr_success("Connections established")
      gemv <-
        system("gemini -v", intern = T) #this is wrong need to make sure that
      #it actually gets the gemini
      toastr_success("Gemini found", gemv)
      locs <- list(db = con, db_loc = db_loc)
      db_startup_check(con, db_loc)
      print(db_loc)
      return(locs)
    },
    error = function(e) {
      toastr_error(title = "Database error", conditionMessage(e))
      return(NULL)
    })
  })
  
  db_info <- reactive({
    if (is.null(locations())) {
      return(NULL)
    } else {
      tablenames <- dbListTables(conn = locations()$db)
      to_rem<-c("features", "jobs", "sqlite_sequence", "vcf_header", "version")
      tablenames<-tablenames[! tablenames %in% to_rem]
      table_info <- list()
      for (table in tablenames) {
        table_info[[table]] <-
          dbGetQuery(locations()$db,
                     paste0("PRAGMA table_info(", table, ")"))
      }
      info = list(tablenames = tablenames, table_info = table_info)
      return(info)
    }
  })
  
  output$overview <- renderUI({
    genotypes<-dbGetQuery(locations()$db, "select * from sample_genotype_counts")
    genm<-melt(genotypes[,-1])
    genm$sample<-as.factor(genotypes$sample_id)
    gen_p<-ggplot(genm, aes(x=sample, y=value, fill=variable))+
      geom_bar(stat = "identity")+theme_minimal()+
      theme(legend.position="none")+
      xlab("Sample Name")+ylab("Number of Variants")
    
    if (!is.null(locations())) {
      toastr_info(title = "Gathering Database stats", "Please wait...")
      tagList(
        fluidRow(
        valueBox(
          dbGetQuery(locations()$db, "select count (*) from samples"),
          "Samples",
          icon = icon("user"),
          color = "teal",
          width = 3
        ),
        valueBox(
          dbGetQuery(
            locations()$db,
            "select count (distinct family_id) from samples"
          ),
          "Familes",
          icon = icon("venus-mars"),
          color = "aqua" ,
          width = 3
        ),
        valueBox(
          dbGetQuery(locations()$db, "select count (*) from variants"),
          "Variants",
          icon = icon("flask"),
          color = "light-blue" ,
          width = 3
        ),
        valueBox(
          dbGetQuery(
            locations()$db,
            "select count (*) from samples where phenotype = 2"
          ),
          "Affected Individuals",
          icon = icon("medkit"),
          color = "blue" ,
          width = 3
        ),
        column(
          width = 3,
          renderPlotly(
            plot_ly(count(dbGetQuery(locations()$db, "select phenotype from samples")),
            labels = ~phenotype, values = ~freq, type = 'pie') %>%
              layout(title ="Phenotype Distribution")
          )
        ),
        column(
          width = 3,
          renderPlotly(
            plot_ly(count(dbGetQuery(locations()$db, "select sex from samples")),
                    labels = ~sex, values = ~freq, type = 'pie') %>%
              layout(title ="Sex Distribution")
          )
        ),
        br(),
        column(
          width = 3,
          renderPlotly(
            plot_ly(count(dbGetQuery(locations()$db, "select impact_severity from variants")),
                    labels = ~impact_severity, values = ~freq, type = 'pie') %>%
              layout(title ="Impact Severity Distribution")
          )),
          column(width = 3,
        renderPlotly(
          ggplotly(gen_p)
        ))
      ))
    } else {
      NULL
    }
  })
  
  output$variant_table_params<-renderUI({
    tagList(
    div(style="display:inline-block;",    
    pickerInput(inputId = "variant_table_select", 
                label="Select table to Display", 
                choices = db_info()$tablenames, 
                multiple = F, selected = "variants")),
    div(style="display:inline-block;",
    numericInput(inputId = "page_len", "Page length", value = 10))
    )
  })
  
  limit <- reactive({input$page_len})
  table <- reactive({input$variant_table_select})
  ##### these values need to be reactive
  
  callModule(
    dbDT,
    "db_query_table",
    con = locations()$db,
    limit = limit,
    table = table
  )
  
  output$gemini_tools <-
    renderUI({
      #this needs to be majorly refactored
      if (is.null(locations())) {
        NULL
      } else {
        if (input$built_in == "Compound Heterozygotes") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples"),
                use.names = F
              ))
            ),
            depth,
            min_gq,
            gt_pl,
            gene_where,
            max_pri,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("allow-unaffected", "pattern-only")
              ),
            add_filters
          )
        } else if (input$built_in == "De novo mutations") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            gt_pl,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("allow-unaffected", "lenient")
              ),
            add_filters
          )
        } else if (input$built_in == "Non-mendelian transmission") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("only-affected", "lenient")
              ),
            add_filters
          )
        } else if (input$built_in == "Autosomal recessive") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            gt_pl,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("lenient")
              ),
            add_filters
          )
        } else if (input$built_in == "Autosomal dominant") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            gt_pl,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("lenient")
              ),
            add_filters
          )
        } else if (input$built_in == "X-linked recessive") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            X,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("allow-unaffected")
              ),
            add_filters
          )
        } else if (input$built_in == "X-linked dominant") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            X,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("allow-unaffected")
              ),
            add_filters
          )
        } else if (input$built_in == "X-linked de novo") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            kindred,
            families <- picker(
              "families",
              "Select families",
              actions = T,
              choices = unique(unlist(
                dbGetQuery(locations()$db, "select family_id from samples")
              ),
              use.names = F)
            ),
            depth,
            min_gq,
            X,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("allow-unaffected")
              ),
            add_filters
          )
        } else if (input$built_in == "Gene wise filtering") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            gene_where,
            gt_filter,
            gt_filter_required,
            add_filters
          )
        } else if (input$built_in == "KEGG pathways") {
          tagList(v,
                  bools <-
                    bool_maker(
                      id = "bools",
                      "other options",
                      options = c("lof")
                    ))
        } else if (input$built_in == "Interactions") {
          tagList(g,
                  r,
                  bools <-
                    bool_maker(
                      id = "bools",
                      "other options",
                      options = c("var")
                    ))
          
        } else if (input$built_in == "Filter LoF variants") {
          tagList(h4("This method does not have any additional arguments"))
        } else if (input$built_in == "Filter by region") {
          tagList(
            columns <- picker(
              "columns",
              "Select columns to display",
              actions = T,
              choices = db_info()$table_info[["variants"]][, 2]
            ),
            reg,
            g,
            bools <-
              bool_maker(
                id = "bools",
                "other options",
                options = c("header", "show-samples")
              ),
            add_filters
          )
        } else if (input$built_in == "Filter by window") {
          tagList(w,
                  s,
                  type,
                  o)
        } else if (input$built_in == "Calculate genetic burden") {
          tagList(
            bools <- bool_maker(
              id = "bools",
              "other options",
              options = c("nonsynonymous", "calpha")
            ),
            div(style = "display: inline-block;vertical-align:top;
                width:50%;text-align: center;",
                min_aaf),
            div(style = "display: inline-block;width:50%;vertical-align:top;
                text-align: center;",
                max_aaf)
          )
        } else if (input$built_in == "Get somatic variants") {
          tagList(
            min_depth,
            min_qual,
            min_somatic_score,
            max_norm_alt_freq,
            max_norm_alt_count,
            min_norm_depth,
            min_mut_alt_freq,
            min_mut_alt_count,
            min_mut_depth,
            chrom
          )
        } else if (input$built_in == "ROH (runs of homozygosity)") {
          tagList(
            min_snps,
            min_total_depth,
            min_gt_depth,
            min_size,
            max_hets,
            max_unknowns,
            samples <- picker(
              id = "samples",
              label = "Samples",
              choices = unlist(
                dbGetQuery(locations()$db, "select name from samples"),
                use.names = F
              ),
              actions = T
            )
          )
        } else if (input$built_in == "Report actionable mutations") {
          h4("This method does not have any additional arguments")
        } else if (input$built_in == "Get gene fusions") {
          tagList(
            min_qual,
            evidence,
            cosmic <- bool_maker("in_cosmic_census", "other options",
                                 options = "In cosmic census")
          )
        }
      }
    })
  
  output$gemini_filter <- renderUI({
    if (is.null(locations())) {
      NULL
    } else if (input$add_filters) {
      tagList(
        picker(
          id = "var_filters",
          label = "Select columns to filter",
          choices = db_info()$table_info[["variants"]][, 2],
          actions = T
        )
      )
    }
  })
  
  observeEvent(input$submit_gem, {
    command <- generate_command(input$built_in, input)
    command <- paste(command, locations()$db_loc)
    print(command)
    # need to check if the table name already exists and give a toastr
    # alert
    job_name<-input$job_name_gem
    job_name<-stripWhitespace(job_name)
    job_name<-gsub(" ", "", job_name)
    insert_command<-paste0("INSERT INTO jobs(job_name, command, status, exit_code) VALUES(", 
                           " \"", job_name, "\",",
                           " \"", command, "\"", 
                           ",", "\"waiting\"" , ",", "\"NA\"", ")")
    #print(insert_command)
    dbSendQuery(locations()$db, insert_command)
    system2("bash", args = c("scheduler.sh", locations()$db_loc, 1, "&"))
    toastr_success("Job submitted", paste("This will appear as ", input$job_name_gem, 
                                          "in the database after successful completion"))
  })
  
  
  output$sql_tools_columns <- renderUI({
    if (length(input$table_selection) > 0) {
      col_selectors <- list()
      for (i in 1:length(input$table_selection)) {
        col_selectors[[i]] <- pickerInput(
          inputId = "column_selection",
          label = paste0("Select columns from to search"),
          choices = db_info()$table_info[["variants"]][, 2],
          multiple = T,
          options = list(`live-search` = T, size = 10)
        )
      }
      tagList(col_selectors)
    }
  })
  
  output$advSQL <- renderUI({
    if (input$is_manual) {
      textAreaInput(
        "man_sql",
        "Enter your SQL query below:",
        placeholder = "eg. SELECT * FROM variants WHERE...",
        resize = "both"
      )
    }
  })
  
  output$jobstable <- renderDT({
    data<-dbGetQuery(locations()$db, "select * from jobs")
    datatable(
      data,
      selection = "none",
      autoHideNavigation = F,
      rownames = F,
      options = list(dom = 't')
    )
    #verbatimTextOutput(command())
  })
}