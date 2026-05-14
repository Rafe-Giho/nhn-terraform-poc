# NHN Cloud Terraform 구축 가이드

기준 provider: `nhn-cloud/nhncloud` `= 1.0.8`  
검증 기준: Terraform Registry provider schema, provider GitHub `v1.0.8` 태그  
대상 구조: NHN Cloud VPC + NKS + Kubernetes CI/CD 플랫폼 + Object Storage

관련 문서:

- [구축 범위](./nhn-cloud-terraform-scope.md)
- [provider inventory](./nhn-cloud-terraform-provider-inventory.md)
- [표준 아키텍처 SVG](./assets/nhn-cloud-standard-architecture.svg)

## 1. 설계 원칙

이 저장소의 표준 구조는 두 개의 Terraform stack으로 나눈다.

| Stack | 경로 | Provider | 역할 |
|---|---|---|---|
| Cloud foundation | `infra/envs/dev` | `nhn-cloud/nhncloud` | VPC, subnet, routing table, security group, Object Storage, NKS 생성 |
| Kubernetes platform | `infra/platform/dev` | `hashicorp/kubernetes`, `hashicorp/helm` | NKS 내부 namespace, StorageClass, cert-manager, Argo CD, CI/CD add-on 설치 |

분리 이유:

- NKS 클러스터가 만들어진 뒤 kubeconfig가 발급되어야 Kubernetes provider와 Helm provider를 사용할 수 있다.
- NHN Cloud 리소스와 Kubernetes 내부 리소스는 장애 범위, 권한, state 수명주기가 다르다.
- 운영에서 클러스터 재생성 위험이 있는 변경과 애드온 변경을 분리할 수 있다.

## 2. 현재 구현된 디렉터리

```text
infra/
  README.md
  envs/
    dev/
      versions.tf
      providers.tf
      variables.tf
      main.tf
      outputs.tf
      terraform.tfvars.example
      backend.s3.example.hcl
  platform/
    dev/
      versions.tf
      providers.tf
      variables.tf
      main.tf
      outputs.tf
      terraform.tfvars.example
  modules/
    network/
    security/
    object-storage/
    nks/
    k8s-platform/
```

## 3. Terraform으로 생성하는 리소스

`infra/envs/dev`에서 생성한다.

| 영역 | 리소스 |
|---|---|
| Network | `nhncloud_networking_vpc_v2`, `nhncloud_networking_routingtable_v2`, `nhncloud_networking_vpcsubnet_v2` |
| Gateway attachment | `nhncloud_networking_routingtable_attach_gateway_v2` |
| Security | `nhncloud_networking_secgroup_v2`, `nhncloud_networking_secgroup_rule_v2` |
| Object Storage | `nhncloud_objectstorage_container_v1` |
| NKS | `nhncloud_kubernetes_cluster_v1`, `nhncloud_kubernetes_nodegroup_v1` |

`infra/platform/dev`에서 생성한다.

| 영역 | 리소스 |
|---|---|
| Kubernetes namespace | `kubernetes_namespace_v1` |
| Kubernetes StorageClass | `kubernetes_storage_class_v1` |
| Helm add-on | `helm_release` |

기본 Helm add-on:

- `cert-manager`
- `argo-cd`

CI runner, NGINX Gateway, monitoring, logging 등은 `extra_helm_releases`로 추가한다. runner token 같은 민감값은 Terraform state에 남을 수 있으므로 직접 넣지 않는다.

검증 메모:

- `nhncloud_kubernetes_nodegroup_v1` 문서에는 `min_node_count`, `max_node_count` 인자가 언급되지만, Registry `v1.0.8` provider schema에는 해당 인자가 없다.
- 이 저장소의 `nks` 모듈은 nodegroup autoscaling 값을 resource argument로 넣지 않고 `labels` 또는 별도 resize/upgrade 흐름으로 관리한다.

## 4. 콘솔에서 미리 생성하거나 확인해야 하는 값

아래 값은 Terraform만으로 안전하게 만들기 어렵거나, provider에서 생성 범위가 명확하지 않거나, 생성 전 사용자가 정책적으로 결정해야 한다.

