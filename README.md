# NHN Cloud Terraform PoC

NHN Cloud에서 Terraform으로 생성/관리할 수 있는 리소스 범위를 분석하고, NKS 중심 표준 아키텍처와 Terraform 프로젝트 골격을 정리한 저장소입니다.

기준 provider:

- `nhn-cloud/nhncloud` `v1.0.8`
- Terraform Registry schema 검증 기준 Resources `110개`, Data sources `53개`

## 구성

```text
docs/
  nhn-cloud-terraform-scope.md              # 구축 가능 범위와 표준 아키텍처
  nhn-cloud-terraform-provider-inventory.md # provider 전체 리소스/데이터소스 목록
  nhn-cloud-terraform-build-guide.md        # 실제 구축 절차 가이드
  assets/
    nhn-cloud-standard-architecture.svg     # 표준 아키텍처 그림
infra/
  envs/dev/                                 # NHN Cloud foundation stack
  platform/dev/                             # NKS 내부 Kubernetes platform stack
  modules/                                  # 재사용 Terraform modules
harness/
  scripts/                                  # 검증/인벤토리 추출 스크립트
```

## 먼저 읽을 문서

1. [구축 범위와 표준 아키텍처](./docs/nhn-cloud-terraform-scope.md)
2. [NHN Cloud Terraform 구축 가이드](./docs/nhn-cloud-terraform-build-guide.md)
3. [Provider Inventory](./docs/nhn-cloud-terraform-provider-inventory.md)

## 표준 아키텍처

![NHN Cloud 표준 아키텍처](./docs/assets/nhn-cloud-standard-architecture.svg)

설계는 두 단계로 나뉩니다.

| Stack | 경로 | 역할 |
|---|---|---|
| Cloud foundation | `infra/envs/dev` | VPC, subnet, routing table, security group, Object Storage, NKS |
| Kubernetes platform | `infra/platform/dev` | namespace, StorageClass, cert-manager, Argo CD, CI/CD 확장 add-on |

## 콘솔에서 먼저 확인할 값

Terraform 실행 전에 아래 값이 필요합니다.

| 값 | 용도 |
|---|---|
| NHN Cloud API Endpoint, Tenant ID, API Password | provider 인증 |
| Keypair name | NKS worker SSH 접근 |
| NKS worker flavor UUID | worker node 사양 |
| NKS node image UUID | worker base image |
| Kubernetes/addon version | NKS 생성 label |
| External network/subnet ID | NKS public endpoint |
| Internet Gateway ID | routing table attach |
| Quota | NKS, LB, volume 생성 가능성 확인 |

자세한 목록은 [구축 가이드](./docs/nhn-cloud-terraform-build-guide.md)의 “콘솔에서 미리 생성하거나 확인해야 하는 값”을 참고하세요.

## 실행 순서

Cloud foundation:

```bash
cp ./infra/envs/dev/terraform.tfvars.example ./infra/envs/dev/terraform.tfvars

terraform -chdir=infra/envs/dev init -backend=false
terraform -chdir=infra/envs/dev plan
```

NKS 생성 후 Kubernetes platform:

```bash
cp ./infra/platform/dev/terraform.tfvars.example ./infra/platform/dev/terraform.tfvars

terraform -chdir=infra/platform/dev init
terraform -chdir=infra/platform/dev plan
```

`apply`는 plan을 검토한 뒤 실행합니다.

## 검증

Provider schema 검증:

```bash
pwsh ./harness/scripts/verify-registry-schema.ps1 -ProviderVersion 1.0.8
```

정적 검증:

```bash
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/envs/dev
```

Plan JSON 생성:

```bash
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/envs/dev
```

## 운영 주의사항

- `terraform.tfvars`, state, plan 파일은 커밋하지 않습니다.
- 운영 `apply` 전에는 반드시 plan을 검토합니다.
- NKS cluster label, addon, node image, subnet, keypair 변경은 재생성 위험이 있습니다.
- Kubernetes Secret, CI token, registry password 같은 민감값은 Terraform state에 남기지 않습니다.
- provider code에는 있지만 문서화가 약한 리소스는 dev smoke 검증 후 운영 편입합니다.
