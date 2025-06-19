## How to apply changes to files in this directory
For example, change the image tag or replica count in: k8s/overlays/my-vote-api/staging/values.yaml

### 1. Re-render rendered.yaml for the target overlay
Use the helm template command:

helm template my-vote-api ./charts/my-vote-api \
  -f k8s/overlays/my-vote-api/staging/values.yaml \
  > k8s/overlays/my-vote-api/staging/rendered.yaml

Repeat for dev/ or prod/ as needed by changing the path.

### 2. Stage and commit your changes

git add k8s/overlays/my-vote-api/staging/{values.yaml,rendered.yaml}
git commit -m "fix: update image tag and re-render manifest for staging"
git push origin main