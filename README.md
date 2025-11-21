# docker-wikiteq-mwlib

Docker image for mwlib (MediaWiki library) with WikiTeq-specific patches and configurations.

## What is mwlib?

[mwlib](https://pypi.org/project/mwlib/) is a Python library designed for parsing MediaWiki articles and converting them into various output formats, such as PDF. It powers Wikipedia's "Print/export" feature, enabling users to generate PDF documents from Wikipedia articles and other MediaWiki-based wikis.

## Overview

This Docker image provides a containerized environment for running mwlib services, including:
- **nserve**: MediaWiki rendering server
- **mw-qserve**: Queue server for rendering tasks
- **nslave**: Worker process for rendering operations

The image is based on Python 2.7.18 and includes various patches and fixes for compatibility with modern dependencies.

## Features

- Python 2.7.18 runtime environment
- mwlib 0.16.2 with related packages (qserve, mwlib.rl, pyfribidi, Pillow)
- Support for large request bodies via configurable `BOTTLE_MEMFILE_MAX`
- Pillow/ReportLab compatibility fixes
- Extended PNG decompression limits
- Multi-language font support (Arabic, Chinese, Thai, Hindi, and many others)

## Building the Image

```bash
docker build -t docker-wikiteq-mwlib .
```

## Running the Container

### Basic Usage

```bash
docker run -d \
  -p 8899:8899 \
  -v mwlib-cache:/var/cache/mwlib \
  docker-wikiteq-mwlib
```

### Configuration

The container supports the following environment variables:

- `BOTTLE_MEMFILE_MAX`: Maximum size for request bodies (default: `10M`)
  - Can be specified in bytes (e.g., `10485760`)
  - Or with suffix: `K`, `M`, `G`, `KB`, `MB`, `GB` (e.g., `50MB`, `1G`)

Example with custom memory limit:

```bash
docker run -d \
  -p 8899:8899 \
  -e BOTTLE_MEMFILE_MAX=50MB \
  -v mwlib-cache:/var/cache/mwlib \
  docker-wikiteq-mwlib
```

### Volumes

- `/var/cache/mwlib`: Cache directory for rendered content (recommended to mount as a volume)

## Ports

- `8899`: Main service port for mwlib services

## Included Patches

1. **nserve.py patch**: Adds support for configurable `BOTTLE_MEMFILE_MAX` via environment variable
2. **Pillow/ReportLab compatibility**: Fixes `.tostring()` to `.tobytes()` for Python 3 compatibility
3. **PNG decompression limits**: Increases limits for handling large PNG files

## Font Support

The image includes fonts for multiple languages:
- Arabic (FarsiWeb)
- Chinese (AR PL UMing)
- Thai (TLWG Garuda)
- Hindi and other Indic languages (Lohit fonts)
- Khmer (KhmerOS)
- Latin (Liberation fonts)
- And many more
