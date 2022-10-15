PHONY : clean
PHONY : getData

clean :
	rm -rf sourceData/*
	rm -rf interData/*

# creates necessary directories
.created-dirs :
	mkdir -p sourceData
	mkdir -p interData
	touch .created-dirs

# phony target which depends on source data
getData : src/getData.sh .created-dirs \
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
