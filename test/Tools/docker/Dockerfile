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

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
		fonts-texgyre libx11-dev\
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
RUN apt -y install libcurl4-openssl-dev
RUN apt -y install libxml2-dev
RUN apt -y install libssl-dev
RUN apt -y install libpng-dev
RUN apt -y install libhdf5-dev
RUN apt -y install iputils-ping

#ENV R_VERSION=3.5.1
#RUN curl -O https://cran.rstudio.com/src/base/R-3/R-${R_VERSION}.tar.gz
#RUN tar -xzvf R-${R_VERSION}.tar.gz
#WORKDIR R-${R_VERSION}
RUN pwd
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*




#RUN wget \
#    https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
#    && mkdir /root/.conda \
#    && bash Miniconda3-py37_4.8.2-Linux-x86_64.sh  -b \
#    && rm -f Miniconda3-py37_4.8.2-Linux-x86_64.sh
#RUN wget \
#    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#    && mkdir /root/.conda \
#    && bash Miniconda3-latest-Linux-x86_64.sh  -b \
#    && rm -f Miniconda3-latest-Linux-x86_64.sh
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-py37_4.8.2-Linux-x86_64.sh  -b \
    && rm -f Miniconda3-py37_4.8.2-Linux-x86_64.sh

RUN conda --version
#artifacts-external-conda-anaconda:
#priority: 1
#artifacts-internal-conda-thirdparty:
#priority: 2
#artifacts-external-conda-bioconda:
#priority: 3
#artifacts-external-conda-forge:
#priority: 4
#artifacts-external-conda-bu-cnio:
#priority: 5

#RUN conda config --remove channels defaults
RUN conda config --append channels  anaconda
RUN conda config --append channels  bioconda
RUN conda config --append channels conda-forge
#RUN conda config --append channels bu_cnio
#RUN conda config --append channels  esgf

#RUN conda install -c conda-forge python=3.6.9=h9d8adfe_0_cpython
RUN conda install -c conda-forge  mamba
#RUN conda install -c conda-forge libffi=3.2.1=hf484d3e_1007 libcurl=7.79.1=h2574ce0_1
#RUN conda install tbb=2021.5.0=h4bd325d_0 umap-learn-0.4.6-py36h9f0ad1d_0
#RUN conda install -c esgf krb5=1.19.2=hcc1bbae_2
#RUN conda install scikit-learn=0.24.2=py36hc89565f_1 scikit-image-0.17.2-py36h284efc9_4 umap-learn-0.4.6-py36h9f0ad1d_0

COPY r-rcpp-1.0.6-r35hbad8821_0.tar.bz2 /tmp
COPY r-rlang-0.4.10-r35hbad8821_3.tar.bz2 /tmp


#RUN mamba install /tmp/r-rcpp-1.0.6-r35hbad8821_0.tar.bz2
#RUN mamba install /tmp/r-rlang-0.4.10-r35hbad8821_3.tar.bz2
#RUN mamba install  r-rcppprogress=0.4.2 


#RUN PKGS=`cat conda-direct-packages.txt |grep -P -v "r-rcpp|^vector-|^r-foundr|spark|snappy|foundry|umap-learn"| tr " " "="  | tr "\n" " "` 


COPY conda_pkg2.txt .
RUN wget https://github.com/CCBR/l2p/blob/master/r-l2psupp-0.0_13-r35_0.tar.bz2?raw=true -O /tmp/r-l2psupp-0.0_13-r35_0.tar.bz2
RUN wget https://github.com/CCBR/l2p/blob/master/r-l2p-0.0_13-r35_0.tar.bz2?raw=true -O /tmp/r-l2p-0.0_13-r35_0.tar.bz2
RUN wget https://cran.r-project.org/src/contrib/Archive/arrow/arrow_1.0.0.tar.gz -O /tmp/arrow_1.0.0.tar.gz

RUN PKGS=`cat conda_pkg2.txt |grep -P -v -i "r-l2p|^r-vector|^r-foundr|spark|snappy|python-file-paths|foundry|networkx|decorator|umap-learn" | tr " " "="  | tr "\n" " "`; mamba install $PKGS


# Install in a conda enviroment

RUN mamba install /tmp/r-l2p-0.0_13-r35_0.tar.bz2 /tmp/r-l2psupp-0.0_13-r35_0.tar.bz2
RUN R CMD INSTALL /tmp/arrow_1.0.0.tar.gz



CMD ["bash"]
CMD ["sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf"]
