library(tidyverse)
library(magrittr)

#### Read data ####
data <- read_tsv("interData/data.tsv")
anno <- read_tsv("interData/anno.tsv")
anno <- anno[order(anno$SUPER.PATHWAY),]
pheno <- read_tsv("interData/pheno.tsv")
pheno <- pheno[order(pheno$SAMPLE_NAME),]
data <- data[order(data$ID),] %>% dplyr::select(-ID)
data <- data %>% dplyr::select(all_of(anno$metabolite_name))

#### Standardize data ####
data %<>% mutate_all(function(x) ifelse(is.na(x), min(x, na.rm = T), x))
data %<>% mutate_all(function(x) log(x+1))
data %<>% mutate_all(function(x) (x-mean(x))/sd(x))

#### PCA ####
pc <- prcomp(data, rank = 2)$x %>% as_tibble()
pc %<>% mutate(COPD = as.factor(pheno$COPD))
pcplot <- pc %>% ggplot(aes(PC1,PC2, color=COPD)) + geom_point()
ggsave("results/pca.png", pcplot)
