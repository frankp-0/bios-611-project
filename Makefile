PHONY: clean

clean:
	rm interData/*

# generates single table linking subject and TOPMED IDs for both platforms
interData/ids.txt: sourceData/metabolon_ids.csv sourceData/broad_ids.csv
	mkdir -p interData
	cd src; Rscript getIDs.R

# generates cleaned Metabolon data file
# removes metabolites with low confidence (of identification)
# removes metabolites with high missingness (>80%)
interData/metabolon.txt: sourceData/Metabolon.txt sourceData/metabolonAnnotation.txt
	mkdir -p interData
	cd src; Rscript cleanMetabolon.R

# generates cleaned Broad data file
# removes header info and transposes Broad files
# joins Broad analyses to single table, prioritizing Amide-neg assay for duplicate metabolites
interData/broad.txt:\
	sourceData/C8-pos.txt sourceData/C18-neg.txt sourceData/HILIC-pos.txt sourceData/Amide-neg.txt
	mkdir -p interData
	cd src; Rscript cleanBroad.R
