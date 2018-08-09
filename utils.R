catchToList <- function(expr) {
  val <- NULL
  myWarnings <- NULL
  wHandler <- function(w) {
    myWarnings <<- c(myWarnings, w$message)
    invokeRestart("muffleWarning")
  }
  myError <- NULL
  eHandler <- function(e) {
    myError <<- e$message
    NULL
  }
  val <- tryCatch(withCallingHandlers(expr, warning = wHandler), error = eHandler)
  list(value = val, warnings = myWarnings, error=myError)
} 

#this might turn into a generic cleaning function. 

gemini_to_df<-function(data){
  data<-stripWhitespace(data)
  data<-str_split(data, pattern=" ", simplify = T)
  #data<-data[,1:(dim(data)[2]-1)]
  colnames(data)<-data[1,]
  data<-data[-1,]
  data<-data.frame(data, stringsAsFactors = F)
  return(data)
}


#this is to help with input generation
determine_class<-function(table){
  
}

#this is to check if there is a jobs table if not add that
db_startup_check<-function(con, loc){
  tablenames<-dbListTables(conn = con)
  if (!("jobs" %in% tablenames)){
    dbSendStatement(con, 
                    statement = "create table jobs(job_id integer primary key autoincrement not null, 
                    job_name text unique, 
                    command text, 
                    status text, 
                    exit_code)"
    )
  }
  #if(!("snps" %in% tablenames)){
  #  dbSendStatement(con, 
  #                  statement ="create table snps(type text, count integer)")
  #  snps<-system(paste("gemini stats --snp-counts", loc), intern = T) #fix this hard coding
  #  snps<-gemini_to_df(snps)
  #  dbWriteTable(con, "snps", snps)
  #}
  #if(!("site_freq_spectrum" %in% tablenames)){
  #  dbSendStatement(con, 
  #                  statement ="create table site_freq_spectrum(aaf float, count integer)")
  #  sfs<-system(paste("gemini stats --sfs", loc), intern = T)
  #  sfs<-gemini_to_df(sfs)
  #  dbWriteTable(con, "site_freq_spectrum", sfs)
  #}
}

