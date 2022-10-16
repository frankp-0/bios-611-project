library(tidyverse)
library(magrittr)

assays <- c("neg", "polar", "pos_early")

readData <- function(assay){
  dfFile <- paste0("sourceData/", assay, ".txt")
  ID <- read.table(dfFile, nrows=1) %>% unlist()
  dfNames <- c("Metabolite", ID)
  df <- read_tsv(dfFile,
                 col_names = dfNames,
                 skip = 1,
                 col_types = cols())
  Metabolite <- df$Metabolite
  df %<>% select(all_of(2:ncol(df))) %>% t() %>%
    as_tibble(.name_repair = "minimal") %>% setNames(Metabolite)
  df %<>% mutate(ID = ID)
  return(df)
}

readAnno <- function(assay){
  dfFile <- paste0("sourceData/", assay, "_metadata.txt")
  dfNames <- c("metabolite_name", "SUPER.PATHWAY", "SUB.PATHWAY",
               "PLATFORM", "RI", "MASS", "PUBCHEM",
                "CAS", "KEGG", "HMDB")
  df <- read_tsv(dfFile,
                 col_names = dfNames,
                 col_types = cols(),
                 skip = 1)
  df %<>% mutate(Assay = assay)
  return(df)
}

data <- lapply(assays, function(assay) readData(assay)) %>%
  Reduce(function(df1, df2) left_join(df1, df2, by="ID"), .)

anno <- lapply(assays, function(assay) readAnno(assay)) %>%
  do.call("rbind", .)

write_tsv(data, "interData/data.tsv")
write_tsv(anno, "interData/anno.tsv")
