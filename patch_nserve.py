#!/usr/bin/env python
"""Patch nserve.py to add BOTTLE_MEMFILE_MAX environment variable support"""
import re
import sys

nserve_file = '/usr/local/lib/python2.7/site-packages/mwlib/nserve.py'

with open(nserve_file, 'r') as f:
    content = f.read()

# Replace the bottle import line to include BaseRequest and error
content = re.sub(
    r'from bottle import request, default_app, post, get, HTTPResponse',
    'from bottle import request, default_app, post, get, HTTPResponse, error, BaseRequest\nimport os',
    content
)

# Configuration code to insert
config_code = '''

# Configure Bottle's MEMFILE_MAX from environment variable
# Default is 100KB (102400 bytes), but can be overridden via BOTTLE_MEMFILE_MAX env var
# Value can be in bytes (e.g., 10485760) or with suffix (e.g., 10M, 50MB)
memfile_max_str = os.getenv('BOTTLE_MEMFILE_MAX', '10M')
try:
    # Handle suffixes: K, M, G for KB, MB, GB
    memfile_max_str = memfile_max_str.strip().upper()
    if memfile_max_str.endswith('K'):
        BaseRequest.MEMFILE_MAX = int(memfile_max_str[:-1]) * 1024
    elif memfile_max_str.endswith('M'):
        BaseRequest.MEMFILE_MAX = int(memfile_max_str[:-1]) * 1024 * 1024
    elif memfile_max_str.endswith('G'):
        BaseRequest.MEMFILE_MAX = int(memfile_max_str[:-1]) * 1024 * 1024 * 1024
    elif memfile_max_str.endswith('KB'):
        BaseRequest.MEMFILE_MAX = int(memfile_max_str[:-2]) * 1024
    elif memfile_max_str.endswith('MB'):
        BaseRequest.MEMFILE_MAX = int(memfile_max_str[:-2]) * 1024 * 1024
    elif memfile_max_str.endswith('GB'):
        BaseRequest.MEMFILE_MAX = int(memfile_max_str[:-2]) * 1024 * 1024 * 1024
    else:
        # Assume bytes if no suffix
        BaseRequest.MEMFILE_MAX = int(memfile_max_str)
except (ValueError, AttributeError):
    # Fallback to 10MB if parsing fails
    BaseRequest.MEMFILE_MAX = 10 * 1024 * 1024
    log.warning("Invalid BOTTLE_MEMFILE_MAX value '%s', using default 10MB" % memfile_max_str)

log.info("Bottle MEMFILE_MAX set to %d bytes (%d MB)" % (BaseRequest.MEMFILE_MAX, BaseRequest.MEMFILE_MAX / (1024 * 1024)))

'''

# Find the import line and insert config code after it
pattern = r'(from bottle import request, default_app, post, get, HTTPResponse, error, BaseRequest\nimport os)'
replacement = r'\1' + config_code
content = re.sub(pattern, replacement, content, count=1)

with open(nserve_file, 'w') as f:
    f.write(content)

print("Successfully patched nserve.py")

