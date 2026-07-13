#!/usr/bin/env bash
# Applies the app's Deployment/Service and VSO custom resources — everything
# that changes on every release. Cluster-level guardrails (namespace,
# ServiceAccount, VSO install, RBAC) are Terraform-managed (terraform/k8s/)
# and aren't touched here.
#
# Called by the CI deploy job (ci-cd/.github/workflows/build-push.yml), which
# exports these directly; for local/manual runs, `source config/demo.env` and
# export IMAGE yourself first. Uses sed (not envsubst, which isn't installed
# by default on macOS) for substitution.
#
# Expects: VAULT_ADDR, VAULT_NAMESPACE, K8S_NAMESPACE, K8S_SERVICE_ACCOUNT, IMAGE
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

subst() {
  sed -e "s|\${VAULT_ADDR}|${VAULT_ADDR}|g" \
      -e "s|\${VAULT_NAMESPACE}|${VAULT_NAMESPACE}|g" \
      -e "s|\${K8S_SERVICE_ACCOUNT}|${K8S_SERVICE_ACCOUNT}|g" \
      -e "s|\${IMAGE}|${IMAGE}|g" \
      "$1"
}

for f in manifests/vso/vault-connection.yaml manifests/vso/vault-auth.yaml manifests/vso/vault-static-secret.yaml; do
  subst "$f" | kubectl apply -n "$K8S_NAMESPACE" -f -
done

subst manifests/deployment.yaml | kubectl apply -n "$K8S_NAMESPACE" -f -
kubectl apply -n "$K8S_NAMESPACE" -f manifests/service.yaml

echo "applied — check with: kubectl -n $K8S_NAMESPACE get pods,secrets"
