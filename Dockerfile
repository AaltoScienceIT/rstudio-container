FROM ubuntu:bionic

# Set versions and platforms
ARG R_VERSION=3.6.2
ARG DRIVERS_VERSION=1.6.0

# Install RStudio Server Pro session components

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    gdebi \
    libcurl4-gnutls-dev \
    libssl1.0.0 \
    libssl-dev \
    libuser \
    libuser1-dev \
    rrdtool

# Install additional system packages

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    libssl1.0.0 \
    libuser \
    libxml2-dev \
    subversion

# Install R

RUN curl -O https://cdn.rstudio.com/r/ubuntu-1804/pkgs/r-${R_VERSION}_1_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive r-${R_VERSION}_1_amd64.deb && \
    rm -f *.deb

RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# Install R packages

RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("devtools", repos="https://demo.rstudiopm.com/cran/__linux__/bionic/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("tidyverse", repos="https://demo.rstudiopm.com/cran/__linux__/bionic/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("shiny", repos="https://demo.rstudiopm.com/cran/__linux__/bionic/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("rmarkdown", repos="https://demo.rstudiopm.com/cran/__linux__/bionic/latest")'

# Install Rstudio Desktop and required libraries

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg && \
    curl -O https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.2.5033-amd64.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i --force-depends rstudio-1.2.5033-amd64.deb && \
    DEBIAN_FRONTEND=noninteractive apt-get -f install -y && \ 
    DEBIAN_FRONTEND=noninteractive apt-get -y install -y libxslt1.1 libasound2 libnss3 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libcanberra-gtk-module libcanberra-gtk3-module && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y unity-gtk3-module && \
    rm -f *.deb

# Install RStudio Professional Drivers

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y unixodbc unixodbc-dev gdebi

RUN curl -O https://drivers.rstudio.org/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    rm -f *.deb

RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("odbc", repos="https://demo.rstudiopm.com/cran/__linux__/bionic/latest")'

# Locale configuration

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Command to run

CMD XDG_RUNTIME_DIR="" rstudio
