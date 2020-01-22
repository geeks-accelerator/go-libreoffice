FROM lambci/lambda:build-go1.x AS build_base_golang

LABEL maintainer="lee@geeksinthewoods.com"


RUN yum -y update
RUN yum -y  install curl wget

RUN wget http://download.documentfoundation.org/libreoffice/src/5.2.7/libreoffice-5.2.7.2.tar.xz && \
    tar xf libreoffice-5.2.7.2.tar.xz

RUN yum -y install openssl-devel make glibc-devel gcc patch cups-devel perl-CPAN openssl-perl.x86_64

RUN yum -y install perl-IO-Socket-SSL.noarch perl-Archive-Zip.noarch perl-Digest-MD5.x86_64 perl-Digest-Perl-MD5.noarch

RUN yum -y install java-1.6.0-openjdk.x86_64 java-1.6.0-openjdk-devel.x86_64

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum repolist all

RUN yum -y install gperf.x86_64 doxygen.x86_64 libXrandr-devel.x86_64 automake  autoconf \
    libjpeg-devel libpng-devel \
    libtiff-devel gcc libffi-devel gettext-devel libmpc-devel \
    libstdc++46-devel xauth gcc-c++ libtool libX11-devel \
    libXext-devel libXinerama-devel libXi-devel libxml2-devel \
    libXrender-devel libXrandr-devel libXt



#ENV PYTHONPATH=/builddir/build/BUILD/usr/lib/python3.6/dist-packages
RUN pip3 install --user meson
RUN find / -name 'cmake'

RUN wget https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz   && \
    tar -zxvf cmake-3.6.2.tar.gz   && \
    cd cmake-3.6.2   && \
    ./bootstrap --prefix=/usr   && \
    make   && \
    make install

RUN yum -y install libmount-devel

RUN yum -y remove cairo.x86_64 cairo-devel.x86_64
ENV PKG_CONFIG_PATH=/usr/lib64/pkgconfig

RUN wget https://www.cairographics.org/releases/cairo-1.14.12.tar.xz && \
    tar xf cairo-1.14.12.tar.xz && ls . && \
    cd cairo-1.14.12  && \
    ./configure --help && \
     ./configure --prefix=/usr && \
    make   && \
    make install
# --disable-static --enable-tee


RUN find / -name '*ninja*'

ENV LD_LIBRARY_PATH=/lib64:/usr/lib64:/usr/lib:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib
#ENV CAIRO_LIBS=/usr/lib/cairo
ENV PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/lib/pkgconfig


RUN yum -y install ninja-build.x86_64

RUN wget https://github.com/fribidi/fribidi/releases/download/v1.0.8/fribidi-1.0.8.tar.bz2  && \
    tar -xvjf fribidi-1.0.8.tar.bz2 && \
    ls . && cd fribidi-1.0.8 && \
    mkdir build && \
    cd    build && \
    /root/.local/bin/meson configure .. && \
       /root/.local/bin/meson --prefix=/usr .. && \
    ninja && \
    ninja install

RUN yum -y install harfbuzz.x86_64 harfbuzz-devel.x86_64 harfbuzz-icu.x86_64


RUN wget http://ftp.acc.umu.se/pub/gnome/sources/gtk/3.96/gtk-3.96.0.tar.xz  && \
    tar xf gtk-3.96.0.tar.xz  && \
    cd gtk-3.96.0 && \
    ls . && cat README.md && \
    grep -r glib * && \
    /root/.local/bin/meson --prefix=/usr -Dcolord=yes -Dgtk_doc=false -Dman=true -Dbroadway_backend=true _build . && \
    cd _build && ninja && \
    ninja install

# $ meson _build .
  #$ cd _build
  #$ ninja


#RUN cpan -i IO::Socket::SSL Archive::Zip Digest::MD5
RUN cd libreoffice-5.2.7.2 && \
    ./autogen.sh --without-doxygen && \
    make



RUN find / -name 'LibreOfficeKitInit.h'


RUN go get github.com/dveselov/go-libreofficekit

# Enable go modules.
ARG GOPROXY=https://goproxy.io
ENV GOPROXY=$GOPROXY
ENV GO111MODULE="on"
COPY go.mod .
COPY go.sum .
RUN go mod download

ADD main.go .

RUN go run main.go

# https://wiki.documentfoundation.org/Development/BuildingOnLinux
# https://gist.github.com/joekiller/3991486
# https://joekiller.com/2012/06/03/install-firefox-on-amazon-linux-x86_64-compiling-gtk/#comment-6035