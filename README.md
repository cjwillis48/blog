# blog

Ghost blog infrastructure for [blog.charliewillis.com](https://blog.charliewillis.com).

Custom Docker image extending Ghost with the `ghost-storage-adapter-s3` to store media assets in Cloudflare R2, served via CDN at `media.blog.charliewillis.com`.

## Architecture

- **Image**: Built from `Dockerfile`, pushed to `ghcr.io/cjwillis48/blog` (ARM64)
- **K8s**: Deployed on a Raspberry Pi K3s cluster via ArgoCD (manifests in `k8s/`)
- **Storage**: New uploads go to R2 (`blog-media` bucket), existing content on PVC
- **Database**: SQLite at `/var/lib/ghost/content/data/ghost.db`
- **Backups**: Daily CronJob syncs Ghost content directory to R2 (`ghost-backups` bucket)

## Setup

1. Create the `blog-media` R2 bucket in Cloudflare
2. Generate an R2 API token with Object Read & Write on `blog-media`
3. Fill in `k8s/storage-r2-secret.yml.tmpl` and seal it:
   ```bash
   kubeseal --format yaml \
     --cert <path-to-sealed-secrets-pub.pem> \
     < k8s/storage-r2-secret.yml.tmpl \
     > k8s/storage-r2-secret.sealed.yml
   ```
4. Commit and push — the GitHub Action builds the image, ArgoCD deploys

## Part 2: Asset Migration (TODO)

Once the R2 storage adapter is verified working for new uploads:

1. **Backup the database**: `kubectl exec` to copy the SQLite DB off the pod
2. **Sync existing images to R2**:
   ```bash
   rclone sync /var/lib/ghost/content/images r2:blog-media/images
   ```
3. **Rewrite URLs in the database** (SQLite):
   ```sql
   UPDATE posts
   SET html = REPLACE(html, 'https://blog.charliewillis.com/content/images/', 'https://media.blog.charliewillis.com/content/images/'),
       mobiledoc = REPLACE(mobiledoc, 'https://blog.charliewillis.com/content/images/', 'https://media.blog.charliewillis.com/content/images/'),
       lexical = REPLACE(lexical, 'https://blog.charliewillis.com/content/images/', 'https://media.blog.charliewillis.com/content/images/')
   WHERE html LIKE '%blog.charliewillis.com/content/images/%'
      OR mobiledoc LIKE '%blog.charliewillis.com/content/images/%'
      OR lexical LIKE '%blog.charliewillis.com/content/images/%';
   ```
4. **Verify** all posts render images from the CDN domain
