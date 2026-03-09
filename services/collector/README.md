# Collector (Cilium + Hubble)

MVP: use Cilium and Hubble to produce:
- L7/L4 service dependency evidence
- network-level signals (drops/retransmits/latency proxies)

We will export Prometheus metrics and labels by k8s identity:
- namespace
- pod
- service (derived)

Next step: add Helm manifests here.
