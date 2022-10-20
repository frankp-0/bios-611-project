FROM phusion/baseimage:jammy-1.0.1
RUN apt update && apt install -y \
    r-base=4.1.2-1ubuntu2 \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev
RUN R -e 'install.packages(c("reprex", "rvest", "xml2"))'
RUN R -e 'install.packages("tidyverse")'
RUN R -e 'install.packages("gt")'
