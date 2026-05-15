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
    object-storage/
    nks/
    k8s-platform/
```

Foundation 실행:

```bash
cd ./projects/customer-a/cloud-native/dev
cp ./foundation/terraform.tfvars.example ./foundation/terraform.tfvars
terraform -chdir=foundation init -backend=false
terraform -chdir=foundation validate
terraform -chdir=foundation plan
```

Platform 실행:

```bash
cp ./platform/terraform.tfvars.example ./platform/terraform.tfvars
terraform -chdir=platform init
terraform -chdir=platform validate
terraform -chdir=platform plan
```

