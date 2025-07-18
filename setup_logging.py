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

print("Logging configured for mwlib components", file=sys.stderr)