| 항목 | 필수 | 이유 | 사용 위치 |
|---|---:|---|---|
| API Endpoint 설정 | 예 | Terraform provider 인증에 필요 | `nhncloud_auth_url`, `tenant_id`, API password |
| Tenant/Project ID | 예 | provider 인증과 리소스 소유 프로젝트 지정 | `nhncloud_tenant_id` |
| API Password | 예 | provider 인증 | `nhncloud_password` |
| Region | 예 | 리소스 생성 리전 | `nhncloud_region` |
| Keypair | 예 | NKS worker SSH 접근용. Terraform 생성 시 private key가 state에 저장될 수 있음 | `nks_keypair_name` |
| NKS worker flavor UUID | 예 | worker node 사양 | `nks_node_flavor_id` |
| NKS node image UUID | 예 | worker base image | `nks_node_image_id` |
| NKS Kubernetes/addon version | 예 | 리전별 지원 버전 차이 가능 | `nks_kubernetes_version`, `nks_calico_version`, `nks_coredns_version` |
| External network ID | 예 | NKS API endpoint, public LB 연동 | `nks_external_network_id` |
| External subnet ID list | 예 | NKS public endpoint 구성 | `nks_external_subnet_id_list` |
| Internet Gateway ID | 조건부 | provider는 routing table attach만 표준화. Gateway 자체 생성은 콘솔 선행 권장 | `internet_gateway_id` |
| DNS zone/record | 조건부 | provider 코드에는 DNS 리소스가 있지만 운영 표준 A 범위로 보지 않음 | 외부 DNS 또는 콘솔 |
| TLS 인증서/Key Manager container ref | 조건부 | HTTPS termination 시 필요 | Gateway/LB/Ingress 설정 |
| Container Registry | 조건부 | 애플리케이션 이미지 저장소 | CI/CD pipeline |
| Terraform remote state bucket/container | 조건부 | remote backend 사용 시 backend init 전에 선행 생성 필요 | `backend.s3.example.hcl` |
| Quota | 예 | NKS node, LB, Floating IP, block volume 생성 실패 방지 | 사전 점검 |
| NAT Gateway, Transit Hub, VPN | 조건부 | provider 표준 A 범위 밖 | 콘솔 선행 또는 별도 PoC |
| RDS/Managed DB | 조건부 | provider 코드에는 DB 리소스가 있으나 운영 표준 편입 전 검증 필요 | 별도 PoC |

## 5. 인증 설정

로컬에서는 `terraform.tfvars`에 비밀번호를 쓰지 말고 환경 변수 사용을 권장한다.

```bash
export TF_VAR_nhncloud_user_name="<NHN Cloud ID>"
export TF_VAR_nhncloud_tenant_id="<tenant-id>"
export TF_VAR_nhncloud_password="<api-password>"
export TF_VAR_nhncloud_auth_url="https://api-identity-infrastructure.nhncloudservice.com/v2.0"
export TF_VAR_nhncloud_region="KR1"
```

`infra/envs/dev/terraform.tfvars.example`을 복사해 `terraform.tfvars`를 만들되, 민감값은 가능하면 환경 변수나 CI secret로 주입한다.

```bash
cp ./infra/envs/dev/terraform.tfvars.example ./infra/envs/dev/terraform.tfvars
```

## 6. Cloud foundation 실행

초기화:

```bash
terraform -chdir=infra/envs/dev init -backend=false
```

정적 포맷:

```bash
terraform -chdir=infra/envs/dev fmt -recursive
```

계획 확인:

```bash
terraform -chdir=infra/envs/dev plan -out=tfplan
terraform -chdir=infra/envs/dev show -json tfplan > ../../../harness/out/dev-foundation-plan.json
```

적용:

```bash
terraform -chdir=infra/envs/dev apply tfplan
```

적용 전 확인:

- VPC CIDR이 기존 네트워크와 겹치지 않는지 확인
- `internet_gateway_id`가 같은 VPC/routing table에 연결 가능한지 확인
- `nks_subnet_key`가 실제 생성되는 subnet key와 일치하는지 확인
- NKS version/addon version이 해당 리전에서 지원되는지 확인
- Object Storage container 이름이 프로젝트 내에서 충돌하지 않는지 확인

## 7. Kubernetes platform 실행

NKS 생성 후 NHN Cloud 콘솔에서 kubeconfig를 발급받는다.

`infra/platform/dev/terraform.tfvars.example`을 복사한다.

```bash
cp ./infra/platform/dev/terraform.tfvars.example ./infra/platform/dev/terraform.tfvars
```

`kubeconfig_path`, `kubeconfig_context`를 실제 값으로 수정한다.

초기화:

```bash
terraform -chdir=infra/platform/dev init
```

계획 확인:

```bash
terraform -chdir=infra/platform/dev plan -out=tfplan
```

적용:

```bash
terraform -chdir=infra/platform/dev apply tfplan
```

기본 생성:

- `argocd` namespace
- `cert-manager` namespace
- `cicd` namespace
- `apps` namespace
- `observability` namespace
- `ingress-system` namespace
- `nhn-cinder-hdd-retain` StorageClass
- `cert-manager` Helm release
- `argocd` Helm release

## 8. CI/CD 설계

권장 흐름:

```text
Developer -> Git Repository -> CI Runner -> Container Registry/Object Storage -> Argo CD -> NKS Apps
```

역할:

