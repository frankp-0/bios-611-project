library(tidyverse)
library(magrittr)

metIDTable <- read_csv("sourceData/metabolon_ids.csv", col_types=cols())[,1:2]
broadIDTable <- read_csv("sourceData/broad_ids.csv", col_types=cols())[,1:2]
names(broadIDTable) <- c("subject_id", "TOMID")

metDupID <- metIDTable$subject_id[duplicated(metIDTable$subject_id)]
broadDupID <- broadIDTable$subject_id[duplicated(broadIDTable$subject_id)]

metIDTable %<>% filter(!(subject_id %in% metDupID))
broadIDTable %<>% filter(!(subject_id %in% broadDupID))

names(metIDTable)[2] <- "Metabolon"
names(broadIDTable)[2] <- "Broad"

IDTable <- inner_join(metIDTable, broadIDTable, by = "subject_id") %>%
  gather(key="Platform", value="ID", Metabolon, Broad)

write_tsv(IDTable, "interData/ids.txt")
