# NHN Cloud 클라우드 네이티브 표준 아키텍처

이 문서는 팀 표준 NKS 기반 클라우드 네이티브 전환 설계를 정의한다. 실행 절차는 [클라우드 네이티브 구축 가이드](../../guides/cloud-native-build-guide.md)를 따른다.

![클라우드 네이티브 표준 아키텍처](../../assets/nhn-cloud-cloud-native-architecture.svg)

## 설계 기준

| 계층 | 기본 구성 | 접근 기준 |
|---|---|---|
| Cloud foundation | VPC, public/private/management routing table, subnet, security group, Object Storage, DevOps 연동 서버, NKS | `nhn-cloud/nhncloud` provider로 관리 |
| Public entry | DNS, TLS, LB, Ingress/Gateway | 외부 노출 지점을 단일화 |
| DevOps integration | GitLab 또는 Gitea, Jenkins controller | VM/volume/SG는 Terraform, 설치/계정/credential은 운영 절차 |
| Kubernetes platform | namespace, StorageClass, cert-manager, Argo CD, CI runner, Jenkins agent | `kubernetes`, `helm` provider로 관리 |
| Workload | web, api, batch, worker namespace | GitOps manifest로 배포 |
| Observability | metrics, logs, traces, alerting | Helm add-on 또는 운영 관제 연동 |
| Storage | Cinder PV, NAS, Object Storage | DB성 stateful workload는 별도 검증 후 적용 |

## Terraform Blueprint

Foundation 예시는 [infra/blueprints/cloud-native/foundation/examples/dev](../../../infra/blueprints/cloud-native/foundation/examples/dev)에 있다.

Platform 예시는 [infra/blueprints/cloud-native/platform/examples/dev](../../../infra/blueprints/cloud-native/platform/examples/dev)에 있다.

Foundation blueprint가 생성하는 주요 범위:

- VPC, public/private/management routing table, ingress/NKS/devops/management subnet
- public entry/admin security group
- Object Storage container
- 선택형 GitLab/Gitea/Jenkins 연동 서버와 data volume
- NKS cluster, nodegroup

Platform blueprint가 생성하는 주요 범위:

- Kubernetes namespace
- StorageClass
- cert-manager Helm release
- Argo CD Helm release
- CI runner, Jenkins agent, ingress, monitoring 등 추가 Helm add-on 확장 지점

## 운영 기준

- NKS cluster label, addon, node image, subnet, keypair 변경은 재생성 위험을 검토한다.
- Internet Gateway는 `public` routing table에만 연결하고 NKS worker와 DevOps VM은 private/management subnet에 둔다.
- Security Group은 기본 outbound 전체 허용 rule을 삭제하고 entrypoint/admin/devops egress를 명시한다.
- Network ACL과 Flow Log는 요구 사업에서 콘솔/API로 선행 구성한다.
- private worker와 DevOps VM outbound는 NAT Gateway, proxy, Service Gateway 중 하나로 설계한다.
- runner token, registry password, kubeconfig는 Terraform state에 남기지 않는다.
- GitLab/Gitea/Jenkins admin password, runner token, credential은 Terraform state에 남기지 않는다.
- GitLab/Gitea/Jenkins는 NHN Cloud 관리형 리소스가 아니므로 Terraform은 서버/볼륨/보안 그룹까지만 표준화한다.
- workload manifest는 GitOps 저장소에서 관리하고 Terraform은 platform 경계까지만 담당한다.
- Managed DB 또는 stateful workload는 별도 PoC 후 운영 편입한다.

보안 상세 기준은 [NHN Cloud 보안 표준 설계](./security.md)를 따른다.
