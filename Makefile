PHONY: clean

clean:
	rm interData/*

interData/ids.txt: sourceData/metabolon_ids.csv sourceData/broad_ids.csv
	mkdir -p interData
	cd src; Rscript getIDs.R

interData/metabolon.txt: sourceData/Metabolon.txt sourceData/metabolonAnnotation.txt
	mkdir -p interData
	cd src; Rscript cleanMetabolon.R

interData/broad.txt:\
	sourceData/C8-pos.txt sourceData/C18-neg.txt sourceData/HILIC-pos.txt sourceData/Amide-neg.txt
	mkdir -p interData
	cd src; Rscript cleanBroad.R
