# Cloud Native Dev Example

생성 명령:

```bash
./tools/new-project/create-cloud-native.sh customer-a dev
```

생성 결과:

```text
projects/customer-a/cloud-native/dev/
  README.md
  foundation/
    backend.s3.example.hcl
    main.tf
    outputs.tf
    providers.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
  platform/
    main.tf
    outputs.tf
    providers.tf
    terraform.tfvars.example
    variables.tf
    versions.tf
  modules/
    network/
    security/
    compute/
    block-storage/
    object-storage/
    nks/
    k8s-platform/
  harness/
    scripts/
```

기본 네트워크는 하나의 VPC에 `public`, `private`, `management` routing table을 만들고, `ingress`, `nks-a`, `nks-b`, `devops`, `management` subnet을 각각 매핑한다. Security Group은 기본 outbound 전체 허용 rule을 삭제하고 entrypoint/admin/devops egress만 명시한다.

Foundation 실행:

```bash
cd ./projects/customer-a/cloud-native/dev
cp ./foundation/terraform.tfvars.example ./foundation/terraform.tfvars
terraform -chdir=foundation init -backend=false
terraform -chdir=foundation validate
terraform -chdir=foundation plan -out=tfplan
terraform -chdir=foundation show -json tfplan > foundation-plan.json
./harness/scripts/policy-check.sh --plan-json ./foundation-plan.json
```

Platform 실행:

```bash
cp ./platform/terraform.tfvars.example ./platform/terraform.tfvars
terraform -chdir=platform init
terraform -chdir=platform validate
terraform -chdir=platform plan
```
