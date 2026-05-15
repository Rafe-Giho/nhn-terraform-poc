# NHN Cloud 클라우드 네이티브 구축 가이드

기준 provider: `nhn-cloud/nhncloud` `= 1.0.8`

대상: NKS, GitOps, CI/CD, DevOps 연동 서버, Object Storage 기반 컨테이너 플랫폼

아키텍처:

![클라우드 네이티브 표준 아키텍처](../assets/nhn-cloud-cloud-native-architecture.svg)

## 1. 적용 범위

이 가이드는 애플리케이션을 컨테이너로 전환하거나 신규 서비스를 NKS 기반으로 구축할 때 사용한다. NHN Cloud 리소스와 Kubernetes 내부 리소스의 생명주기를 분리하고, GitOps와 CI/CD를 표준 배포 경로로 둔다. 네트워크는 Public VPC/Private VPC 2개가 아니라 하나의 VPC 안에서 public/private/management routing table과 역할별 subnet으로 분리한다.

현재 저장소에는 기본 골격이 구현되어 있다.

| Stack | 경로 | 역할 |
|---|---|---|
| Cloud foundation | `infra/blueprints/cloud-native/foundation/examples/dev` | VPC, subnet, routing table, security group, Object Storage, DevOps 연동 서버, NKS |
| Kubernetes platform | `infra/blueprints/cloud-native/platform/examples/dev` | namespace, StorageClass, cert-manager, Argo CD, CI/CD 확장 add-on |

팀원은 표준 원본을 직접 수정하지 않고 생성 스크립트로 사업별 workspace를 만든다.

```bash
./tools/new-project/create-cloud-native.sh customer-a dev
cd ./projects/customer-a/cloud-native/dev
```

생성 구조:

```text
projects/<project-name>/cloud-native/<env>/
  foundation/       # NHN Cloud VPC, Object Storage, NKS
  platform/         # Kubernetes namespace, StorageClass, Helm add-on
  modules/
  harness/scripts/
```

실제 사업 repository에 바로 만들려면 세 번째 인자로 대상 경로를 지정한다.

```bash
./tools/new-project/create-cloud-native.sh customer-a prod ../customer-a-infra/cloud-native/prod
```

## 2. 콘솔 선행 확인 값

| 항목 | 필수 | 사용 위치 |
|---|---:|---|
| Tenant/Project ID, API Endpoint, API Password | 예 | provider 인증 |
| Region | 예 | provider 설정 |
| Internet Gateway ID | 조건부 | public routing table attach |
| NKS worker flavor UUID | 예 | `nks_node_flavor_id` |
| NKS worker image UUID | 예 | `nks_node_image_id` |
| Keypair name | 예 | `nks_keypair_name` |
| Kubernetes version | 예 | `nks_kubernetes_version` |
| Calico/CoreDNS version | 예 | `nks_calico_version`, `nks_coredns_version` |
| External network/subnet ID | 예 | NKS public endpoint |
| DNS/TLS | 조건부 | Ingress/Gateway |
| Container Registry | 조건부 | CI/CD image push |
| GitLab/Gitea/Jenkins 서버 image/flavor | 조건부 | VM 기반 DevOps 연동 서버 |
| DevOps 서비스 접근 CIDR | 조건부 | GitLab/Gitea/Jenkins HTTPS/SSH/Jenkins agent 접근 |
| Network ACL | 조건부 | ingress/devops/management subnet 앞단 allow/deny 통제 |
| Flow Log 저장 Object Storage | 조건부 | NKS worker, DevOps VM, entrypoint 트래픽 검증 |
| NAT Gateway/Service Gateway | 조건부 | private worker와 DevOps VM의 외부/NHN 서비스 접근 |
| Managed DB 또는 외부 DB | 조건부 | 애플리케이션 데이터 계층 |
| Quota | 예 | NKS worker, LB, volume, Floating IP 생성 가능성 |

## 3. Terraform 생성/관리 범위

`infra/blueprints/cloud-native/foundation/examples/dev`에서 생성한다.

| 영역 | 리소스 |
|---|---|
| Network | `nhncloud_networking_vpc_v2`, `nhncloud_networking_routingtable_v2`, `nhncloud_networking_routingtable_attach_gateway_v2`, `nhncloud_networking_vpcsubnet_v2` |
| Gateway attachment | `nhncloud_networking_routingtable_attach_gateway_v2` |
| Security | `nhncloud_networking_secgroup_v2`, `nhncloud_networking_secgroup_rule_v2` |
| Object Storage | `nhncloud_objectstorage_container_v1` |
| DevOps integration server | `nhncloud_compute_instance_v2`, `nhncloud_networking_port_v2`, `nhncloud_blockstorage_volume_v2`, `nhncloud_compute_volume_attach_v2` |
| NKS | `nhncloud_kubernetes_cluster_v1`, `nhncloud_kubernetes_nodegroup_v1` |

