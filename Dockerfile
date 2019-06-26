# FROM alpine:latest
FROM whosonfirst-exportify-geo

ARG PYMZWOF_UTILS_VERSION=0.4.5
ARG PYMZWOF_EXPORT_VERSION=0.9.6

RUN apk update && apk upgrade \
    && apk add coreutils git make ca-certificates py-pip \
    && mkdir /build \    
    #
    # Something to note here is that the URLs for py-mapzen-whosonfirst-utils and py-mapzen-whosonfirst-export
    # are subtlely different. Specifically the latter uses the `vX.Y.Z` convention for releases and the former
    # does not. The next release of py-mapzen-whosonfirst-utils (0.4.6) should use the updated convention so
    # we'll need to update this when it does. Could I just make a new release and be done with it? Yes, I could
    # but today I did not... (20190626/thisisaaronland)
    #
    && cd /build \
    && wget -O utils.tar.gz https://github.com/whosonfirst/py-mapzen-whosonfirst-utils/archive/${PYMZWOF_UTILS_VERSION}.tar.gz && tar -xvzf utils.tar.gz \
    && cd py-mapzen-whosonfirst-utils-${PYMZWOF_UTILS_VERSION} \
    && pip install -r requirements.txt . \
    #
    && cd /build \    
    && wget -O export.tar.gz https://github.com/whosonfirst/py-mapzen-whosonfirst-export/archive/v${PYMZWOF_EXPORT_VERSION}.tar.gz && tar -xvzf export.tar.gz \
    && cd py-mapzen-whosonfirst-export-${PYMZWOF_EXPORT_VERSION} \
    && pip install -r requirements.txt . \
    #
    && cd / && rm -rf /build