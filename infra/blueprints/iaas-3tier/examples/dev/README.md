# IaaS 3-tier Dev Blueprint

이 blueprint는 Web/WAS/DB VM, 운영 서버, public/internal LB, block storage, Object Storage를 만드는 IaaS 3-tier 예시다.

```bash
cp ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars.example ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/iaas-3tier/examples/dev init -backend=false
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev validate
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev plan
```

`apply`는 plan 검토와 승인 후 실행한다.
