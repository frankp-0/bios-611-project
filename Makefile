PHONY : clean
PHONY : getData

clean :
	rm -rf sourceData/*
	rm -rf interData/*

.created-dired :
	mkdir -p sourceData
	mkdir -p interData
	touch .created-dirs

getData : neg.txt \
	neg_metadata.txt \
	polar.txt \
	polar_metadata.txt \
	pos_early.txt \
	pos_early_metadata.txt \
	pos_late.txt \
	pos_polar_metadata.txt \
	study_design.txt

neg.txt \
	neg_metadata.txt \
	polar.txt \
	polar_metadata.txt \
	pos_early.txt \
	pos_early_metadata.txt \
	pos_late.txt \
	pos_polar_metadata.txt \
	study_design.txt :
		bash src/getData.sh
