PHONY : clean
PHONY : getData
PHONY : cleanData
PHONY : summarize

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

report/report.pdf : report/report.tex .created-dirs \
	results/phenoSummary.tex \
	results/pathSummary.png \
	results/metaboliteCount.png \
	results/outliers.png
		cd report; pdflatex report.tex
