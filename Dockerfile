FROM python:2.7.18-slim

# Ensures Python output is sent straight to the terminal (no buffering)
ENV PYTHONUNBUFFERED=1

# Point to the Debian Stretch archive repositories
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

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
    patch \
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

# Apply all patches for source code modifications
COPY patches/ /tmp/patches/
RUN cd /usr/local/lib/python2.7/site-packages/mwlib && \
    patch -p0 < /tmp/patches/nserve.patch || (echo "Failed to apply nserve.patch" && cat /tmp/patches/nserve.patch && exit 1) && \
    cd /usr/local/lib/python2.7/site-packages/PIL && \
    patch -p0 < /tmp/patches/pngimageplugin.patch || (echo "Failed to apply pngimageplugin.patch" && exit 1) && \
    sed -i 's/self._data = im.tostring()/self._data = im.tobytes()/g' /usr/local/lib/python2.7/site-packages/mwlib/ext/reportlab/lib/utils.py && \
    find /usr/local/lib/python2.7/site-packages/mwlib -type f -name "*.py" -exec sed -i 's/\.tostring()/\.tobytes()/g' {} + && \
    rm -rf /tmp/patches

# mwlib.rl's stock fontconfig.py resolves fonts ONLY from its package dir and
# ~/mwlibfonts/, using the legacy file_names below — it never scans
# /usr/share/fonts. Populate /root/mwlibfonts/ accordingly (absolute paths so
# the layout survives a future USER switch, failing loudly instead).
# Sources verified present in python:2.7.18-slim (stretch archive) packages above.
RUN set -e; F=/root/mwlibfonts; mkdir -p "$F"/customnazli "$F"/unfonts "$F"/ttf-thai-arundina \
    "$F"/ttf-telugu-fonts "$F"/ttf-devanagari-fonts "$F"/ttf-indic-fonts-core \
    "$F"/ttf-oriya-fonts "$F"/ttf-malayalam-fonts "$F"/ttf-kannada-fonts \
    "$F"/ttf-bengali-fonts "$F"/ttf-khmeros-core "$F"/arphic "$F"/customliberation \
    /usr/share/fonts/truetype/custom \
    && ln -sf /usr/share/fonts/truetype/farsiweb/nazli.ttf "$F"/customnazli/nazli.ttf \
    && ln -sf /usr/share/fonts/truetype/farsiweb/nazli.ttf "$F"/customnazli/nazli-italic.ttf \
    && ln -sf /usr/share/fonts/truetype/farsiweb/nazlib.ttf "$F"/customnazli/nazlib.ttf \
    && ln -sf /usr/share/fonts/truetype/farsiweb/nazlib.ttf "$F"/customnazli/nazlib-italic.ttf \
    && ln -sf /usr/share/fonts/truetype/unfonts-core/UnBatang.ttf "$F"/unfonts/UnBatang.ttf \
    && ln -sf /usr/share/fonts/truetype/tlwg/Garuda.ttf "$F"/ttf-thai-arundina/ArundinaSans.ttf \
    && ln -sf /usr/share/fonts/truetype/tlwg/Garuda-Bold.ttf "$F"/ttf-thai-arundina/ArundinaSans-Bold.ttf \
    && ln -sf /usr/share/fonts/truetype/tlwg/Garuda-Oblique.ttf "$F"/ttf-thai-arundina/ArundinaSans-Oblique.ttf \
    && ln -sf /usr/share/fonts/truetype/tlwg/Garuda-BoldOblique.ttf "$F"/ttf-thai-arundina/ArundinaSans-BoldOblique.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-telugu/Lohit-Telugu.ttf "$F"/ttf-telugu-fonts/lohit_te.ttf \
    && ln -sf /usr/share/fonts/truetype/Sarai/Sarai.ttf "$F"/ttf-devanagari-fonts/Sarai_07.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-gujarati/Lohit-Gujarati.ttf "$F"/ttf-indic-fonts-core/lohit_gu.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-punjabi/Lohit-Gurmukhi.ttf "$F"/ttf-indic-fonts-core/lohit_pa.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-tamil/Lohit-Tamil.ttf "$F"/ttf-indic-fonts-core/lohit_ta.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-oriya/Lohit-Odia.ttf "$F"/ttf-oriya-fonts/lohit_or.ttf \
    && ln -sf /usr/share/fonts/truetype/malayalam/AnjaliOldLipi-Regular.ttf "$F"/ttf-malayalam-fonts/AnjaliOldLipi.ttf \
    && ln -sf /usr/share/fonts/truetype/Gubbi/Gubbi.ttf "$F"/ttf-kannada-fonts/Kedage-n.ttf \
    && ln -sf /usr/share/fonts/truetype/Gubbi/Gubbi.ttf "$F"/ttf-kannada-fonts/Kedage-b.ttf \
    && ln -sf /usr/share/fonts/truetype/Gubbi/Gubbi.ttf "$F"/ttf-kannada-fonts/Kedage-i.ttf \
    && ln -sf /usr/share/fonts/truetype/Gubbi/Gubbi.ttf "$F"/ttf-kannada-fonts/Kedage-t.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-bengali/Lohit-Bengali.ttf "$F"/ttf-bengali-fonts/LikhanNormal.ttf \
    && ln -sf /usr/share/fonts/truetype/khmeros/KhmerOS.ttf "$F"/ttf-khmeros-core/KhmerOS.ttf \
    && ln -sf /usr/share/fonts/truetype/arphic/uming.ttc "$F"/arphic/uming.ttc \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf "$F"/customliberation/Liberation\ Sans.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf "$F"/customliberation/Liberation\ Sans-Bold.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSans-Italic.ttf "$F"/customliberation/Liberation\ Sans-Italic.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSans-BoldItalic.ttf "$F"/customliberation/Liberation\ Sans-BoldItalic.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf "$F"/customliberation/Liberation\ Serif.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf "$F"/customliberation/Liberation\ Serif-Bold.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSerif-Italic.ttf "$F"/customliberation/Liberation\ Serif-Italic.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSerif-BoldItalic.ttf "$F"/customliberation/Liberation\ Serif-BoldItalic.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf "$F"/customliberation/Liberation\ Mono.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf "$F"/customliberation/Liberation\ Mono-Bold.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationMono-Italic.ttf "$F"/customliberation/Liberation\ Mono-Italic.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationMono-BoldItalic.ttf "$F"/customliberation/Liberation\ Mono-BoldItalic.ttf \
    && ln -sf /usr/share/fonts/truetype/arphic/uming.ttc "/usr/share/fonts/truetype/custom/AR PL UMing HK.ttf" \
    && ln -sf /usr/share/fonts/truetype/farsiweb/nazli.ttf /usr/share/fonts/truetype/custom/Nazli.ttf \
    && ln -sf /usr/share/fonts/truetype/unfonts-core/UnBatang.ttf /usr/share/fonts/truetype/custom/UnBatang.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-telugu/Lohit-Telugu.ttf "/usr/share/fonts/truetype/custom/Lohit Telugu.ttf" \
    && ln -sf /usr/share/fonts/truetype/Sarai/Sarai.ttf /usr/share/fonts/truetype/custom/Sarai.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-gujarati/Lohit-Gujarati.ttf /usr/share/fonts/truetype/custom/Gujarati.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-punjabi/Lohit-Gurmukhi.ttf "/usr/share/fonts/truetype/custom/Lohit Punjabi.ttf" \
    && ln -sf /usr/share/fonts/truetype/lohit-oriya/Lohit-Odia.ttf "/usr/share/fonts/truetype/custom/Lohit Oriya.ttf" \
    && ln -sf /usr/share/fonts/truetype/malayalam/AnjaliOldLipi-Regular.ttf /usr/share/fonts/truetype/custom/AnjaliOldLipi.ttf \
    && ln -sf /usr/share/fonts/truetype/Gubbi/Gubbi.ttf /usr/share/fonts/truetype/custom/Kedage.ttf \
    && ln -sf /usr/share/fonts/truetype/lohit-tamil/Lohit-Tamil.ttf "/usr/share/fonts/truetype/custom/Lohit Tamil.ttf" \
    && ln -sf /usr/share/fonts/truetype/khmeros/KhmerOS.ttf /usr/share/fonts/truetype/custom/Khmer.ttf \
    && ln -sf /usr/share/fonts/truetype/tlwg/Garuda.ttf "/usr/share/fonts/truetype/custom/Arundina Serif.ttf" \
    && ln -sf /usr/share/fonts/truetype/tlwg/Garuda.ttf /usr/share/fonts/truetype/custom/LikhanNormal.ttf \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf "/usr/share/fonts/truetype/custom/Liberation Sans.ttf" \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf "/usr/share/fonts/truetype/custom/Liberation Serif.ttf" \
    && ln -sf /usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf "/usr/share/fonts/truetype/custom/Liberation Mono.ttf" \
    && fc-cache -f

VOLUME /var/cache/mwlib
EXPOSE 8899

# Start services
CMD ["/bin/bash", "-c", "export PYTHONUNBUFFERED=1 && python -c \"import logging; logging.getLogger().setLevel(logging.INFO)\" && nserve & mw-qserve & nslave --cachedir /var/cache/mwlib"]
