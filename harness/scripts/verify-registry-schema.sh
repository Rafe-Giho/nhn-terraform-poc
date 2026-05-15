#!/usr/bin/env bash
set -euo pipefail

provider_version="1.0.8"
work_dir="harness/out/registry-schema-check"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -ProviderVersion|--provider-version)
      provider_version="$2"
      shift 2
      ;;
    -WorkDir|--work-dir)
      work_dir="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--provider-version <version>] [--work-dir <path>]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

mkdir -p "$work_dir"
resolved_work_dir="$(cd "$work_dir" && pwd -P)"

cat > "$resolved_work_dir/providers.tf" <<EOF
terraform {
  required_providers {
    nhncloud = {
      source  = "nhn-cloud/nhncloud"
      version = "= $provider_version"
    }
  }
}
EOF

terraform -chdir="$resolved_work_dir" init -backend=false -input=false
terraform -chdir="$resolved_work_dir" providers schema -json > "$resolved_work_dir/schema.json"

python3 - "$resolved_work_dir/schema.json" "$provider_version" <<'PY'
import json
import sys

schema_path = sys.argv[1]
provider_version = sys.argv[2]
provider_key = "registry.terraform.io/nhn-cloud/nhncloud"

with open(schema_path, "r", encoding="utf-8") as f:
    schema = json.load(f)

provider_schema = schema.get("provider_schemas", {}).get(provider_key)
if not provider_schema:
    raise SystemExit(f"Provider schema not found for {provider_key}")

resources = provider_schema.get("resource_schemas", {})
data_sources = provider_schema.get("data_source_schemas", {})

print(f"provider={provider_key}")
print(f"version={provider_version}")
print(f"resource_schemas={len(resources)}")
print(f"data_source_schemas={len(data_sources)}")
print(f"schema_path={schema_path}")
PY
