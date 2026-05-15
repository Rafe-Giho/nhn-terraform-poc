# NHN Cloud Terraform 구축 가이드

기준 provider: `nhn-cloud/nhncloud` `= 1.0.8`

검증 기준: Terraform Registry provider schema, provider GitHub `v1.0.8` 태그

이 문서는 구축 가이드의 진입점이다. 실제 절차는 전환 유형별 가이드를 따른다.

| 전환 유형 | 대상 | 가이드 |
|---|---|---|
| IaaS 3-tier 전환 | 기존 VM/물리 업무시스템을 Web/WAS/DB와 운영 솔루션 서버 구조로 이전 | [IaaS 3-tier 구축 가이드](./iaas-3tier-build-guide.md) |
| 클라우드 네이티브 전환 | NKS, GitOps, CI/CD, Object Storage 기반 컨테이너 플랫폼 구축 | [클라우드 네이티브 구축 가이드](./cloud-native-build-guide.md) |

관련 문서:

- [구축 범위](../standards/terraform-scope.md)
- [provider inventory](../reference/provider-inventory.md)
- [표준 아키텍처 비교도](../assets/nhn-cloud-standard-architecture.svg)
- [IaaS 3-tier 표준 아키텍처](../assets/nhn-cloud-iaas-3tier-architecture.svg)
- [클라우드 네이티브 표준 아키텍처](../assets/nhn-cloud-cloud-native-architecture.svg)

## 1. 선택 기준

| 구분 | IaaS 3-tier 전환 | 클라우드 네이티브 전환 |
|---|---|---|
| 주 대상 | 기존 물리/VM 업무시스템 이전 | 애플리케이션 현대화, 컨테이너 전환 |
| 런타임 | Compute Instance | NKS worker node |
| 애플리케이션 구조 | Web 서버, WAS 서버, DB 서버 분리 | Gateway/Ingress, workload, service, pod |
| 운영 솔루션 | 모니터링, 로그, 백업, 보안 솔루션을 전용 서버로 구성 | Kubernetes add-on, Helm chart, DaemonSet/Agent 중심 |
| 배포 방식 | 수동 배포, SCP, Ansible, VM image, CI 연동 | GitOps, Argo CD, CI runner, image registry |
| 데이터 계층 | VM 기반 DB 또는 별도 Managed DB 검증 | Managed DB 또는 외부 DB 권장, stateful workload는 별도 검증 |
| Terraform 적합도 | 네트워크/보안/VM/LB/볼륨 표준화에 적합 | NKS foundation과 platform add-on 표준화에 적합 |
| 현재 저장소 구현 | `infra/blueprints/iaas-3tier/examples/dev`에 기본 blueprint 구현 | `infra/blueprints/cloud-native/foundation/examples/dev`, `infra/blueprints/cloud-native/platform/examples/dev`에 기본 blueprint 구현 |

두 표준안은 같은 NHN Cloud provider를 사용하지만 state, 승인 절차, 운영 단위를 분리한다. 한 state에 섞으면 장애 범위와 변경 영향이 커진다.

## 2. 공통 사전 준비

로컬 실행 도구:

| 도구 | 용도 |
|---|---|
| Terraform `>= 1.5` | NHN Cloud 리소스 plan/apply |
| Bash | 프로젝트 생성과 하네스 스크립트 실행 |
| Python 3 | provider inventory/schema 하네스 처리 |
| tflint, checkov 또는 tfsec | 선택 정적 검증 |

아래 값은 전환 유형과 무관하게 먼저 확인한다.

| 항목 | 필수 | 이유 |
|---|---:|---|
| API Endpoint | 예 | provider 인증 |
| Tenant/Project ID | 예 | 리소스 소유 프로젝트 지정 |
| API Password | 예 | provider 인증 |
| Region | 예 | 리소스 생성 리전 |
| External network/subnet ID | 예 | Floating IP, public LB, NKS public endpoint |
| Internet Gateway ID | 조건부 | routing table gateway attach |
| Keypair | 예 | VM/NKS worker SSH 접근 |
| Image UUID | 예 | VM 또는 NKS worker base image |
| Flavor UUID | 예 | VM 또는 worker node 사양 |
| Quota | 예 | VM, LB, Floating IP, volume, NKS 생성 실패 방지 |
| DNS zone/record | 조건부 | 서비스 도메인 연결 |
| TLS 인증서/Key Manager ref | 조건부 | HTTPS termination |
| Remote state 저장소 | 조건부 | 협업과 운영 state 관리 |
| 보안 요구사항 | 예 | 망 분리, 접근 통제, 로그 보존, 백업 정책 확정 |

민감값은 `terraform.tfvars`에 저장하지 않는다. 로컬 실행은 환경 변수 주입을 기본으로 한다.

```bash
export TF_VAR_nhncloud_user_name="<NHN Cloud ID>"
export TF_VAR_nhncloud_tenant_id="<tenant-id>"
export TF_VAR_nhncloud_password="<api-password>"
export TF_VAR_nhncloud_auth_url="https://api-identity-infrastructure.nhncloudservice.com/v2.0"
export TF_VAR_nhncloud_region="KR1"
```

## 3. 권장 디렉터리 구조

