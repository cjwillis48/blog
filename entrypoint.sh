#!/bin/bash
set -e

# Copy the S3 storage adapter into the PVC-mounted content directory
mkdir -p /var/lib/ghost/content/adapters/storage/s3
cp -r /tmp/s3-adapter/* /var/lib/ghost/content/adapters/storage/s3/

# Hand off to Ghost's original entrypoint
exec docker-entrypoint.sh "$@"
