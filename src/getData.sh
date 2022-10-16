#!/usr/bin/env sh

curl https://www.metabolomicsworkbench.org/studydownload/ST001639.zip --output sourceData/data.zip
unzip sourceData/data.zip -d sourceData/
tar -xf sourceData/ST001639/SPIROMICS_metabolon.tar -C sourceData
