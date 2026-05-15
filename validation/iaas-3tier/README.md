# IaaS 3-tier Validation Workspace

이 디렉터리는 팀원이 main 브랜치의 IaaS 3-tier 표준 blueprint를 받아 실제 NHN Cloud 계정에서 검증하는 상황을 재현하기 위한 독립 작업 공간이다.

구성:

```text
validation/iaas-3tier/
  terraform/          # 실제 실행 루트
  modules/            # IaaS 검증에 필요한 모듈 복제본
```

진행 순서:

```bash
cp ./validation/iaas-3tier/terraform/terraform.tfvars.example ./validation/iaas-3tier/terraform/terraform.tfvars
```

`terraform.tfvars`에 실제 NHN Cloud 값 입력:

- `nhncloud_user_name`
- `nhncloud_tenant_id`
- `nhncloud_password`
- `nhncloud_auth_url`
- `nhncloud_region`
- `availability_zone`
- `keypair_name`
- `image_id`
- `flavor_ids`
- `external_network_id`
- `internet_gateway_id`

검증:

```bash
terraform -chdir=validation/iaas-3tier/terraform init -backend=false
terraform -chdir=validation/iaas-3tier/terraform validate
terraform -chdir=validation/iaas-3tier/terraform plan
```

`apply`는 plan에서 생성 대상, public ingress, Floating IP, LB, volume, destroy/replace 여부를 검토한 뒤 승인 후 실행한다.

