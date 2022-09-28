## Emacs, make this -*- mode: sh; -*-
FROM rocker/r-ubuntu:18.04
#FROM debian:testing

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rocker-org/r-base" \
      org.label-schema.vendor="Rocker Project" \
      maintainer="Dirk Eddelbuettel <edd@debian.org>"

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
#RUN useradd docker \
#	&& mkdir /home/docker \
#	&& chown docker:docker /home/docker \
#	&& addgroup docker staff

RUN chmod -R ugo+rx /root \
  && umask u=rwx,g=rwx,o=rx	\
  && apt-get update \
	&& apt-get install -y --no-install-recommends \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		fonts-texgyre libx11-dev\
        vim \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
                dirmngr \
                ed \
		less \
		locales \
		vim-tiny \
		wget curl libcurl4-openssl-dev \
		ca-certificates \
        && add-apt-repository --enable-source --yes "ppa:marutter/rrutter4.0" \
        && add-apt-repository --enable-source --yes "ppa:c2d4u.team/c2d4u4.0+"

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
#RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
#        && echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default
#
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libx11-6 \
    libxss1 \
    libxt6 \
    libxext6 \
    libsm6 \
    libice6 \
    r-cran-png \
    xdg-utils libxt-dev xorg-dev libcairo2 libcairo2-dev libpango1.0-dev firefox \
  && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt -y install zlib1g-dev
RUN apt -y install libcurl4-openssl-dev \
                    libxml2-dev \
                    libssl-dev \
                    libpng-dev \
                    libhdf5-dev \
                    libgfortran3
 

#ENV R_VERSION=3.5.1
#RUN curl -O https://cran.rstudio.com/src/base/R-3/R-${R_VERSION}.tar.gz
#RUN tar -xzvf R-${R_VERSION}.tar.gz
#WORKDIR R-${R_VERSION}

RUN pwd
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-py37_4.8.2-Linux-x86_64.sh  -b \
    && rm -f Miniconda3-py37_4.8.2-Linux-x86_64.sh

RUN conda --version

RUN conda config --append channels defaults
RUN conda config --append channels anaconda
RUN conda config --append channels bioconda
RUN conda config --append channels conda-forge
RUN conda config --append channels bu_cnio
RUN conda config --append channels esgf

RUN conda install -c conda-forge mamba

RUN conda init bash

### For .yml method
COPY environment.yml .
RUN mamba env update -f environment.yml

### For .txt method
#COPY conda_pkg.txt .
#RUN PKGS=`cat conda_pkg.txt |grep -P -v -i "r-l2p|^r-vector|^r-foundr|spark|snappy|python-file-paths|foundry|networkx|decorator|umap-learn" | tr " " "="  | tr "\n" " "`; mamba install $PKGS


RUN echo "source activate single-cell-test-Rbase" > ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH

RUN chmod -R ugo+rx /opt
RUN chmod -R ugo+rx /tmp
RUN echo "TMPDIR=/mnt" > /root/.Renviron

CMD ["bash"]




