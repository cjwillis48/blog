# Blog

Ghost blog running on Kubernetes (arm64). Media stored in Cloudflare R2, backed up via CronJob.

## Architecture

- Ghost 6.x image; media goes to R2 via Ghost's built-in S3Storage adapter (configured by env vars, nothing baked in)
- Deployed to `blog` namespace on a `storage-tier: large` node
- Recreate strategy (single replica, SQLite on PVC — no rolling updates)
- Secrets are Bitnami SealedSecrets committed to `k8s/`

## Deployment

- Push to `main` triggers CI to build and push to `ghcr.io/cjwillis48/blog`
- CI only fires on changes to Dockerfile, config.production.json, or entrypoint.sh
- K8s manifests are applied via Kustomize: `kubectl apply -k k8s/`
- Image is pinned to the CI short-sha tag in deployment.yml (rollback = git revert). Push the Dockerfile first, wait for CI, then bump the tag: Argo would otherwise roll out a deployment pointing at an image that does not exist yet

## Gotchas

- Storage config lives in `storage__S3Storage__*` env vars and `storage__active=S3Storage`, not in config.production.json. Ghost 6 validates adapters at boot and refuses to start on a bad config
- SQLite is officially dev-only in Ghost 6 but works in production (verified on 6.73.0, 2026-10-28). Re-check this before each major upgrade
- Before a Ghost major: copy `content/data/ghost.db` aside on the PVC and locally. Migrations are not reversible by downgrading the image
- Builds are arm64-only — won't run on amd64 nodes