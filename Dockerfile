FROM ghost:6.73.0

# Ghost 6 ships a built-in S3 storage adapter (S3Storage, AWS SDK v3), configured
# by storage__S3Storage__* env vars in k8s/deployment.yml. The community
# ghost-storage-adapter-s3 (AWS SDK v2) that 5.x needed fails Ghost 6's boot-time
# adapter validation, so it is no longer installed.
COPY config.production.json /var/lib/ghost/config.production.json
