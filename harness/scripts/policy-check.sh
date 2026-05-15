#!/usr/bin/env bash
set -euo pipefail

plan_json=""
allow_open_egress="false"
allow_delete="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan-json|-PlanJson)
      plan_json="$2"
      shift 2
      ;;
    --allow-open-egress)
      allow_open_egress="true"
      shift
      ;;
    --allow-delete)
      allow_delete="true"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 --plan-json <tfplan.json> [--allow-open-egress] [--allow-delete]"
      exit 0
      ;;
    *)
      plan_json="$1"
      shift
      ;;
  esac
done

if [[ -z "$plan_json" ]]; then
  echo "plan JSON path is required. Use --plan-json <tfplan.json>." >&2
  exit 2
fi

python_cmd=()
if [[ -n "${PYTHON:-}" ]]; then
  python_cmd=("$PYTHON")
elif command -v python3 >/dev/null 2>&1; then
  python_cmd=("python3")
elif command -v python >/dev/null 2>&1; then
  python_cmd=("python")
elif command -v py >/dev/null 2>&1; then
  python_cmd=("py" "-3")
else
  echo "python3 or python is required for policy-check.sh." >&2
  exit 2
fi

"${python_cmd[@]}" - "$plan_json" "$allow_open_egress" "$allow_delete" <<'PY'
import json
import sys

path = sys.argv[1]
allow_open_egress = sys.argv[2] == "true"
allow_delete = sys.argv[3] == "true"

with open(path, "r", encoding="utf-8") as f:
    plan = json.load(f)

failures = []
warnings = []

public_cidrs = {"0.0.0.0/0", "::/0"}
public_service_ports = {80, 443}
admin_ports = {22, 3389}
high_risk_delete_types = {
    "nhncloud_networking_vpc_v2",
    "nhncloud_networking_vpcsubnet_v2",
    "nhncloud_networking_routingtable_v2",
    "nhncloud_kubernetes_cluster_v1",
    "nhncloud_kubernetes_nodegroup_v1",
    "nhncloud_objectstorage_container_v1",
    "nhncloud_blockstorage_volume_v2",
    "nhncloud_compute_instance_v2",
}

def actions(change):
    return change.get("actions") or []

def port_range(after):
    return after.get("port_range_min"), after.get("port_range_max")

def is_public(remote):
    return remote in public_cidrs

for rc in plan.get("resource_changes", []):
    change = rc.get("change", {})
    acts = actions(change)
    if acts == ["no-op"]:
        continue

    address = rc.get("address", "<unknown>")
    rtype = rc.get("type", "")
    after = change.get("after") or {}

    if "delete" in acts:
        if rtype in high_risk_delete_types and not allow_delete:
            failures.append(f"{address}: high-risk delete/replace action {acts}")
        elif not allow_delete:
            warnings.append(f"{address}: delete action present {acts}")

    if rtype == "nhncloud_networking_secgroup_rule_v2":
        direction = after.get("direction")
        protocol = (after.get("protocol") or "").lower()
        remote = after.get("remote_ip_prefix")
        port_min, port_max = port_range(after)

        if direction == "ingress" and is_public(remote):
            if port_min in admin_ports or port_max in admin_ports:
                failures.append(f"{address}: public ingress to admin port {port_min}-{port_max}")
            if protocol != "tcp" or port_min != port_max or port_min not in public_service_ports:
                failures.append(f"{address}: public ingress is only allowed for TCP 80/443")

        if direction == "egress" and is_public(remote):
            whole_protocol = protocol in {"", "any", "all"}
            whole_port = port_min is None and port_max is None
            if whole_protocol and whole_port and not allow_open_egress:
                failures.append(f"{address}: open egress to {remote} requires explicit approval")

    if rtype == "nhncloud_networking_routingtable_attach_gateway_v2":
        if "\"public\"" not in address and ".public" not in address and "[public]" not in address:
            failures.append(f"{address}: gateway attachment is only allowed for public routing table")

    if rtype == "nhncloud_networking_floatingip_v2" and any(a in acts for a in ["create", "update"]):
        warnings.append(f"{address}: Floating IP change requires public LB/bastion approval check")

    if rtype == "nhncloud_kubernetes_cluster_v1" and "delete" in acts and "create" in acts:
        failures.append(f"{address}: NKS cluster replacement requires separate migration approval")

if failures:
    print("Policy check failed:")
    for item in failures:
        print(f"  - {item}")
else:
    print("Policy check passed.")

if warnings:
    print("Warnings:")
    for item in warnings:
        print(f"  - {item}")

sys.exit(1 if failures else 0)
PY
