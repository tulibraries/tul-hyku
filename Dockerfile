ARG HYRAX_IMAGE_VERSION=hyrax-v5.0.0.rc1
FROM harbor.k8s.temple.edu/ghcr-io-proxy/samvera/hyrax/hyrax-base:$HYRAX_IMAGE_VERSION as hyku-base

USER root

RUN apk add -U --no-cache \
  bash=5.2.21-r0 \
  cmake=3.27.8-r0 \
  exiftool=12.70-r0 \
  ffmpeg=6.1.1-r0 \
  git=2.43.0-r0 \
  imagemagick=7.1.1.26-r0 \
  less=643-r1 \
  libreoffice=7.6.3.1-r0 \
  libreoffice-lang-uk=7.6.3.1-r0 \
  libxml2-dev=2.11.7-r0 \
  mediainfo=23.11-r0 \
  nodejs=20.11.1-r0 \
  openjdk17-jre=17.0.10_p7-r0 \
  openjpeg-dev=2.5.0-r3 \
  openjpeg-tools=2.5.0-r3 \
  perl=5.38.2-r0 \
  poppler=23.10.0-r0 \
  poppler-utils=23.10.0-r0 \
  postgresql16-client=16.2-r0 \
  rsync=3.2.7-r4 \
  screen=4.9.1-r1 \
  tesseract-ocr=5.3.3-r1 \
  vim=9.0.2127-r0 \
  yarn=1.22.19-r0 \
&& \
  # curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  # source "$HOME/.cargo/env" && \
  # cargo install rbspy && \
  echo "******** Packages Installed *********"

RUN wget --progress=dot:giga https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.0-57.tar.gz \
    && tar xf 7.1.0-57.tar.gz \
    && apk --no-cache add \
      libjpeg-turbo=3.0.1-r0 openjpeg=2.5.0-r3 libpng=1.6.40-r0 tiff=4.6.0-r0 librsvg=2.57.1-r0 libgsf=1.14.51-r0 libimagequant=4.2.2-r0 poppler-qt5-dev=23.10.0-r0 \
    && WORKDIR ImageMagick* \
    && ./configure \
    && make install \
    && WORKDIR "$OLDPWD" \
    && rm -rf ImageMagick* \
    && rm -rf /var/cache/apk/*

ARG VIPS_VERSION=8.11.3

SHELL ["/bin/bash", "-xo", "pipefail"]
RUN wget -O- --progress=dot:giga https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz | tar xzC /tmp \
    && apk --no-cache add \
     libjpeg-turbo=3.0.1-r0 openjpeg=2.5.0-r3 libpng=1.6.40-r0 tiff=4.6.0-r0 librsvg=2.57.1-r0 libgsf=1.14.51-r0 libimagequant=4.2.2-r0 poppler-qt5-dev=23.10.0-r0 \
    && apk add --no-cache --virtual vips-dependencies build-base=0.5-r3 \
     libjpeg-turbo-dev=3.0.1-r0 libpng-dev=1.6.40-r0 tiff-dev=4.6.0-r0 librsvg-dev=2.57.1-r0 libgsf-dev=1.14.51-r0 libimagequant-dev=4.2.2-r0 \
    && WORKDIR "/tmp/vips-${VIPS_VERSION}" \
    && ./configure --prefix=/usr \
                   --disable-static \
                   --disable-dependency-tracking \
                   --enable-silent-rules \
    && make -s install-strip \
    && WORKDIR "$OLDPWD" \
    && rm -rf "/tmp/vips-${VIPS_VERSION}" \
    && apk del --purge vips-dependencies \

USER app

RUN mkdir -p /app/fits && \
    WORKDIR /app/fits && \
    wget --progress=dot:giga https://github.com/harvard-lts/fits/releases/download/1.5.5/fits-1.5.5.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"
# Change the order so exif tool is better positioned and use the biggest size if more than one
# size exists in an image file (pyramidal tifs mostly)
COPY --chown=1001:101 ./ops/fits.xml /app/fits/xml/fits.xml
COPY --chown=1001:101 ./ops/exiftool_image_to_fits.xslt /app/fits/xml/exiftool/exiftool_image_to_fits.xslt
RUN ln -sf /usr/lib/libmediainfo.so.0 /app/fits/tools/mediainfo/linux/libmediainfo.so.0 && \
  ln -sf /usr/lib/libzen.so.0 /app/fits/tools/mediainfo/linux/libzen.so.0

COPY --chown=1001:101 ./bin/db-migrate-seed.sh /app/samvera/

ONBUILD ARG APP_PATH=.
ONBUILD COPY --chown=1001:101 $APP_PATH/Gemfile* /app/samvera/hyrax-webapp/
ONBUILD RUN git config --global --add safe.directory /app/samvera && \
  bundle install --jobs "$(nproc)"

ONBUILD COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp

USER nobody

FROM hyku-base as hyku-web
RUN RAILS_ENV=production SECRET_KEY_BASE=$(bin/rake secret) DB_ADAPTER=nulldb DB_URL='postgresql://fake' bundle exec rake assets:precompile && yarn install && yarn cache clean

CMD ["./bin/web"]

FROM hyku-web as hyku-worker
CMD ["./bin/worker"]