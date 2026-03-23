FROM ghost:5.130.6

# Install S3 storage adapter into Ghost's versioned adapter path
# Ghost looks in versions/X.Y.Z/core/server/adapters/storage/ for adapters
RUN npm install ghost-storage-adapter-s3 && \
    mkdir -p /var/lib/ghost/versions/5.130.6/core/server/adapters/storage/s3 && \
    cp -r ./node_modules/ghost-storage-adapter-s3/* /var/lib/ghost/versions/5.130.6/core/server/adapters/storage/s3/

COPY config.production.json /var/lib/ghost/config.production.json
