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
    # Required for Pillow
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install mwlib and other required libraries
RUN pip install --no-cache-dir mwlib==0.16.2 qserve==0.2.8 mwlib.rl==0.14.5

VOLUME /var/cache/mwlib
EXPOSE 8899

CMD ["/bin/bash", "-c", "nserve & mw-qserve & nslave --cachedir /var/cache/mwlib"]
