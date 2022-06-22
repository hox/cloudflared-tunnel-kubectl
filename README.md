# cloudflared-tunnel-kubectl
Github action for using Kubectl with Cloudflared Tunnel

# Example configuration:
```yaml
name: CI

on:
  push:
    branches:
      - main

jobs:
  info:
    runs-on: ubuntu-latest
    steps:
      - uses: raptorhq/cloudflare-tunnel-kubectl@v1
        name: Cluster info
        env: 
          cloudflared_service_token_id: ${{ secrets.CLOUDFLARE_SERVICE_TOKEN_ID }}
          cloudflared_service_token_secret: ${{ secrets.CLOUDFLARE_SERVICE_TOKEN_SECRET }}
          cloudflared_host_address: "kubernetes.acme.local"
          kubeconfig: ${{ secrets.KUBECONFIG }}
          kubectl_args: "cluster-info"
```
