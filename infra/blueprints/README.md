# Terraform Blueprints

이 디렉터리는 팀 표준 아키텍처를 사업별로 복사해서 시작할 수 있는 Terraform blueprint로 제공한다.

| Blueprint | 경로 | 용도 |
|---|---|---|
| IaaS 3-tier | `iaas-3tier/examples/dev` | Web/WAS/DB VM 전환 구조 |
| Cloud-native foundation | `cloud-native/foundation/examples/dev` | VPC, Object Storage, DevOps 연동 서버, NKS |
| Cloud-native platform | `cloud-native/platform/examples/dev` | NKS 내부 namespace, StorageClass, Helm add-on, CI runner/agent |

`modules/`는 직접 실행하지 않는다. 실행은 항상 blueprint의 example 디렉터리에서 수행한다.

네트워크 blueprint는 Public VPC/Private VPC를 자동으로 둘로 나누지 않는다. 기본 표준은 하나의 VPC에 public/private/management routing table과 역할별 subnet을 구성하는 방식이다.

보안 blueprint는 Security Group 생성 시 자동 outbound 전체 허용 rule을 삭제하고 표준 계층별 egress만 추가한다. NAT Gateway, Service Gateway, Network ACL, Flow Log는 provider 표준 A 범위 밖이므로 콘솔 선행 항목으로 검증한다.
