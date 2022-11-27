FROM phusion/baseimage:jammy-1.0.1
RUN apt update && apt install -y \
    r-base=4.1.2-1ubuntu2 \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev
RUN R -e 'install.packages(c("reprex", "rvest", "xml2"))'
RUN R -e 'install.packages("tidyverse")'
RUN R -e 'install.packages("gt")'
RUN apt update && apt install -y libfontconfig1-dev
RUN R -e 'install.packages("vtable")'
RUN apt update && apt install -y pandoc
RUN apt update && apt install -y texlive-latex-extra
RUN apt update && apt install -y texlive-extra-utils
RUN R -e 'install.packages("BiocManager")'
RUN R -e 'BiocManager::install("clusterProfiler")'
Run R -e 'BiocManager::install("mixOmics")'
