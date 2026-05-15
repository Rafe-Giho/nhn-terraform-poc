#!/usr/bin/env bash
set -euo pipefail

terraform_root="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    -TerraformRoot|--terraform-root)
      terraform_root="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--terraform-root <path>]"
      exit 0
      ;;
    *)
      terraform_root="$1"
      shift
      ;;
  esac
done

cd "$terraform_root"

terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate

if command -v tflint >/dev/null 2>&1; then
  tflint --init
  tflint --recursive
fi

if command -v checkov >/dev/null 2>&1; then
  checkov -d .
elif command -v tfsec >/dev/null 2>&1; then
  tfsec .
else
  echo "checkov/tfsec not found. Security scan skipped." >&2
fi