`infra/blueprints/cloud-native/platform/examples/dev`에서 생성한다.

| 영역 | 리소스 |
|---|---|
| Kubernetes namespace | `kubernetes_namespace_v1` |
| Kubernetes StorageClass | `kubernetes_storage_class_v1` |
| Helm add-on | `helm_release` |

기본 Helm add-on:

- `cert-manager`
- `argo-cd`

CI runner, Ingress controller, monitoring, logging, External Secrets, policy controller 등은 `extra_helm_releases`로 확장한다. runner token, registry password, webhook secret 같은 값은 Terraform state에 남을 수 있으므로 직접 변수로 넣지 않는다.

GitLab/Gitea/Jenkins는 NHN Cloud provider가 직접 제공하는 관리형 리소스가 아니다. 표준안에서는 다음 두 방식 중 하나를 선택한다.

| 방식 | 권장 상황 | Terraform 역할 |
|---|---|---|
| VM 기반 DevOps 연동 서버 | 운영 표준, 데이터 보존, 백업, 플러그인 관리가 중요한 경우 | DevOps subnet, SG, VM, data volume, Object Storage backup container 생성 |
| NKS 내부 Helm 배포 | PoC, 임시 개발환경, stateless runner/agent 중심 | namespace, StorageClass, Helm release 생성. stateful Git/Jenkins 운영은 별도 검증 |

기본 표준은 `GitLab 또는 Gitea`를 Git 저장소로 두고, `Jenkins`를 CI controller로 둘 수 있는 VM 기반 연동 서버를 foundation stack에서 선택적으로 생성하는 방식이다. NKS 내부에는 Jenkins agent, GitLab Runner, Argo CD, Ingress/Gateway, observability add-on을 둔다.

Security Group은 기본 outbound 전체 허용 rule을 삭제하고 필요한 egress만 명시한다.

| SG | Ingress | Egress |
|---|---|---|
| `public_entrypoint` | public CIDR -> TCP 80/443 | VPC CIDR -> `entrypoint_backend_ports` |
| `platform_admin` | 관리 CIDR -> SSH | VPC CIDR -> `platform_admin_egress_ports` |
| `devops_tools` | 관리 CIDR -> SSH, `devops_access_cidrs` -> Git/Jenkins 포트 | VPC CIDR -> `devops_internal_egress_ports` |
| NKS worker | NKS 관리 영역 | NKS label/add-on 요구사항 |

사업별 예외는 `extra_security_group_rules`에 추가한다. GitLab/Gitea/Jenkins를 외부에 공개해야 하는 요구는 기본 표준 예외이며 WAF/LB/IP allow 정책을 먼저 검토한다.

## 4. Cloud foundation 실행

생성된 workspace에서 foundation 변수 파일을 만든다.

```bash
cp ./foundation/terraform.tfvars.example ./foundation/terraform.tfvars
```

민감값은 환경 변수로 주입한다.

```bash
export TF_VAR_nhncloud_user_name="<NHN Cloud ID>"
export TF_VAR_nhncloud_tenant_id="<tenant-id>"
export TF_VAR_nhncloud_password="<api-password>"
export TF_VAR_nhncloud_auth_url="https://api-identity-infrastructure.nhncloudservice.com/v2.0"
export TF_VAR_nhncloud_region="KR1"
```

초기화와 검증:

```bash
terraform -chdir=foundation init -backend=false
terraform -chdir=foundation fmt -recursive
terraform -chdir=foundation validate
terraform -chdir=foundation plan -out=tfplan
terraform -chdir=foundation show -json tfplan > foundation-plan.json
./harness/scripts/policy-check.sh --plan-json ./foundation-plan.json
```

remote state를 사용할 경우 backend 설정 파일을 먼저 확정한다.

```bash
cp ./foundation/backend.s3.example.hcl ./foundation/backend.s3.hcl
terraform -chdir=foundation init -backend-config=backend.s3.hcl
```

적용 전 확인:

