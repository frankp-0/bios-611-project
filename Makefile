PHONY : clean
PHONY : getData
PHONY : cleanData

# "reset" project
clean :
	rm -rf sourceData/*
	rm -rf interData/*

# creates necessary directories
.created-dirs :
	mkdir -p sourceData
	mkdir -p interData
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
	sourceData/study_design.txt

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
cleanData : R/cleanData.R .created-dirs \
	interData/data.tsv \
	interData/anno.tsv

# cleans and combines source metabolomic data
# combines annotation data
# use cleanData target when running make
interData/data.tsv interData/anno.tsv : \
	sourceData/neg.txt \
	sourceData/neg_metadata.txt \
	sourceData/polar.txt \
	sourceData/polar_metadata.txt \
	sourceData/pos_early.txt \
	sourceData/pos_early_metadata.txt \
	sourceData/pos_late.txt \
	sourceData/pos_polar_metadata.txt
		Rscript R/cleanData.R
