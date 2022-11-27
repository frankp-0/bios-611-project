PHONY : clean
PHONY : getData
PHONY : cleanData
PHONY : summarize
PHONY : gsea
PHONY : heatmap
PHONY : pca
PHONY : plsda
PHONY : report


#### USE THESE TARGETS TO RUN WORKFLOW ####
# "reset" project
clean :
	rm -rf sourceData/*
	rm -rf interData/*
	rm -rf results/*

# acquire source data
getData : src/getData.sh .created-dirs\
	sourceData/neg.txt \
	sourceData/neg_metadata.txt \
	sourceData/polar.txt \
	sourceData/polar_metadata.txt \
	sourceData/pos_early.txt \
	sourceData/pos_early_metadata.txt \
	sourceData/pos_late.txt \
	sourceData/pos_polar_metadata.txt \
	sourceData/study_design.txt \

# clean data
cleanData : interData/data.tsv interData/anno.tsv interData/pheno.tsv

# summarize data
summarize : results/phenoSummary.tex results/pathSummary.png results/metaboliteCount.png

# GSEA
gsea : results/gsea.png

# heatmap
heatmap : results/heat.png

# PCA
pca : results/pca.png

# PLS-DA
plsda : results/roc.png results/plsdaPerf.png \
	results/indiv.png results/vip.tex

# generate report
report : report/report.pdf



#### DO NOT USE THESE TARGETS ####
# creates necessary directories
.created-dirs :
	mkdir -p sourceData
	mkdir -p interData
	mkdir -p results
	touch .created-dirs

# gets source data. use "getData" phony target when running make
sourceData/neg.txt \
	sourceData/neg_metadata.txt \
	sourceData/polar.txt \
	sourceData/polar_metadata.txt \
	sourceData/pos_early.txt \
	sourceData/pos_early_metadata.txt \
	sourceData/pos_late.txt \
	sourceData/pos_polar_metadata.txt \
	sourceData/study_design.txt :
		bash src/getData.sh


# cleans and combines source metabolomic data
# combines annotation data
# use cleanData target when running make
interData/data.tsv interData/anno.tsv interData/pheno.tsv  results/outliers.png : R/cleanData.R .created-dirs \
	sourceData/neg.txt \
	sourceData/neg_metadata.txt \
	sourceData/polar.txt \
	sourceData/polar_metadata.txt \
	sourceData/pos_early.txt \
	sourceData/pos_early_metadata.txt \
	sourceData/pos_late.txt \
	sourceData/pos_polar_metadata.txt
		Rscript R/cleanData.R

# generates figures summarizing missingness in cleaned data
results/phenoSummary.tex results/pathSummary.png results/metaboliteCount.png : R/summarize.R .created-dirs \
	interData/anno.tsv \
	interData/data.tsv \
	interData/pheno.tsv
		Rscript R/summarize.R

# conducts GSEA analysis to identify enriched sub-pathways
results/gsea.png : R/gsea.R .created-dirs \
	interData/anno.tsv \
	interData/data.tsv \
	interData/pheno.tsv
		Rscript R/gsea.R

# makes metabolomic correlation heatmap
results/heat.png : R/heatmap.R .created-dirs \
	interData/anno.tsv \
	interData/data.tsv \
	interData/pheno.tsv
		Rscript R/heatmap.R

# makes metabolomic PCA plot (with COPD status)
results/pca.png : R/pca.R .created-dirs \
	interData/anno.tsv \
	interData/data.tsv \
	interData/pheno.tsv
		Rscript R/pca.R

# performs PLS-DA analysis to identify important metabolites for COPD status
results/roc.png results/plsdaPerf.png results/indiv.png results/vip.tex : \
	R/plsda.R .created-dirs \
	interData/anno.tsv \
	interData/data.tsv \
	interData/pheno.tsv
		Rscript R/plsda.R

report/report.pdf : report/report.tex .created-dirs \
	results/phenoSummary.tex \
	results/pathSummary.png \
	results/metaboliteCount.png \
	results/outliers.png \
	results/gsea.png \
	results/heat.png \
	results/pca.png \
	results/roc.png \
	results/plsdaPerf.png \
	results/indiv.png \
	results/vip.tex
		cd report; pdflatex report.tex
