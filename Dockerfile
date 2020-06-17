# first build all the gdal/libgeos stuff

FROM osgeo/gdal:alpine-ultrasmall-latest

ARG PY_WOF_UTILS_VERSION=1.0.0
ARG PY_WOF_EXPORT_VERSION=1.0.0
ARG WWW_WOF_EXPORTIFY_VERSION=0.0.7

RUN apk update && apk upgrade \
    && apk add git gcc libc-dev python3-dev ca-certificates py3-pip wget build-base \
    #
    && pip3 install gevent \
    && pip3 install gunicorn \
    && pip3 install pygdal=="`gdal-config --version`.*" \
    #
    && mkdir /build \
    #
    # Something to note here is that the URLs for py-mapzen-whosonfirst-utils and py-mapzen-whosonfirst-export
    # are subtlely different. Specifically the latter uses the `vX.Y.Z` convention for releases and the former
    # does not. The next release of py-mapzen-whosonfirst-utils (0.4.6) should use the updated convention so
    # we'll need to update this when it does. Could I just make a new release and be done with it? Yes, I could
    # but today I did not... (20190626/thisisaaronland)
    #
    && cd /build \
    && wget -O utils.tar.gz https://github.com/whosonfirst/py-mapzen-whosonfirst-utils/archive/${PY_WOF_UTILS_VERSION}.tar.gz && tar -xvzf utils.tar.gz \
    && cd py-mapzen-whosonfirst-utils-${PY_WOF_UTILS_VERSION} \
    && pip3 install -r requirements.txt . \
    && cp -r scripts/. /usr/local/bin/ \
    #
    && cd /build \
    && wget -O export.tar.gz https://github.com/whosonfirst/py-mapzen-whosonfirst-export/archive/v${PY_WOF_EXPORT_VERSION}.tar.gz && tar -xvzf export.tar.gz \
    && cd py-mapzen-whosonfirst-export-${PY_WOF_EXPORT_VERSION} \
    && pip3 install -r requirements.txt . \
    && cp -r scripts/. /usr/local/bin/ \
    #
    # wof-exportify-www.py is required by gunicorn
    # wof-exportify-www is for everyone else...
    #
    && cd /build \
    && wget -O exportify.tar.gz https://github.com/whosonfirst/whosonfirst-www-exportify/archive/v${WWW_WOF_EXPORTIFY_VERSION}.tar.gz && tar -xvzf exportify.tar.gz \
    && cd whosonfirst-www-exportify-${WWW_WOF_EXPORTIFY_VERSION} \
    && pip3 install -r requirements.txt \
    && cp www/server.py /usr/local/bin/wof-exportify-www.py  \
    && ln -s /usr/local/bin/wof-exportify-www.py /usr/local/bin/wof-exportify-www \
    #
    && cd / && rm -rf /build
