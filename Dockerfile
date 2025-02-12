# start with the ropensci image including debian:testing, r-base, rocker/rstudio, rocker/hadleyverse
# https://hub.docker.com/r/rocker/ropensci/
FROM quay.io/battelleecology/rstudio:4.0.5
#
WORKDIR /home/NCAR-NEON
# copy clone of GitHub source repo "NEONScience/NEON-FIU-algorithm" to the Docker image
COPY . .

# Build R dependencies using two cpu's worth of resources
ENV MAKEFLAGS='-j3'

# install OS-side dependencies: EBImage -> fftwtools -> fftw3, REddyProc -> RNetCDF -> udunits

  	# update the list of available packages and their versions

    RUN apt-get update \
    && apt-get dist-upgrade -y \
    && RUNDEPS="libudunits2-dev \
            udunits-bin \
            hdf5-helpers \
            libhdf5-cpp-103 \
            libhdf5-103 \
            libsz2 \
            libmysql++3v5 \
            libmariadb3 \
            libpng-tools \
            libproj-dev \
			      libssl-dev \
			      libgdal-dev \
			      libnetcdf-dev \
			      libgsl-dev \
			      # Library for git via ssh key
			      ssh \
			      vim \
            libxml2-dev" \
            #mysql-common" \
            #fftw3\
            #libnetcdf11 \
    && BUILDDEPS="libhdf5-dev \
                  libjpeg-dev \
                 libtiff5-dev \
                 libpng-dev \
                 " \
                 #libmysql++-dev \
                 #fftw3-dev \
                 
    && apt-get install -y $BUILDDEPS $RUNDEPS \

    # Installing R package dependencies that are only workflow related (including CI combiner)
    && install2.r --error --repos "https://mran.microsoft.com/snapshot/2021-05-17"\ 
    #"https://cran.rstudio.com/"\
    devtools \
    BiocManager \
    REddyProc \
    ncdf4 \
    reshape2 \
    ggplot2 \
    gridExtra \
    #tidyverse \
    naniar \
    #aws.s3 \
    neonUtilities \
    googleCloudStorageR \
    
     ## from bioconductor
    && R -e "BiocManager::install('rhdf5', update=FALSE, ask=FALSE)" \
    
    && R -e "install.packages('Rfast')" \
    #Install packages from github repos
   # && R -e "devtools::install_github('NEONScience/eddy4R/pack/eddy4R.base')" \
    && R -e "devtools::install(pkg = 'gapFilling/pack/NEON.gf', dependencies=TRUE, upgrade = TRUE)" \

    # provide read and write access for default R library location to Rstudio users
    && chmod -R 777 /usr/local/lib/R/site-library \
    # Clean up build dependencies
    && apt-get remove --purge -y $BUILDDEPS \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* \
    # Clean up the rocker image leftovers
    && rm -rf /tmp/rstudio* \
    && rm -rf /tmp/Rtmp* \
