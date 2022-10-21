# Introduction
This repository contains code for my final project in the course Biostatistics 611 (Introduction to Data Science) at UNC Chapel Hill. For this project, I intend to analyze data from the Plasma Metabolomic Signatures of COPD Study (doi: 10.21228/M8FQ2X). My primary goals are to 1) identify associations between metabolites and age, sex, BMI, COPD status, and smoker status and 2) investigate how different imputation strategies affect these associations. This project is in an intermediate state, but complete analyses and a report will soon follow.

# Docker
This analysis can be run on any machine using Docker. First, download this repository to a new directory on your machine.

``` sh
git clone https://github.com/frankp-0/bios-611-project.git
cd bios-611-project/
```

Next, build and run a Docker container using the provided Dockerfile.

``` sh
docker build . -t bios611project
docker run --rm -v $(pwd):/home/ -w /home/ -it bios611project /bin/bash
```

If you are unfamiliar with Docker, this tool generates an isolated user space which (ostensibly) has all the depencies required to exactly repeat my analysis.

# Makefile
Once in the Docker container, this analysis can be run using the GNU make workflow tool. Briefly, the Makefile specifies recipes for completing steps of the workflow. For example, to complete the data preprocessing step, run `make cleanData`. Make keeps track of dependencies for each step, so you can just run `make report` to complete all other steps and generate the final report.
