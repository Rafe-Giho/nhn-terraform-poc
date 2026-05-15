# IaaS 3-tier Dev Example

생성 명령:

```bash
./tools/new-project/create-iaas-3tier.sh customer-a dev
```

생성 결과:

```text
projects/customer-a/iaas-3tier/dev/
  README.md
  terraform/
    backend.s3.example.hcl
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
    load-balancer/
    object-storage/
  harness/
    scripts/
```

기본 네트워크는 하나의 VPC에 `public`, `private`, `management` routing table을 만들고, `dmz`, `web`, `app`, `data`, `management`, `operations` subnet을 각각 매핑한다. Security Group은 기본 outbound 전체 허용 rule을 삭제하고 계층별 egress만 명시한다.

실행:

```bash
cd ./projects/customer-a/iaas-3tier/dev
cp ./terraform/terraform.tfvars.example ./terraform/terraform.tfvars
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform show -json tfplan > plan.json
./harness/scripts/policy-check.sh --plan-json ./plan.json
```
