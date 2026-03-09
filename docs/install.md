# Install (out of box)

Goal: one-command install into a fresh Kubernetes cluster.

## Prereqs
- kubectl
- helm v3

## Install

```bash
helm repo add cilium https://helm.cilium.io/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install photon ./charts/photon -n photon --create-namespace
```

## Verify

```bash
kubectl -n photon get pods
kubectl -n photon port-forward svc/photon-api 8080:8080
curl http://127.0.0.1:8080/healthz
```

## Notes
- This chart enables Cilium + Hubble and Prometheus.
- API image defaults to `ghcr.io/mingleiw/photon-api:latest` (published automatically by GitHub Actions on pushes to main).
  For local dev (kind/minikube), build and override `api.image.repository/tag`.
