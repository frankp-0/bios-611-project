library(tidyverse)
library(magrittr)
library(mixOmics)

set.seed(131523)

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
mod <- mixOmics::splsda(X = data, Y = Y, ncomp = 10)
perfo <- perf(mod, validation = "Mfold",
              folds = 5, nrepeat = 10,
              progressBar = TRUE, auc = TRUE)

png("results/roc.png")
auroc(mod, roc.comp = 2)
dev.off()

png("results/plsdaPerf.png")
plot(perfo)
dev.off()

VIP <- vip(mod)[,1] %>% unlist() %>% unname()
dfVip <- tibble(VIP = VIP,
                Metabolite = anno$metabolite_name,
                SuperPathway = anno$SUPER.PATHWAY,
                SubPathway = anno$SUB.PATHWAY
                )
dfVip %<>% mutate(Metabolite = factor(Metabolite, levels = Metabolite))
dfVip <- dfVip[order(VIP, decreasing = TRUE),]
dfVip[1:15,] %>%
  kableExtra::kable(
                format = "latex",
                caption = "Table caption \\label{tab:vip}") %>%
  kableExtra::kable_styling(latex_options = "scale_down") %>%
  write("results/vip.tex")

png("results/indiv.png")
plotIndiv(mod, ellipse = TRUE)
dev.off()
