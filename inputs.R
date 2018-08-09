# this is a utilities file that stores all the inputs that are needed for 
# built in tools for gemini, it gets loaded when the shiny package is called
# these are grouped by input type not by tool type, in the ui file you can see that
# different combinations of inputs are needed for different tools, and the inputs 
# are dynamically generated. 

picker<-function(id, label, choices, actions=F){
  input<-pickerInput(inputId = id, label = label,
              choices = choices,
              multiple = TRUE,
              options = list(`actions-box` = actions, `live-search`=T, size=10)
  )
  return(input)
}

kindred<-numericInput(inputId = "min_kindreds", label = "Min kindred", value = 1)

depth<-numericInput(inputId = "d", label = "Min depth", value = NULL)

min_gq<-numericInput(inputId = "min_gq", label = "Min genotype quality", value = NULL)

gt_pl<-numericInput(inputId = "gt_pl_max", label = "Max PL value", value = NULL)

max_pri<-selectInput(inputId = "max_priority", label = "Max priority", choices = c(1,2,3,NA))

gene_where<-textInput(inputId = "gene_where", label = "gene_where")

X<-textInput(inputId = "X", label = "X", value = "X")

gt_filter<-textAreaInput(inputId = "gt_filter", label = "gt filters", 
                        placeholder = "Enter GT filters one per line")

min_filter<-numericInput(inputId = "min_filters", label = "Min filter", value = NULL)

gt_filter_required<-textInput(inputId = "gt_filter_required", 
                              label = "Mandatory gt filter")

v<-numericInput(inputId = "v", label = "Ensembl version (66-71)", value = 68)

g<-textInput(inputId = "gene", label = "Gene")

r<-numericInput(inputId = "r", label = "Radius", value = NULL)

reg<-textInput(inputId = "region", label = "Region")

w<-numericInput(inputId = "w", label = "Window", value = NULL)

s<-numericInput(inputId = "s", label = "Size", value = NULL)

type<-radioGroupButtons(inputId = "t", label = "window type",
  choices = c("nucl_div", "hwe"))

o<-radioGroupButtons(inputId = "o", label = "output type",
                        choices = c("mean", "median", "min", "max", "collapse"))

bool_maker<-function(id, label, options, ind=T){
  buttons<-checkboxGroupButtons(
    inputId = id,
    label = label,
    choices = options,
    individual = ind,
    checkIcon = list(
      yes = tags$i(class = "fa fa-circle", 
                   style = "color: steelblue"),
      no = tags$i(class = "fa fa-circle-o", 
                  style = "color: steelblue"))
  )
  return(buttons)
}

min_snps<-numericInput(inputId = "min_snps", label = "Min snps", value = NULL)

min_total_depth<-numericInput(inputId = "min_total_depth", label = "Min total depth", 
                              value = NULL)

min_gt_depth<-numericInput(inputId = "min_gt_depth", label = "Min gt depth", value = NULL)

max_hets<-numericInput(inputId = "max_hets", label = "Max hets", value = NULL)

min_size<-numericInput(inputId = "min_size", label = "Min size", value = NULL)

max_unknowns<-numericInput(inputId = "max_unknown", label = "Max unknowns", value = NULL)

min_depth<-numericInput(inputId = "min_depth", label = "Min depth", value = NULL)

min_qual<-numericInput(inputId = "min_qual", label = "Min qual", value = NULL)

min_somatic_score<-numericInput(inputId = "min_size", label = "Min somatic score", value = NULL)

max_norm_alt_freq<-numericInput(inputId = "max_norm_alt_freq", label = "Max normal alternate freq"
                                , value = NULL)

max_norm_alt_count<-numericInput(inputId = "max_norm_alt_count", label = "Max normal alternate count"
                                 , value = NULL)

min_norm_depth<-numericInput(inputId = "min_norm_depth", label = "Min normal depth"
                             ,value = NULL)

min_mut_alt_freq<-numericInput(inputId = "min_tumor_alt_freq", 
                               label = "Min affected alternate frequency",
                               value = NULL)

min_mut_alt_count<-numericInput(inputId = "min_tumor_alt_count", 
                                label = "Min affected alternate count",
                                value = NULL)

min_mut_depth<-numericInput(inputId = "min_tumor-depth", 
                            label = "Min affected depth",
                            value = NULL)

chrom<-textInput("chrom", label = "Chromosome")

evidence<-radioGroupButtons(inputId = "evidence", label = "Evidence type",
                               choices = c("PE,SR", "SR", "PE"))

add_filters<-checkboxInput(inputId = "add_filters", label = "Add addtional filters")

min_aaf<-numericInput("min-aaf", "Min-allele freq", value = 0)

max_aaf<-numericInput("max-aaf", "Max-allele freq", value = 0)

high_impact<-picker("high_picker", "High Impact Mutations", 
             choices = c("frameshift", "splice acceptor", 
                         "splice donor", "start lost", 
                         "stop gained", "stop lost"))

med_impact<-picker("med_picker", "Medium Impact Mutations", 
             choices = c("in frame deletion", "in frame insertion", 
                         "missense", "protein altering", 
                         "splice region"))

low_impact<-picker("low_picker", "Low Impact Mutations", 
             choices = c("3' UTR", "5' UTR", 
                         "TF binding site", "coding sequence", 
                         "downstream gene", "intergenic", "intron", 
                         "miRNA", "non-coding exon", "regulatory region", 
                         "stop retained", "synonymous", "upstream gene"))

