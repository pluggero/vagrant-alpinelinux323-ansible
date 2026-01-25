#!/bin/sh
# Cleanup script to finalize the image
set -euo pipefail

# Remove apk cache and lists
rm -rf /var/cache/apk/*

# Remove documentation to reduce image size
rm -Rf /usr/share/doc
rm -Rf /usr/share/man
