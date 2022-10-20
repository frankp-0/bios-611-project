PHONY : clean
PHONY : getData
PHONY : cleanData
PHONY : summarize

# "reset" project
clean :
	rm -rf sourceData/*
	rm -rf interData/*
	rm -rf results/*

# creates necessary directories
.created-dirs :
	mkdir -p sourceData
	mkdir -p interData
	mkdir -p results
	touch .created-dirs

# phony target used to get source data
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

# phony target used to clean data
cleanData : interData/data.tsv interData/anno.tsv interData/pheno.tsv

# cleans and combines source metabolomic data
# combines annotation data
# use cleanData target when running make
interData/data.tsv interData/anno.tsv interData/pheno.tsv : R/cleanData.R .created-dirs \
	sourceData/neg.txt \
	sourceData/neg_metadata.txt \
	sourceData/polar.txt \
	sourceData/polar_metadata.txt \
	sourceData/pos_early.txt \
	sourceData/pos_early_metadata.txt \
	sourceData/pos_late.txt \
	sourceData/pos_polar_metadata.txt
		Rscript R/cleanData.R

# phony target used to summarize data
summarize : results/pathSummary.png results/metaboliteCount.png

# generates figures summarizing missingness in cleaned data
results/pathSummary.png results/metaboliteCount.png : R/summarize.R .created-dirs \
	interData/anno.tsv \
	interData/data.tsv \
	interData/pheno.tsv
		Rscript R/summarize.R
