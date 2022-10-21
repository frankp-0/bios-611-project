library(tidyverse)
library(magrittr)

#### Helper Functions ####
#=========================
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
#=========================

##### Concatenate Data ####
#==========================
assays <- c("neg", "polar", "pos_early")
data <- lapply(assays, function(assay) readData(assay)) %>%
  Reduce(function(df1, df2) left_join(df1, df2, by="ID"), .)

anno <- lapply(assays, function(assay) readAnno(assay)) %>%
  do.call("rbind", .)

# Remove metabolites with greater than 50% missingness
namesKeep <- names(data)[colMeans(is.na(data)) <= 0.5]
anno %<>% filter(metabolite_name %in% namesKeep)
data %<>% select(all_of(namesKeep))
#==========================

#### Remove Outliers ####
#========================
# Min-impute, log transform, and standardize data
dataMin <- data %>% select(-ID)
dataMin %<>% mutate_all(function(x) ifelse(is.na(x), min(x, na.rm = T), x))
dataMin %<>% mutate_all(function(x) log(x+1))
dataMin %<>% mutate_all(function(x) (x-mean(x))/sd(x))

# Calculate Mahalanobis distance on principal components
pca <- prcomp(dataMin)
scores <- pca$x
mah <- sqrt(rowSums((t(t(scores) / pca$sdev))^2))
dfMah <- tibble(dist = mah)
dfMah %>% ggplot(aes(x = dist)) +
  geom_boxplot() +
  xlab("Mahalanobis Distance")
ggsave("results/outliers.png", width=7, height = 4)
data <- data[-which.max(mah),]

##### Format and save data ####
#------------------------------
data <- data[order(data$ID), ]
pheno <- read_tsv("sourceData/study_design.txt")
pheno <- pheno[match(data$ID, pheno$SAMPLE_NAME),]

write_tsv(data, "interData/data.tsv")
write_tsv(anno, "interData/anno.tsv")
write_tsv(pheno, "interData/pheno.tsv")
#------------------------------