| 구성요소 | 역할 | Terraform 관리 방식 |
|---|---|---|
| Git repository | 소스/manifest 저장 | Terraform 범위 밖 |
| CI Runner | build/test/image push | `extra_helm_releases`로 설치 가능. token은 별도 Secret |
| Object Storage | artifact, log, backup 저장 | `object-storage` module |
| Container Registry | image 저장 | NHN Cloud 콘솔/서비스 API 또는 외부 registry |
| Argo CD | GitOps CD | `k8s-platform` module의 Helm release |
| cert-manager | 인증서 자동화 | `k8s-platform` module의 Helm release |
| Gateway/Ingress | 외부 트래픽 진입 | Helm release 또는 Kubernetes manifest 별도 추가 |

민감값 처리:

- GitLab Runner registration token, GitHub token, registry password는 Terraform 변수에 직접 넣지 않는다.
- 필요한 경우 Kubernetes Secret을 수동 생성하거나 External Secrets/Sealed Secrets를 사용한다.
- Terraform으로 Secret을 만들면 state에 평문 또는 base64 값이 남을 수 있다.

## 9. Object Storage 사용 기준

기본 container:

| Container | 용도 |
|---|---|
| `artifacts` | CI build artifact, release bundle |
| `backups` | DB dump, manifest export, 장애 복구 자료 |
| `logs` | pipeline log, 배치 처리 결과 |

주의:

- Terraform으로 대량 object를 직접 관리하지 않는다.
- Object Storage를 Terraform backend로 쓰려면 backend bucket/container를 먼저 만들어야 한다.
- NHN Object Storage S3 호환 backend는 별도 smoke 검증 후 운영 적용한다.

## 10. Remote state

현재 예제는 안전한 PoC를 위해 backend를 코드에 고정하지 않았다.

선택지:

| 방식 | 장점 | 주의 |
|---|---|---|
| local state | 단순함 | 협업/운영 부적합 |
| Terraform Cloud | lock/이력 관리 용이 | 외부 SaaS 사용 |
| S3-compatible backend | 범용적 | NHN Object Storage endpoint 검증 필요 |
| 별도 사내 backend | 정책 통제 가능 | 운영 설계 필요 |

S3-compatible backend 예시는 `infra/envs/dev/backend.s3.example.hcl`에 있다. backend용 bucket/container는 `terraform init` 전에 선행 생성해야 한다.

## 11. 기존 리소스 편입

기존 NHN Cloud 리소스가 있으면 새로 만들지 말고 import한다.

```bash
terraform import nhncloud_networking_vpc_v2.main <vpc-id>
terraform import nhncloud_networking_vpcsubnet_v2.app <subnet-id>
terraform import nhncloud_networking_secgroup_v2.web <security-group-id>
terraform import nhncloud_kubernetes_cluster_v1.main <cluster-uuid>
```

절차:

1. resource block 작성
2. `terraform import`
3. `terraform plan`
4. 실제 리소스와 코드 차이 보정
5. no-op plan 확인

운영 클러스터 import 후 첫 plan은 절대 바로 apply하지 않는다. `replace` 또는 `delete`가 보이면 원인을 먼저 제거한다.

## 12. 검증 게이트

정적 검증:

```bash
pwsh ./harness/scripts/static-check.ps1 -TerraformRoot ./infra/envs/dev
```

Registry schema 검증:

```bash
pwsh ./harness/scripts/verify-registry-schema.ps1 -ProviderVersion 1.0.8
```

Plan JSON:

```bash
pwsh ./harness/scripts/plan-json.ps1 -TerraformRoot ./infra/envs/dev
```

검토 항목:

- `delete` 또는 `replace` 존재 여부
- 운영 환경에서 `-target` 사용 여부
- SSH/RDP 공개 여부
- NKS node count, version, addon 변경 여부
- Object Storage container 삭제 여부
- state에 민감값이 들어갈 가능성
- 콘솔 선행 리소스 ID가 실제 리전/프로젝트와 일치하는지 여부

## 13. 운영 변경 기준

허용:

- dev 환경 신규 리소스 생성
- 보안 그룹의 제한적 CIDR 추가
- Object Storage container metadata 변경
- platform add-on minor 설정 변경

승인 필요:

- NKS cluster labels/addons 변경
- NKS node image/flavor/subnet/keypair 변경
- public ingress CIDR 확대
- Object Storage container 삭제
- NAS, DB, dedicated LB, 대용량 volume 생성
- prod apply

금지 또는 별도 절차:

- 운영 `terraform destroy`
- 운영 state 수동 편집
- 민감값을 `*.tfvars` 또는 Terraform Secret resource에 저장
- provider docs가 없는 B 등급 리소스의 바로 운영 적용

## 14. 완료 기준

구축 완료 조건:

- `infra/envs/dev` plan 리뷰 완료
- NKS 생성 후 kubeconfig 발급 확인
- `infra/platform/dev` plan 리뷰 완료
- Argo CD/cert-manager 설치 상태 확인
- StorageClass/PVC 동작 smoke 확인
- Object Storage container CRUD smoke 확인
- 문서에 콘솔 선행 값과 실제 적용 값 기록