```text
infra/
  blueprints/
    iaas-3tier/
      examples/dev/         # IaaS 3-tier foundation, compute, lb, storage
    cloud-native/
      foundation/examples/dev/
      platform/examples/dev/
  modules/
    network/
    security/
    object-storage/
    compute/
    load-balancer/
    block-storage/
    nks/
    k8s-platform/
tools/
  new-project/
    create-iaas-3tier.sh
    create-cloud-native.sh
projects/                 # 생성 스크립트의 기본 출력 경로. 커밋하지 않음
```

현재 저장소의 구현 경로는 다음과 같다.

| 구분 | 현재 경로 | 상태 |
|---|---|---|
| IaaS 3-tier blueprint | `infra/blueprints/iaas-3tier/examples/dev` | 구현됨 |
| 클라우드 네이티브 foundation blueprint | `infra/blueprints/cloud-native/foundation/examples/dev` | 구현됨 |
| 클라우드 네이티브 platform blueprint | `infra/blueprints/cloud-native/platform/examples/dev` | 구현됨 |
| compute/lb/block-storage 모듈 | `infra/modules/compute`, `infra/modules/load-balancer`, `infra/modules/block-storage` | 구현됨 |

## 4. 사업별 workspace 생성

팀원은 `infra/blueprints`를 직접 수정하지 않는다. 표준 원본에서 사업별 workspace를 생성한 뒤 그 안에서 `terraform.tfvars`, backend, state를 관리한다.

IaaS 3-tier:

```bash
./tools/new-project/create-iaas-3tier.sh customer-a dev
cd ./projects/customer-a/iaas-3tier/dev
```

클라우드 네이티브:

```bash
./tools/new-project/create-cloud-native.sh customer-a dev
cd ./projects/customer-a/cloud-native/dev
```

기본 출력 경로인 `projects/`는 `.gitignore` 대상이다. 실제 사업 repository로 관리하려면 세 번째 인자에 별도 경로를 지정한다.

```bash
./tools/new-project/create-iaas-3tier.sh customer-a prod ../customer-a-infra/iaas-3tier/prod
./tools/new-project/create-cloud-native.sh customer-a prod ../customer-a-infra/cloud-native/prod
```

생성된 workspace 안에는 실행 root와 필요한 모듈 복제본이 함께 들어간다. 이후 사업별 변경은 생성된 workspace에서 수행하고, 공통 표준 개선은 `infra/blueprints`와 `infra/modules`에 별도 반영한다.

## 5. 공통 Terraform 실행 흐름

모든 stack은 아래 순서를 따른다.

```bash
cp ./terraform.tfvars.example ./terraform.tfvars
terraform init -backend=false
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
```

remote state를 사용할 때는 backend 설정 파일을 먼저 확정한 뒤 초기화한다.

```bash
terraform init -backend-config=backend.s3.hcl
```

plan 검토 후 적용한다.

```bash
terraform apply tfplan
```

운영 변경 전에는 항상 현재 상태를 먼저 확인한다.

```bash
terraform plan -refresh-only
```

기존 콘솔 리소스를 편입해야 할 때는 import 후 첫 plan에서 재생성 여부를 확인한다.

```bash
terraform import nhncloud_networking_vpc_v2.main <vpc-id>
terraform plan
```

커밋 금지 대상:

- `terraform.tfvars`
- `.terraform/`
- `.terraform.lock.hcl`
- `*.tfstate`, `*.tfstate.*`
- `tfplan`, `*.tfplan`, `plan.json`
- kubeconfig, token, license key, private key

## 6. 공통 검증 게이트

정적 검증:

```bash
./harness/scripts/static-check.sh --terraform-root ./infra/blueprints/iaas-3tier/examples/dev
./harness/scripts/static-check.sh --terraform-root ./infra/blueprints/cloud-native/foundation/examples/dev
./harness/scripts/static-check.sh --terraform-root ./infra/blueprints/cloud-native/platform/examples/dev
```

Registry schema 검증:

```bash
./harness/scripts/verify-registry-schema.sh --provider-version 1.0.8
```

Plan JSON:

```bash
./harness/scripts/plan-json.sh --terraform-root ./infra/blueprints/iaas-3tier/examples/dev
./harness/scripts/plan-json.sh --terraform-root ./infra/blueprints/cloud-native/foundation/examples/dev
./harness/scripts/plan-json.sh --terraform-root ./infra/blueprints/cloud-native/platform/examples/dev
```

검토 항목:

- `delete` 또는 `replace` 존재 여부
- 운영 환경에서 `-target` 사용 여부
- SSH/RDP 공개 여부
- public ingress CIDR 확대 여부
- Web/WAS/DB 보안 그룹 계층 위반 여부
- NKS node count, version, addon 변경 여부
- Object Storage container 삭제 여부
- state에 민감값이 들어갈 가능성
- 콘솔 선행 리소스 ID가 실제 리전/프로젝트와 일치하는지 여부

## 7. 다음 문서

IaaS 기반 전환이면 [IaaS 3-tier 구축 가이드](./iaas-3tier-build-guide.md)를 따른다.

NKS 기반 전환이면 [클라우드 네이티브 구축 가이드](./cloud-native-build-guide.md)를 따른다.
