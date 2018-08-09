

dbDTUI<-function(id){
  ns<-NS(id)
  tagList(
    uiOutput(ns("col_sel")),
    DTOutput(ns("table")), 
    br(),
    column(width = 2, offset = 0, 
           numericInput(ns("page_sel"), label = "Go to page", value = 1, min = 1)), 
    column(width = 4, offset = 6, 
           div(style="display: inline-block;vertical-align:bottom;",actionButton(inputId = ns("prev_page"), label = "<")),
           div(style="display: inline-block;vertical-align:bottom;width: 100px;",uiOutput(ns("pagecount"))),
           div(style="display: inline-block;vertical-align:bottom;",actionButton(inputId = ns("next_page"), label = ">"))
           )
  )
}

dbDT<-function(input, output, session, con, table, limit){
  
  ns <- session$ns
  
  selected=c("variant_id", "chrom", "start", "end", "gene", "aa_change", "impact_severity")
  
  page<-reactiveValues(page=1)
  
  observeEvent(input$page_sel, {
    page$page<-input$page_sel
  })
  
  observeEvent(input$next_page, {
    page$page<-page$page+1
  })
  
  observeEvent(input$prev_page, {
    if(page$page>1){
    page$page<-page$page-1
    } else {
      NULL
    }
  })
  
  output$col_sel<-renderUI({
    pickerInput(
      inputId = ns("columns_selected"), 
      label = "Select Columns to display",
      choices = dbGetQuery(con, paste0("pragma table_info(", table, ")"))[,2], 
      multiple = T, selected=selected,
      options = list(`actions-box` = T, `live-search`=T, size=10))
  })
  
  quer<-reactive({
    result<-dbGetQuery(con, paste("select * from", table, "limit", limit, "offset",
                          limit*(page$page-1)))
    pages<-unlist(dbGetQuery(con, paste("select count(*) from", table)))
    pages<-ceiling(pages/limit)
    return(list(result=result, pages=pages))
    })
  
  output$table<-renderDT({
    datatable(quer()$result[, input$columns_selected], selection="multiple", autoHideNavigation = F, rownames = F, 
              options = list(pageLength = limit, dom = 't', scrollX = TRUE), extensions = "Scroller")
  })
  
  output$pagecount<-renderText({paste("Displaying Page", page$page, "of", quer()$pages)})
}

