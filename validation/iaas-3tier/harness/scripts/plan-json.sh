#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../.." && pwd)"

terraform_root="."
out_dir="$repo_root/harness/out"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -TerraformRoot|--terraform-root)
      terraform_root="$2"
      shift 2
      ;;
    -OutDir|--out-dir)
      out_dir="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--terraform-root <path>] [--out-dir <path>]"
      exit 0
      ;;
    *)
      terraform_root="$1"
      shift
      ;;
  esac
done

mkdir -p "$out_dir"

cd "$terraform_root"

terraform init -input=false
terraform plan -out="$out_dir/tfplan"
terraform show -json "$out_dir/tfplan" > "$out_dir/tfplan.json"

echo "Wrote $out_dir/tfplan and $out_dir/tfplan.json"
