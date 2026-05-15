# Cloud-native Foundation Dev Blueprint

이 blueprint는 VPC, subnet, security group, Object Storage, NKS를 만드는 클라우드 네이티브 foundation 예시다.

```bash
cp ./infra/blueprints/cloud-native/foundation/examples/dev/terraform.tfvars.example ./infra/blueprints/cloud-native/foundation/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev init -backend=false
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev validate
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev plan
```

`apply`는 plan 검토와 승인 후 실행한다. NKS 생성 후 kubeconfig를 발급받아 platform blueprint로 진행한다.
