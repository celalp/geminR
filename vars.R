tools<-list(
  `Compound Heterozygotes`="comp_hets", 
  `De novo mutations`="de_novo",
  `Non-mendelian transmission`="mendel_errors", 
  `Autosomal recessive`="autosomal_recessive", 
  `Autosomal dominant`="autosomal_dominant", 
  `X-linked recessive`="x_linked_recessive", 
  `X-linked dominant`="x_linked_dominant", 
  `X-linked de novo`="x_linked_de_novo", 
  `Gene wise filtering`="gene_wise", 
  `KEGG pathways`="pathways", 
  `Interactions`="interactions", 
  `Filter LoF variants`="lof_sieve", 
  `Filter by region`="region", 
  `Filter by window`="windower", 
  `Calculate genetic burden`="burden", 
  `ROH (runs of homozygosity)`="roh", 
  `Get somatic variants`="set_somatic", 
  `Report actionable mutations`="actionable_mutations", 
  `Get gene fusions`="fusions" 
)

args<-list(
  comp_hets=c("columns", "kindred", "families", "d", "gt_pl_max", 
              "min_gq", "gene_where", "max_priority", 
              "bools"), 
  de_novo=c("columns", "kindred", "families", "d", "gt_pl_max", 
            "min_gq", "bools"), 
  mendel_errors=c("columns", "kindred", "families", "d", "gt_pl_max", 
                  "min_gq", "bools"),
  autosomal_recessive=c("columns", "kindred", "families", "d", "gt_pl_max", 
                        "min_gq", "bools"),
  autosomal_dominant=c("columns", "kindred", "families", "d", "gt_pl_max", 
                       "min_gq", "bools"),
  x_linked_recessive=c("columns", "kindred", "families", "d", 
                       "min_gq", "bools", "X"),
  x_linked_dominant=c("columns", "kindred", "families", "d", 
                      "min_gq", "bools", "X"),
  x_linked_de_novo=c("columns", "kindred", "families", "d", 
                     "min_gq", "bools", "X"),
  gene_wise=c("columns", "gene_where", "gt_filter", "gt_filter_required"),
  burden=c("bools", "min_aaf", "max_aaf"),
  lof_sieve=NULL,
  pathways=c("bools", "v"),
  roh=c("min_snps", "min_total_depth", "min_gt_depth", "min_size", 
        "max_hets", "max_unknowns", "samples"),
  actionable_mutations=NULL,
  fusions=c("bools", "evidence", "min_qual"),
  interactions=c("bools", "g", "r"),
  region=c("columns", "bools", "reg", "g"),
  windower=c("w", "s", "type", "o"), 
  set_somatic=c("min_depth", "min_qual", "min_somatic_score", 
                "max_norm_alt_freq", "max_norm_alt_count", 
                "min_norm_depth", "min_tumor_alt_freq", 
                "min_tumor_alt_count", "min_tumor_depth")
)

generate_command<-function(method, input){
  method_name<-tools[[method]]
  varnames<-args[[method_name]]
  if(is.null(varnames)){
    command<-paste("gemini", method_name)
  } else {
    parsed<-NULL
    for(var in varnames){
      value<-input[[var]]
      if(is.null(value) || is.na(value) || nchar(value)==0){
        next
      } else {
        name<-gsub("_", "-", var)
        if(name=="bools"){
          opt<-paste0("--", value)
          opt<-paste(opt, collapse = " ")
        } else {
          if(length(value)>1){
            value<-paste0(value, collapse = ",") 
          }
          if(nchar(name)==1){
            name<-paste0("-", name)
            opt<-paste(name, value)
          } else {
            name<-paste0("--", name)
            opt<-paste(name, value)
          }
        }
      }
      parsed<-paste(parsed, opt)
    }
    command<-paste0("gemini", " ", method_name, parsed)
  }
  return(command)
}





