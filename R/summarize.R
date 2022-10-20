library(tidyverse)
library(magrittr)
library(gt)
library(ggplot2)

data <- read_tsv("interData/data.tsv") %>% select(-ID)
anno <- read_tsv("interData/anno.tsv")

naMeans <- data %>% is.na() %>% colMeans() * 100
df <- tibble(means = naMeans,
             Pathway = anno$SUPER.PATHWAY,
             Assay = anno$Assay
             )

df %>% ggplot(aes(x = Pathway, fill = Assay)) +
  geom_bar(position = "stack", stat="count") +
  theme(axis.text.x = element_text(angle = -30, vjust=-3))
ggsave("results/metaboliteCount.png")

dfPath <- df %>% group_by(Pathway)

pathSummary <- dfPath %>% summarize(mean = mean(means) %>% round(2))

dfPath %>% ggplot(aes(factor(Pathway), means, fill = Pathway)) +
  geom_boxplot() +
  theme(axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        axis.ticks.x = element_blank()) +
  stat_summary(fun=mean, color = "darkblue") +
  geom_text(data = pathSummary, aes(label = mean, y = mean + 1)) +
  ylab("% Missingness")
ggsave("results/pathSummary.png")
