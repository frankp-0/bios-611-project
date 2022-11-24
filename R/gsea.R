library(tidyverse)
library(magrittr)

data <- read_tsv("interData/data.tsv")
anno <- read_tsv("interData/anno.tsv")
anno <- anno[order(anno$SUPER.PATHWAY),]
pheno <- read_tsv("interData/pheno.tsv")
pheno <- pheno[order(pheno$SAMPLE_NAME),]
data <- data[order(data$ID),] %>% dplyr::select(-ID)
data <- data %>% dplyr::select(all_of(anno$metabolite_name))

data %<>% mutate_all(function(x) ifelse(is.na(x), min(x, na.rm = T), x))
data %<>% mutate_all(function(x) log(x+1))
data %<>% mutate_all(function(x) (x-mean(x))/sd(x))

data %<>% filter(!is.na(pheno$COPD))
pheno <- pheno %>% filter(!is.na(COPD))

Y <- pheno$COPD %>% as.factor()

l2fc <- sapply(1:ncol(data), function(i) {
  df <- tibble(metabolite = data[[i]], gender = pheno$GENDER, bmi = pheno$BMI_CM01, Y = Y)
  mod <- glm(Y ~ metabolite + gender, data = df, family = binomial)
  log2(exp(coef(summary(mod))[2,1]))})

met_names <- names(data)[order(l2fc, decreasing = TRUE)]
l2fc <- l2fc[order(l2fc, decreasing = TRUE)]
names(l2fc) <- met_names

t2g <- data.frame(
  path = anno$SUB.PATHWAY[match(names(l2fc), anno$metabolite_name)],
  ID = 1:ncol(data))
names(l2fc) <- 1:ncol(data)

gsRes <- clusterProfiler::GSEA(geneList = l2fc,
     TERM2GENE = t2g,
     minGSSize = 1)

gsDot <- enrichplot::dotplot(object = gsRes) +
  xlab("Pathway Ratio")
ggsave("results/gsea.png", gsDot)
