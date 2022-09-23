library(tidyverse)
library(magrittr)

ids <- read_tsv("interData/ids.txt") %>% arrange(subject_id)
broad <- read_tsv("interData/broad.txt")
metabolon <- read_tsv("interData/metabolon.txt")

broad %<>% filter(ID %in% ids$ID)
broad <- broad[order(match(broad$ID, ids$ID)),]
broad$ID <- ids %>% filter(Platform == "Broad") %>% select(subject_id)

metabolon %<>% filter(ID %in% ids$ID)
metabolon <- metabolon[order(match(metabolon$ID, ids$ID)),]
metabolon$ID <- ids %>% filter(Platform == "Metabolon") %>% select(subject_id)

metabAnno <- read_tsv("sourceData/metabolonAnnotation.txt")
metabAnno <- metabAnno %>% filter(CHEM_ID %in% names(metabolon))
hmdbBroad <- broad %>% select(-ID) %>% names()
hmdbMetab <- metabAnno$HMDB
hmdbMetab <- hmdbMetab[!is.na(hmdbMetab)]
hmdb <- hmdbBroad[hmdbBroad %in% hmdbMetab]

broad <- broad[, all_of(c("ID", hmdb))]
metNames <- c(as.character(metabAnno$CHEM_ID[match(hmdb,metabAnno$HMDB)]), "ID")
metabolon <- metabolon %>% select(all_of(metNames))
metNames <- metabAnno$HMDB[match(metNames, metabAnno$CHEM_ID)]
metNames <- c(metNames[!is.na(metNames)], "ID")
names(metabolon) <- metNames
metabolon %<>% select(all_of(names(broad)))

broadImp <- broad %>% mutate(across(where(is.numeric), ~ coalesce(., min(., na.rm = TRUE)/2)))
broadImp %<>% select(-ID) %>% as.matrix()
broadImp %<>% log()
metabolonImp <- metabolon %>% mutate(across(where(is.numeric), ~ coalesce(., min(., na.rm = TRUE))))
metabolonImp %<>% select(-ID) %>% as.matrix()
metabolonImp %<>% log()

mFor <- metabolon %>% select(-ID) %>% as.matrix()
mFor %<>% missForest()
mFor <- mFor$ximp
mFor %<>% log()
