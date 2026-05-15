# NHN Cloud Terraform PoC

NHN Cloud에서 Terraform으로 생성/관리할 수 있는 리소스 범위를 분석하고, IaaS 3-tier 전환안과 클라우드 네이티브 전환안의 표준 아키텍처와 Terraform 프로젝트 골격을 정리한 저장소입니다.

기준 provider:

- `nhn-cloud/nhncloud` `v1.0.8`
- Terraform Registry schema 검증 기준 Resources `110개`, Data sources `53개`

## 구성

```text
docs/
  standards/
    terraform-scope.md                      # 구축 가능 범위와 운영 판단
    architecture/
      iaas-3tier.md                         # IaaS 3-tier 표준 설계
      cloud-native.md                       # 클라우드 네이티브 표준 설계
  guides/
    build-guide.md                          # 구축 가이드 진입점
    iaas-3tier-build-guide.md
    cloud-native-build-guide.md
  reference/
    provider-inventory.md                   # provider 전체 리소스/데이터소스 목록
  assets/
    nhn-cloud-standard-architecture.svg     # 표준 아키텍처 비교도
    nhn-cloud-iaas-3tier-architecture.svg
    nhn-cloud-cloud-native-architecture.svg
infra/
  blueprints/
    iaas-3tier/examples/dev/                # 바로 실행 가능한 IaaS 3-tier 예시
    cloud-native/foundation/examples/dev/   # NKS foundation 예시
    cloud-native/platform/examples/dev/     # NKS 내부 platform 예시
  modules/
    network/
    security/
    compute/
    load-balancer/
    block-storage/
    object-storage/
    nks/
    k8s-platform/
harness/
  scripts/                                  # 검증/인벤토리 추출 스크립트
```

## 먼저 읽을 문서

1. [NHN Cloud Terraform 구축 가이드](./docs/guides/build-guide.md)
2. [IaaS 3-tier 구축 가이드](./docs/guides/iaas-3tier-build-guide.md)
3. [클라우드 네이티브 구축 가이드](./docs/guides/cloud-native-build-guide.md)
4. [구축 범위와 표준 아키텍처](./docs/standards/terraform-scope.md)
5. [Provider Inventory](./docs/reference/provider-inventory.md)

## 표준 아키텍처

![NHN Cloud 표준 아키텍처 비교도](./docs/assets/nhn-cloud-standard-architecture.svg)

설계는 두 가지 표준안으로 나뉩니다.

| 표준안 | 주요 구조 | Terraform 역할 |
|---|---|---|
| IaaS 3-tier 전환 | Web/WAS/DB VM, 운영 솔루션 서버, LB, volume | VPC, subnet, security group, compute, LB, volume, Object Storage 표준화 |
| 클라우드 네이티브 전환 | NKS, GitOps, CI/CD, Object Storage | VPC, NKS, Object Storage, namespace, StorageClass, Helm add-on 표준화 |

현재 구현된 Terraform 코드는 `infra/blueprints` 아래에 전환 유형별로 분리되어 있다. `infra/modules`는 blueprint가 사용하는 공통 모듈이며 직접 실행 대상이 아니다.

## 콘솔에서 먼저 확인할 값

Terraform 실행 전에 아래 값이 필요합니다.

| 값 | 용도 |
|---|---|
| NHN Cloud API Endpoint, Tenant ID, API Password | provider 인증 |
| Keypair name | VM 또는 NKS worker SSH 접근 |
| VM/NKS flavor UUID | 서버 또는 worker node 사양 |
| VM/NKS image UUID | 서버 또는 worker base image |
| Kubernetes/addon version | NKS 생성 label |
| External network/subnet ID | Floating IP, LB, NKS public endpoint |
| Internet Gateway ID | routing table attach |
| Quota | NKS, LB, volume 생성 가능성 확인 |

자세한 목록은 [구축 가이드](./docs/guides/build-guide.md)의 공통 사전 준비와 전환 유형별 가이드를 참고하세요.

## 빠른 시작

전환 유형에 맞는 가이드를 먼저 선택하고, `terraform.tfvars.example`을 복사한 뒤 실제 값으로 채운다. 민감값은 가능하면 환경 변수나 CI secret으로 주입한다.

IaaS 3-tier 실제 계정 검증 브랜치에서는 [validation/iaas-3tier](./validation/iaas-3tier)를 사용한다. 이 디렉터리는 표준 blueprint와 필요한 모듈을 복제한 독립 실행 workspace다.

IaaS 3-tier 전환:

```bash
cp ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars.example ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/iaas-3tier/examples/dev init -backend=false
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev validate
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev plan
```

클라우드 네이티브 foundation:

```bash
cp ./infra/blueprints/cloud-native/foundation/examples/dev/terraform.tfvars.example ./infra/blueprints/cloud-native/foundation/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev init -backend=false
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev validate
terraform -chdir=infra/blueprints/cloud-native/foundation/examples/dev plan
```

NKS 생성 후 Kubernetes platform:

```bash
cp ./infra/blueprints/cloud-native/platform/examples/dev/terraform.tfvars.example ./infra/blueprints/cloud-native/platform/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev init
terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev validate
terraform -chdir=infra/blueprints/cloud-native/platform/examples/dev plan
```

`apply`는 plan을 검토한 뒤 실행합니다.

## 검증

Provider schema 검증:

```bash
pwsh ./harness/scripts/verify-registry-schema.ps1 -ProviderVersion 1.0.8
```

정적 검증:

```bash
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/blueprints/iaas-3tier/examples/dev
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/blueprints/cloud-native/foundation/examples/dev
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/blueprints/cloud-native/platform/examples/dev
```

Plan JSON 생성:

```bash
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/blueprints/iaas-3tier/examples/dev
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/blueprints/cloud-native/foundation/examples/dev
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/blueprints/cloud-native/platform/examples/dev
```

## 운영 주의사항

- `terraform.tfvars`, state, plan 파일은 커밋하지 않습니다.
- 운영 `apply` 전에는 반드시 plan을 검토합니다.
- NKS cluster label, addon, node image, subnet, keypair 변경은 재생성 위험이 있습니다.
- Kubernetes Secret, CI token, registry password 같은 민감값은 Terraform state에 남기지 않습니다.
- provider code에는 있지만 문서화가 약한 리소스는 dev smoke 검증 후 운영 편입합니다.
