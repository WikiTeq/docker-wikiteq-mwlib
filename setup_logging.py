#!/usr/bin/env python
import logging
import sys

# Configure basic logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(name)s: %(message)s',
    stream=sys.stderr
)

# Set specific loggers to INFO level
logging.getLogger('mwlib').setLevel(logging.INFO)
logging.getLogger('mwlib.core.nslave').setLevel(logging.INFO)
logging.getLogger('qs').setLevel(logging.INFO)

# Python 2 compatible print to stderr
sys.stderr.write("Logging configured for mwlib components\n")
sys.stderr.flush()
