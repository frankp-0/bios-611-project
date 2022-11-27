library(pheatmap)
library(tidyverse)
library(magrittr)

data <- read_tsv("interData/data.tsv")
anno <- read_tsv("interData/anno.tsv")
anno <- anno[order(anno$SUPER.PATHWAY),]
pheno <- read_tsv("interData/pheno.tsv")
pheno <- pheno[order(pheno$SAMPLE_NAME),]
data <- data[order(data$ID),] %>% dplyr::select(-ID)
data <- data %>% dplyr::select(all_of(anno$metabolite_name))

data %<>% mutate_all(function(x) log(x+1))
data %<>% mutate_all(function(x) (x-mean(x, na.rm = T))/sd(x, na.rm = T))
data %<>% mutate_all(function(x) ifelse(is.na(x), min(x, na.rm = T), x))

ar <- data.frame(row.names = anno$metabolite_name, category = anno$SUPER.PATHWAY)
pheat <- pheatmap(cor(data), annotation_row = ar, annotation_col = ar,
         show_colnames = FALSE, show_rownames = FALSE,
         main = "Heatmap of Metabolite Correlations")
ggsave("results/heat.png", pheat)