- VPC CIDR이 기존 네트워크, VPN, 전용회선 대역과 겹치지 않는지 확인
- `public_internet_gateway_id`가 해당 프로젝트/리전에 존재하는지 확인
- Internet Gateway가 `public` routing table에만 연결되는지 확인
- `nks_subnet_key`가 실제 생성되는 subnet key와 일치하는지 확인
- NKS version/addon version이 리전에서 지원되는지 확인
- Object Storage container 이름이 충돌하지 않는지 확인
- DevOps 연동 서버를 만들 경우 GitLab/Gitea/Jenkins 포트가 관리 CIDR 또는 사내망으로만 열리는지 확인
- private worker/DevOps VM outbound는 NAT Gateway, proxy, Service Gateway 중 하나로 설계했는지 확인
- Flow Log, Network ACL이 필요한 사업이면 콘솔 선행 설정과 Object Storage 저장소를 확인
- DevOps data volume 크기와 백업 경로가 운영 요구사항을 만족하는지 확인

plan 검토 기준:

| 항목 | 기준 |
|---|---|
| NKS cluster | cluster name, version, node image, flavor, subnet이 콘솔 확인값과 일치 |
| Node group | node count, autoscaler label, availability zone 확인 |
| Network | VPC CIDR과 subnet이 기존망/VPN/전용회선과 충돌 없음 |
| Routing table | `ingress=public`, `nks-a/nks-b=private`, `devops/management=management` |
| Security Group | API endpoint, worker, 관리 접근 CIDR이 과도하게 열리지 않음 |
| Egress | 운영 `0.0.0.0/0` 전체 outbound 없음 |
| Object Storage | container 삭제 계획 없음 |
| DevOps server | GitLab/Gitea/Jenkins VM, port, volume 생성 범위가 의도와 일치 |
| Replace | NKS cluster replacement가 있으면 적용 중단 후 원인 검토 |

적용은 plan 검토와 승인 후 실행한다.

```bash
terraform -chdir=foundation apply tfplan
terraform -chdir=foundation output
terraform -chdir=foundation plan -refresh-only
```

## 5. Kubernetes platform 실행

NKS 생성 후 NHN Cloud 콘솔에서 kubeconfig를 발급받는다.

```bash
cp ./platform/terraform.tfvars.example ./platform/terraform.tfvars
```

`kubeconfig_path`, `kubeconfig_context`를 실제 값으로 수정한다.

초기화와 계획 확인:

```bash
terraform -chdir=platform init
terraform -chdir=platform fmt -recursive
terraform -chdir=platform validate
terraform -chdir=platform plan -out=tfplan
terraform -chdir=platform show -json tfplan > platform-plan.json
```

적용은 plan 검토와 승인 후 실행한다.

