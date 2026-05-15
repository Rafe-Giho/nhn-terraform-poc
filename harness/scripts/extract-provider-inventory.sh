#!/usr/bin/env bash
set -euo pipefail

provider_source=".provider-src"
output_path="harness/out/nhncloud-provider-inventory.md"
source_ref=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -ProviderSource|--provider-source)
      provider_source="$2"
      shift 2
      ;;
    -OutputPath|--output-path)
      output_path="$2"
      shift 2
      ;;
    -SourceRef|--source-ref)
      source_ref="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--provider-source <path>] [--output-path <path>] [--source-ref <ref>]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

python3 - "$provider_source" "$output_path" "$source_ref" <<'PY'
from pathlib import Path
import re
import sys

provider_source = Path(sys.argv[1])
output_path = Path(sys.argv[2])
source_ref = sys.argv[3]

provider_file = provider_source / "nhncloud" / "provider.go"
resource_docs = provider_source / "docs" / "resources"
data_docs = provider_source / "docs" / "data-sources"

if not provider_file.exists():
    raise SystemExit(f"provider.go not found: {provider_file}")

def doc_names(path):
    if not path.exists():
        return set()
    names = {item.stem for item in path.glob("*.md")}
    if "nhncloud_networking_secgroup_rule" in names:
        names.add("nhncloud_networking_secgroup_rule_v2")
    return names

doc_resources = doc_names(resource_docs)
doc_data_sources = doc_names(data_docs)

text = provider_file.read_text(encoding="utf-8")
resources = re.findall(r'"(nhncloud_[^"]+)":\s+resource', text)
data_sources = re.findall(r'"(nhncloud_[^"]+)":\s+dataSource', text)

def area(name):
    match = re.match(r"^nhncloud_([^_]+)", name)
    return match.group(1) if match else "unknown"

lines = [
    "# NHN Cloud Provider Inventory",
    "",
]

source = str(provider_file).replace("\\", "/")
if source_ref:
    lines.append(f"Generated from `{source}` at `{source_ref}`.")
else:
    lines.append(f"Generated from `{source}`.")

lines.extend([
    "",
    "이 문서는 provider의 `ResourcesMap`과 `DataSourcesMap`에 등록된 전체 목록이다. Resource type이 등록되어 있다는 뜻이지, NHN Cloud 운영 환경에서 모두 동일하게 권장된다는 뜻은 아니다.",
    "",
    "구분:",
    "",
    "- `provider docs`: provider 저장소의 `docs/resources` 또는 `docs/data-sources`에 문서 파일이 있는 항목",
    "- `provider code`: provider 코드에는 등록되어 있으나 docs 파일이 없는 항목",
    "- 운영 우선순위는 scope 문서의 A/B/C 등급을 따른다.",
    "",
    "요약:",
    "",
    f"- Resources: {len(resources)}개",
    f"- Data sources: {len(data_sources)}개",
    "",
    "## Resources",
    "",
    "| Area | Resource | Source |",
    "|---|---|---|",
])

for resource in resources:
    source_type = "provider docs" if resource in doc_resources else "provider code"
    lines.append(f"| {area(resource)} | `{resource}` | {source_type} |")

lines.extend([
    "",
    "## Data Sources",
    "",
    "| Area | Data source | Source |",
    "|---|---|---|",
])

for data_source in data_sources:
    source_type = "provider docs" if data_source in doc_data_sources else "provider code"
    lines.append(f"| {area(data_source)} | `{data_source}` | {source_type} |")

output_path.parent.mkdir(parents=True, exist_ok=True)
output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Wrote {output_path}")
PY
