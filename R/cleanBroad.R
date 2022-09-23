library(tidyverse)
library(magrittr)

transposeData <- function(df) {
  indMetab <- grep("Metabolite", names(df))
  df %<>% filter(grepl("HMDB", HMDB_ID))
  df %<>% filter(`Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)`==1)
  metNames <- df$HMDB_ID
  df <- df[, indMetab:ncol(df)]
  df %<>% select(-Metabolite)
  ID <- names(df)
  df %<>% as.matrix() %>% t()
  colnames(df) <- metNames
  df %<>% as_tibble
  df$ID <- ID
  return(df)
}

readBroad <- function(file){
  command <- paste0("awk '{ print $1 }' ", file, " | grep -n -m 1 \"Method\"")
  skip = system(command, intern = T) %>%
    sub(pattern = "\\:.*", replacement = "") %>%
    as.integer() - 1
  df <- read_tsv(file, skip = skip)

  if(grepl("Amide", file)){
    tmp <- df$HMDB_ID
    df$HMDB_ID <- df$`Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)`
    df$`Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)` <- tmp
  }

  df %<>% transposeData
  return(df)
}

C18_neg <- readBroad("sourceData/C18-neg.txt")
C8_pos <- readBroad("sourceData/C8-pos.txt")
HILIC_pos <- readBroad("sourceData/HILIC-pos.txt")
Amide_neg <- readBroad("sourceData/Amide-neg.txt")

broadData <- HILIC_pos %>% inner_join(C18_neg, by="ID") %>%
  inner_join(C8_pos, by="ID") %>%
  inner_join(Amide_neg, by="ID")

colRemove <- names(broadData)[endsWith(names(broadData), ".y")]
broadData <- broadData %>% select(-all_of(colRemove))
names(broadData) <- str_remove(names(broadData), ".x")

write_tsv(broadData, "interData/broad.txt")