```bash
terraform -chdir=platform apply tfplan
terraform -chdir=platform output
terraform -chdir=platform plan -refresh-only
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

선택 생성:

- `devops` subnet
- `public`, `private`, `management` routing table
- GitLab 또는 Gitea VM
- Jenkins controller VM
- DevOps 서버 data volume

platform plan 검토 기준:

| 항목 | 기준 |
|---|---|
| kubeconfig | 올바른 NKS cluster context를 바라봄 |
| Namespace | 기존 운영 namespace와 충돌 없음 |
| StorageClass | 기본 class 여부와 reclaim policy 확인 |
| Helm release | chart repository, version, namespace 확인 |
| Secret | token/password가 Terraform 변수나 state에 직접 저장되지 않음 |

## 6. 실제 진행 시나리오

| 시나리오 | 절차 | 판단 기준 |
|---|---|---|
| 최초 NKS 구축 | cloud-native workspace 생성, foundation tfvars 작성, plan, apply | NKS API 접근과 node Ready 확인 |
| Ingress subnet 추가 | `ingress` subnet은 public routing table 사용 | 외부 진입점만 public subnet에 배치 |
| Platform add-on 설치 | kubeconfig 발급, platform tfvars 작성, plan, apply | Argo CD/cert-manager pod 정상 |
| Node 증설 | node group count 또는 resize resource 검토 | node 추가만 발생하고 cluster replacement 없음 |
| Kubernetes version 변경 | NKS 지원 버전 확인 후 upgrade resource 검토 | nodegroup upgrade 영향과 rollback 계획 확보 |
| Ingress 추가 | `extra_helm_releases` 또는 GitOps manifest로 적용 | 외부 LB, DNS, TLS 경로 확인 |
| CI runner 추가 | runner Helm release 검토 | registration token은 Terraform state 밖에서 관리 |
| Gitea 또는 GitLab 서버 추가 | `devops_servers`에 Git 서버 VM 추가, plan, apply | Git data volume, 백업, 접근 CIDR 확인 |
| Jenkins controller 추가 | `devops_servers`에 Jenkins VM 추가, plan, apply | controller는 VM, agent는 NKS pod로 분리 |
| Drift 점검 | `terraform plan -refresh-only` | 콘솔/수동 변경 여부 확인 |

## 7. CI/CD 설계 기준

권장 흐름:

```text
Developer -> GitLab/Gitea -> Jenkins or CI Runner -> Container Registry -> Argo CD -> NKS Workloads
```

| 구성요소 | 역할 | Terraform 관리 방식 |
|---|---|---|
| GitLab 또는 Gitea | 소스와 manifest 저장 | VM/volume/SG는 foundation stack. 애플리케이션 설치와 백업 정책은 별도 절차 |
| Jenkins controller | build/test/pipeline orchestration | VM/volume/SG는 foundation stack. plugin, credential, job 설정은 별도 절차 |
| Jenkins agent 또는 CI Runner | build executor, image push | NKS Helm release 가능. token은 별도 Secret |
| Container Registry | 이미지 저장 | 콘솔/서비스 API 또는 외부 registry |
| Argo CD | GitOps CD | `k8s-platform` module |
| cert-manager | 인증서 자동화 | `k8s-platform` module |
| Ingress/Gateway | 외부 트래픽 진입 | Helm release 또는 별도 manifest |
| Object Storage | artifact, backup, export 저장 | `object-storage` module |

선택 기준:

| 선택 | 기준 |
|---|---|
| Gitea | 소규모 프로젝트, 단순 Git hosting, 낮은 운영 비용 |
| GitLab | 이슈/리뷰/패키지/보안 스캔 등 ALM 기능이 필요한 프로젝트 |
| Jenkins | 기존 Jenkins pipeline 자산이 있거나 플러그인 기반 빌드 표준이 필요한 프로젝트 |
| GitLab Runner만 사용 | GitLab SaaS/외부 GitLab을 쓰고 NKS에는 runner만 붙이는 프로젝트 |

민감값 처리:

- GitLab Runner registration token, GitHub token, registry password는 Terraform 변수에 직접 넣지 않는다.
- GitLab root password, Gitea admin password, Jenkins admin token은 Terraform 변수에 직접 넣지 않는다.
- 필요한 경우 Kubernetes Secret을 수동 생성하거나 External Secrets/Sealed Secrets를 사용한다.
- Terraform으로 Secret을 만들면 state에 평문 또는 base64 값이 남을 수 있다.

## 8. Object Storage 사용 기준

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

## 9. 검증 항목

| 검증 | 기준 |
|---|---|
| NKS API | kubeconfig로 cluster 접근 가능 |
| Routing | ingress만 public routing table, NKS worker와 DevOps 서버는 private/management routing table |
| Node group | node 상태 Ready, worker flavor/image/version 확인 |
| StorageClass | PVC 생성과 PV binding 확인 |
| cert-manager | controller pod 정상, issuer 전략 확정 |
| Argo CD | server/controller/repo-server 정상 |
| Ingress/Gateway | 외부 LB와 라우팅 정상 |
| CI/CD | runner 등록, image build/push, GitOps sync 확인 |
| DevOps server | GitLab/Gitea/Jenkins 접속, data volume mount, backup 경로 확인 |
| Object Storage | artifact/log/backup container CRUD smoke 확인 |
| Observability | metrics/log 수집과 alerting 경로 확인 |

## 10. 완료 기준

- `foundation` plan 리뷰 완료
- public/private/management routing table과 subnet mapping 확인 완료
- NKS 생성 후 kubeconfig 발급 확인
- `platform` plan 리뷰 완료
- Argo CD/cert-manager 설치 상태 확인
- StorageClass/PVC 동작 smoke 확인
- Object Storage container CRUD smoke 확인
- GitLab/Gitea/Jenkins 또는 외부 Git/CI 연동 방식 확정
- CI runner와 registry 연동 방식 확정
- DNS/TLS와 Ingress/Gateway 노출 방식 확정
- 문서에 콘솔 선행 값과 실제 적용 값 기록

## 11. 운영 주의사항

- 운영 `terraform destroy`는 금지한다.
- NKS cluster label, addon, node image, subnet, keypair 변경은 재생성 위험을 검토한다.
- runner token, registry password, kubeconfig는 Terraform state에 남기지 않는다.
- GitLab/Gitea/Jenkins 설치와 계정, 플러그인, credential은 Terraform state 밖에서 관리한다.
- workload manifest는 GitOps 저장소에서 관리하고 Terraform은 platform 경계까지만 담당한다.
- Managed DB 또는 stateful workload는 별도 PoC 후 운영 편입한다.
