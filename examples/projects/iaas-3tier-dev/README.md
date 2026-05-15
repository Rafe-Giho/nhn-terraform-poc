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
```

실행:

```bash
cd ./projects/customer-a/iaas-3tier/dev
cp ./terraform/terraform.tfvars.example ./terraform/terraform.tfvars
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

