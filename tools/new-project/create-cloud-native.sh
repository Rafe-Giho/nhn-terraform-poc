#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./tools/new-project/create-cloud-native.sh <project-name> <env> [target-dir]

Examples:
  ./tools/new-project/create-cloud-native.sh customer-a dev
  ./tools/new-project/create-cloud-native.sh customer-a prod ../customer-a-infra/cloud-native/prod
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
TARGET_DIR="${3:-$REPO_ROOT/projects/$PROJECT_NAME/cloud-native/$ENV_NAME}"

FOUNDATION_BLUEPRINT="$REPO_ROOT/infra/blueprints/cloud-native/foundation/examples/dev"
PLATFORM_BLUEPRINT="$REPO_ROOT/infra/blueprints/cloud-native/platform/examples/dev"
MODULES_DIR="$REPO_ROOT/infra/modules"

if [[ -e "$TARGET_DIR" ]]; then
  echo "Target already exists: $TARGET_DIR" >&2
  echo "Choose another target directory or move the existing one first." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR/foundation" "$TARGET_DIR/platform" "$TARGET_DIR/modules"

cp "$FOUNDATION_BLUEPRINT"/backend.s3.example.hcl "$TARGET_DIR/foundation/"
cp "$FOUNDATION_BLUEPRINT"/main.tf "$TARGET_DIR/foundation/"
cp "$FOUNDATION_BLUEPRINT"/outputs.tf "$TARGET_DIR/foundation/"
cp "$FOUNDATION_BLUEPRINT"/providers.tf "$TARGET_DIR/foundation/"
cp "$FOUNDATION_BLUEPRINT"/terraform.tfvars.example "$TARGET_DIR/foundation/"
cp "$FOUNDATION_BLUEPRINT"/variables.tf "$TARGET_DIR/foundation/"
cp "$FOUNDATION_BLUEPRINT"/versions.tf "$TARGET_DIR/foundation/"

cp "$PLATFORM_BLUEPRINT"/main.tf "$TARGET_DIR/platform/"
cp "$PLATFORM_BLUEPRINT"/outputs.tf "$TARGET_DIR/platform/"
cp "$PLATFORM_BLUEPRINT"/providers.tf "$TARGET_DIR/platform/"
cp "$PLATFORM_BLUEPRINT"/terraform.tfvars.example "$TARGET_DIR/platform/"
cp "$PLATFORM_BLUEPRINT"/variables.tf "$TARGET_DIR/platform/"
cp "$PLATFORM_BLUEPRINT"/versions.tf "$TARGET_DIR/platform/"

for module in network security object-storage nks k8s-platform; do
  cp -R "$MODULES_DIR/$module" "$TARGET_DIR/modules/"
done

sed -i 's#../../../../../modules/#../modules/#g' "$TARGET_DIR/foundation/main.tf"
sed -i 's#../../../../../modules/#../modules/#g' "$TARGET_DIR/platform/main.tf"

cat > "$TARGET_DIR/README.md" <<EOF
# $PROJECT_NAME Cloud Native $ENV_NAME

이 디렉터리는 NHN Cloud NKS 기반 클라우드 네이티브 표준 blueprint에서 생성한 실행 workspace다.

## Foundation 실행

\`\`\`bash
cp ./foundation/terraform.tfvars.example ./foundation/terraform.tfvars
terraform -chdir=foundation init -backend=false
terraform -chdir=foundation fmt -recursive
terraform -chdir=foundation validate
terraform -chdir=foundation plan -out=tfplan
terraform -chdir=foundation show -json tfplan > foundation-plan.json
\`\`\`

## Platform 실행

NKS 생성 후 kubeconfig를 발급받고 \`platform/terraform.tfvars\`에 경로와 context를 입력한다.

\`\`\`bash
cp ./platform/terraform.tfvars.example ./platform/terraform.tfvars
terraform -chdir=platform init
terraform -chdir=platform fmt -recursive
terraform -chdir=platform validate
terraform -chdir=platform plan -out=tfplan
terraform -chdir=platform show -json tfplan > platform-plan.json
\`\`\`

\`terraform.tfvars\`, \`tfplan\`, \`*-plan.json\`, state 파일은 커밋하지 않는다.

EOF

echo "Created cloud native workspace: $TARGET_DIR"

