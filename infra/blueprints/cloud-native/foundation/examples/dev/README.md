# Cloud-native Foundation Dev Blueprint

이 blueprint는 VPC, subnet, security group, Object Storage, 선택형 DevOps 연동 서버, NKS를 만드는 클라우드 네이티브 foundation 예시다.
Security Group은 기본 outbound 전체 허용 rule을 삭제하고 entrypoint/admin/devops egress만 생성한다.

```bash
cp ./infra/blueprints/cloud-native/foundation/examples/dev/terraform.tfvars.example ./infra/blueprints/cloud-native/foundation/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev init -backend=false
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev validate
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev plan -out=tfplan
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev show -json tfplan > foundation-plan.json
./harness/scripts/policy-check.sh --plan-json ./foundation-plan.json
```

`apply`는 plan 검토와 승인 후 실행한다. GitLab/Gitea/Jenkins를 사용할 경우 Terraform은 VM, volume, security group까지만 만들고 애플리케이션 설치와 credential은 별도 절차로 관리한다. NKS 생성 후 kubeconfig를 발급받아 platform blueprint로 진행한다.
