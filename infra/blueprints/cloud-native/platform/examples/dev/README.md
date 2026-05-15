# Cloud-native Platform Dev Blueprint

이 blueprint는 NKS 내부 namespace, StorageClass, cert-manager, Argo CD를 구성하는 platform 예시다.

```bash
cp ./infra/blueprints/cloud-native/platform/examples/dev/terraform.tfvars.example ./infra/blueprints/cloud-native/platform/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev init
terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev validate
terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev plan
```

`apply`는 plan 검토와 승인 후 실행한다. Kubernetes Secret, runner token, registry password는 Terraform state에 남기지 않는다.
