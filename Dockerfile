FROM python:2.7.18-slim

# Ensures Python output is sent straight to the terminal (no buffering)
ENV PYTHONUNBUFFERED=1

# Install prerequisite packages needed for mwlib
RUN apt-get update  \
    && mkdir -p /usr/share/man/man1 \
    && apt-get install -y --no-install-recommends \
    ca-certificates-java \
    default-jre-headless \
    build-essential \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libncurses-dev \
    libffi-dev \
    pdftk \
    imagemagick \
    locales \
    fontconfig \
    # Required for Pillow
    libjpeg-dev \
    # Required for RTL support
    libfribidi-dev \
    # Font packages
    fonts-arphic-uming \
    fonts-farsiweb \
    fonts-unfonts-core \
    fonts-thai-tlwg \
    fonts-lohit-* \
    fonts-gubbi \
    fonts-sarai \
    fonts-kalapi \
    fonts-smc \
    fonts-khmeros \
    fonts-tlwg-garuda \
    fonts-tlwg-garuda-ttf \
    fonts-sil-padauk \
    # Latin fonts
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install mwlib and other required libraries with specific versions
RUN pip install --no-cache-dir mwlib==0.16.2 qserve==0.2.8 mwlib.rl==0.14.5 pyfribidi==0.12.0 pillow==6.2.2

# Fix Pillow/ReportLab compatibility issues
RUN sed -i 's/self._data = im.tostring()/self._data = im.tobytes()/g' /usr/local/lib/python2.7/site-packages/mwlib/ext/reportlab/lib/utils.py && \
    find /usr/local/lib/python2.7/site-packages/mwlib -type f -name "*.py" -exec sed -i 's/\.tostring()/\.tobytes()/g' {} +

# Create font symlinks
RUN mkdir -p /usr/share/fonts/truetype/custom \
    && cd /usr/share/fonts/truetype \
    && ln -s ../arphic/uming.ttc custom/AR\ PL\ UMing\ HK.ttf \
    && ln -s ../farsiweb/nazli.ttf custom/Nazli.ttf \
    && ln -s ../unfonts-core/UnBatang.ttf custom/UnBatang.ttf \
    && ln -s ../lohit-telugu/Lohit-Telugu.ttf custom/Lohit\ Telugu.ttf \
    && ln -s ../Sarai/Sarai.ttf custom/Sarai.ttf \
    && ln -s ../lohit-gujarati/Lohit-Gujarati.ttf custom/Gujarati.ttf \
    && ln -s ../lohit-punjabi/Lohit-Punjabi.ttf custom/Lohit\ Punjabi.ttf \
    && ln -s ../lohit-oriya/Lohit-Oriya.ttf custom/Lohit\ Oriya.ttf \
    && ln -s ../malayalam/AnjaliOldLipi.ttf custom/AnjaliOldLipi.ttf \
    && ln -s ../Gubbi/Gubbi.ttf custom/Kedage.ttf \
    && ln -s ../lohit-tamil/Lohit-Tamil.ttf custom/Lohit\ Tamil.ttf \
    && ln -s ../khmeros/KhmerOS.ttf custom/Khmer.ttf \
    && ln -s ../tlwg/Garuda.ttf custom/Arundina\ Serif.ttf \
    && ln -s ../tlwg/Garuda.ttf custom/LikhanNormal.ttf \
    # Add Liberation font symlinks
    && ln -s liberation/LiberationSans-Regular.ttf custom/Liberation\ Sans.ttf \
    && ln -s liberation/LiberationSerif-Regular.ttf custom/Liberation\ Serif.ttf \
    && ln -s liberation/LiberationMono-Regular.ttf custom/Liberation\ Mono.ttf \
    && fc-cache -f -v

VOLUME /var/cache/mwlib
EXPOSE 8899

# Start services
CMD ["/bin/bash", "-c", "nserve & mw-qserve & nslave --cachedir /var/cache/mwlib"]
