FROM alpine:latest

# https://proj4.org/download.html
# https://download.osgeo.org/geos
# https://download.osgeo.org/gdal/

ARG LIBGEOS_VERSION=3.7.2
ARG LIBGDAL_VERSION=3.0.0
ARG LIBPROJ_VERSION=6.1.0

RUN apk update && apk upgrade \
    && apk add coreutils git make ca-certificates py-pip libc-dev gcc g++ python-dev \
    #
    # https://github.com/appropriate/docker-postgis/blob/master/Dockerfile.alpine.template
    #
    # && apk add --no-cache --virtual .build-deps-edge \
    #    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    #    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    #    gdal-dev geos-dev proj4-dev \
    #
    # or the hard way which takes _forever_ to build and doesn't always work...
    # but we're going to do things the hard way because the above no longer works
    # and doesn't return any useful error messages... (20190612/thisisaaronland)
    #
    && apk add libc-dev gcc g++ linux-headers python-dev sqlite sqlite-dev \       
    && mkdir /build \
    #
    && cd /build \
    && wget https://download.osgeo.org/proj/proj-${LIBPROJ_VERSION}.tar.gz && tar -xvzf proj-${LIBPROJ_VERSION}.tar.gz \
    && cd proj-${LIBPROJ_VERSION} && ./configure && make && make install \
    #
    && cd /build \
    && wget https://download.osgeo.org/geos/geos-${LIBGEOS_VERSION}.tar.bz2 && tar -xvjf geos-${LIBGEOS_VERSION}.tar.bz2 \
    && cd geos-${LIBGEOS_VERSION} && ./configure && make && make install \
    #
    && cd /build \
    && wget https://download.osgeo.org/gdal/${LIBGDAL_VERSION}/gdal-${LIBGDAL_VERSION}.tar.gz && tar -xvzf gdal-${LIBGDAL_VERSION}.tar.gz \
    && cd gdal-${LIBGDAL_VERSION} && ./configure && make && make install \
    #       
    && pip install gdal \
    #
    && cd / && rm -rf /build