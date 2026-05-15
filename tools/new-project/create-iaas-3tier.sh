#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./tools/new-project/create-iaas-3tier.sh <project-name> <env> [target-dir]

Examples:
  ./tools/new-project/create-iaas-3tier.sh customer-a dev
  ./tools/new-project/create-iaas-3tier.sh customer-a prod ../customer-a-infra/iaas-3tier/prod
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 1
fi

PROJECT_NAME="$1"
ENV_NAME="$2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_DIR="${3:-$REPO_ROOT/projects/$PROJECT_NAME/iaas-3tier/$ENV_NAME}"

BLUEPRINT_DIR="$REPO_ROOT/infra/blueprints/iaas-3tier/examples/dev"
MODULES_DIR="$REPO_ROOT/infra/modules"

if [[ -e "$TARGET_DIR" ]]; then
  echo "Target already exists: $TARGET_DIR" >&2
  echo "Choose another target directory or move the existing one first." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR/terraform" "$TARGET_DIR/modules"

cp "$BLUEPRINT_DIR"/backend.s3.example.hcl "$TARGET_DIR/terraform/"
cp "$BLUEPRINT_DIR"/main.tf "$TARGET_DIR/terraform/"
cp "$BLUEPRINT_DIR"/outputs.tf "$TARGET_DIR/terraform/"
cp "$BLUEPRINT_DIR"/providers.tf "$TARGET_DIR/terraform/"
cp "$BLUEPRINT_DIR"/terraform.tfvars.example "$TARGET_DIR/terraform/"
cp "$BLUEPRINT_DIR"/variables.tf "$TARGET_DIR/terraform/"
cp "$BLUEPRINT_DIR"/versions.tf "$TARGET_DIR/terraform/"

for module in network security compute block-storage load-balancer object-storage; do
  cp -R "$MODULES_DIR/$module" "$TARGET_DIR/modules/"
done

sed -i 's#../../../../modules/#../modules/#g' "$TARGET_DIR/terraform/main.tf"

cat > "$TARGET_DIR/README.md" <<EOF
# $PROJECT_NAME IaaS 3-tier $ENV_NAME

이 디렉터리는 NHN Cloud IaaS 3-tier 표준 blueprint에서 생성한 실행 workspace다.

## 실행 순서

\`\`\`bash
cp ./terraform/terraform.tfvars.example ./terraform/terraform.tfvars
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform show -json tfplan > plan.json
\`\`\`

\`terraform.tfvars\`, \`tfplan\`, \`plan.json\`, state 파일은 커밋하지 않는다.

EOF

echo "Created IaaS 3-tier workspace: $TARGET_DIR"

