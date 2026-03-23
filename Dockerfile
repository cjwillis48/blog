FROM ghost:5.130.6

RUN npm install ghost-storage-adapter-s3 && \
    mkdir -p ./content/adapters/storage/s3 && \
    cp -r ./node_modules/ghost-storage-adapter-s3/* ./content/adapters/storage/s3/

COPY config.production.json /var/lib/ghost/config.production.json
