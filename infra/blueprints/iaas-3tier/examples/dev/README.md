# IaaS 3-tier Dev Blueprint

이 blueprint는 Web/WAS/DB VM, 운영 서버, public/internal LB, block storage, Object Storage를 만드는 IaaS 3-tier 예시다.
Security Group은 기본 outbound 전체 허용 rule을 삭제하고 계층별 egress만 생성한다.

```bash
cp ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars.example ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/iaas-3tier/examples/dev init -backend=false
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev validate
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev plan -out=tfplan
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev show -json tfplan > plan.json
./harness/scripts/policy-check.sh --plan-json ./plan.json
```

`apply`는 plan 검토와 승인 후 실행한다.
