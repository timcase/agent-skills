# Container Registries

DigitalOcean Container Registry (DOCR). One registry per account;
repositories live inside it.

## Registry management

```bash
doctl registry get                        # show your registry details
doctl registry create <name> \
  --subscription-tier basic               # basic | starter | professional
doctl registry delete --force
```

Subscription tiers: `starter` (free, 1 repo), `basic`, `professional`.

## Authenticate Docker

```bash
doctl registry login                      # docker login to your registry
doctl registry logout
```

Push/pull images after login:
```bash
docker tag myimage registry.digitalocean.com/<registry>/<repo>:<tag>
docker push registry.digitalocean.com/<registry>/<repo>:<tag>
docker pull registry.digitalocean.com/<registry>/<repo>:<tag>
```

## Repositories

```bash
doctl registry repository list-v2        # list all repos in registry
doctl registry repository list-tags  <repo-name>
doctl registry repository list-manifests <repo-name>
```

## Delete images

```bash
# Delete a tag
doctl registry repository delete-tag <repo> <tag> [<tag2>...]

# Delete by digest (use list-manifests to find digest)
doctl registry repository delete-manifest <repo> <digest> [<digest2>...]
```

## Garbage collection

```bash
doctl registry garbage-collection start --include-untagged-manifests
doctl registry garbage-collection get    # status of current GC run
doctl registry garbage-collection list   # history
doctl registry garbage-collection cancel # cancel running GC
```

## Kubernetes integration

```bash
# Generate a K8s secret for pulling from the registry
doctl registry kubernetes-manifest | kubectl apply -f -

# Or output and review first
doctl registry kubernetes-manifest \
  --namespace my-namespace \
  --name my-registry-secret
```

## Docker config (for CI/CD)

```bash
# Generate a Docker auth config JSON (for use in CI)
doctl registry docker-config
doctl registry docker-config --read-write  # include push access
```
