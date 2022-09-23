library(tidyverse)
library(magrittr)

metabolon <- read_tsv("sourceData/Metabolon.txt")
anno <- read_tsv("sourceData/metabolonAnnotation.txt")
metKeep <- anno %>% filter(LEVEL == 1) %>% select(CHEM_ID) %>% pull()
metKeep <- c("TOMID", as.character(metKeep))
metabolon %<>% select(all_of(metKeep))
metabolon %<>% select(which(colMeans(is.na(metabolon )) <= 0.8))
metabolon %<>% rename(ID=TOMID)

write_tsv(metabolon, "interData/metabolon.txt")
