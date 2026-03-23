FROM ghost:5.130.6

# Install S3 storage adapter to a staging location (the content dir gets
# overwritten by the PVC mount at runtime, so we copy it in via initContainer)
RUN npm install ghost-storage-adapter-s3 && \
    mkdir -p /tmp/s3-adapter && \
    cp -r ./node_modules/ghost-storage-adapter-s3/* /tmp/s3-adapter/

COPY config.production.json /var/lib/ghost/config.production.json
