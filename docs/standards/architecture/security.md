# NHN Cloud 보안 표준 설계

이 문서는 IaaS 3-tier와 클라우드 네이티브 표준안이 공통으로 따르는 보안 기준을 정의한다. 네트워크 구조는 [NHN Cloud 네트워크 표준 설계](./network.md)를 기준으로 한다.

## 설계 원칙

NHN Cloud의 기본 보안 경계는 VPC, routing table, security group, Network ACL, 운영 접근 통제의 조합으로 만든다.

| 기준 | 표준 |
|---|---|
| 공개 진입점 | Public LB, Ingress/Gateway, WAF/Reverse Proxy만 허용 |
| 서버 직접 공개 | 금지. 예외는 승인된 bastion/Floating IP만 허용 |
| subnet 분리 | public, private, management routing table로 분리 |
| 계층 접근 | Security Group allow rule로 최소 허용 |
| NACL | Terraform provider 표준 범위 밖. 요구 사업은 콘솔/API로 별도 구성 |
| Flow Log | Terraform provider 표준 범위 밖. 운영/보안 요구 사업은 콘솔에서 활성화 |
| outbound | 기본 all egress 삭제 후 필요한 목적지/포트만 명시 |
| 민감값 | Terraform state에 password, token, license key, kubeconfig 저장 금지 |

## NHN Cloud 기능 기준

| 기능 | NHN Cloud 역할 | Terraform 표준 처리 |
|---|---|---|
| Security Groups | instance 또는 network interface 단위 allow rule | `nhncloud_networking_secgroup_v2`, `nhncloud_networking_secgroup_rule_v2` |
| 기본 egress rule | Security Group 생성 시 전체 outbound rule이 자동 추가됨 | `delete_default_rules = true`를 기본 적용하고 필요한 egress만 생성 |
| Network ACL | network/instance 앞단의 allow/deny 제어. SG보다 먼저 적용 | provider v1.0.8 표준 A 범위 밖. 콘솔/API 선행 |
| Flow Log | network interface 트래픽 통계와 allow/block 확인 | provider v1.0.8 표준 A 범위 밖. Object Storage 대상 콘솔 선행 |
| NAT Gateway | private subnet outbound internet 경로 | provider v1.0.8 표준 A 범위 밖. 콘솔 선행 후 routing 설계 반영 |
| Service Gateway | Object Storage/NCR 등 NHN Cloud 서비스 private 접근 | provider v1.0.8 표준 A 범위 밖. 콘솔 선행 |
| Load Balancer IP Access Control | LB 진입 IP allow/deny | provider 표준 A 범위 밖. 필요 시 콘솔/운영 정책 |
| Security Advisor/Monitoring | 설정 점검, 보안관제 | Terraform 생성 대상이 아니라 운영 통제 항목 |

출처 기준:

- [VPC 개요](https://docs.nhncloud.com/ko/Network/VPC/ko/overview/): subnet, routing table, gateway를 구성하고 security group으로 보호한다.
- [Security Groups 콘솔 가이드](https://docs.nhncloud.com/ko/Network/Security%20Groups/ko/console-guide/): Security Group 생성 시 outbound 전체 허용 rule이 자동 추가되며, rule은 ingress/egress, protocol, port, remote CIDR/security group을 기준으로 동작한다.
- [Network ACL 개요](https://docs.nhncloud.com/ko/Network/Network%20ACL/ko/overview/): Network ACL은 SG보다 먼저 적용되며 allow/deny 정책을 둘 수 있다.
- [Flow Log 개요](https://docs.nhncloud.com/ko/Network/Flow%20Log/ko/overview/): network interface의 허용/차단 트래픽 통계를 Object Storage에 저장할 수 있다.
- [NAT Gateway 개요](https://docs.nhncloud.com/ko/Network/NAT%20Gateway/ko/overview/): Internet Gateway가 연결되지 않은 instance의 outbound internet access를 제공하지만 inbound 시작 트래픽은 차단한다.
- [Service Gateway 개요](https://docs.nhncloud.com/ko/Network/Service%20Gateway/ko/overview/): VPC 안의 VM이 Object Storage/NCR 같은 NHN Cloud 서비스를 internet 경유 없이 접근하게 한다.

## IaaS 3-tier Security Group 표준

| SG | Ingress | Egress | 비고 |
|---|---|---|---|
| `public_lb` | `public_ingress_cidrs`에서 TCP 80/443 | `web` subnet TCP `web_port` | 외부 공개는 여기로 집중 |
| `internal_lb` | `web` subnet에서 TCP `was_port` | `app` subnet TCP `was_port` | Web/WAS 사이 private load balancing |
| `web` | `dmz` subnet에서 TCP `web_port`, 관리 CIDR에서 SSH | `app` subnet TCP `was_port`, `operations` subnet UDP `log_ingress_port` | Web 서버는 public routing table에 두지 않음 |
| `was` | internal LB subnet에서 TCP `was_port`, 관리 CIDR에서 SSH | `data` subnet TCP `db_port`, `operations` subnet UDP `log_ingress_port` | WAS는 DB 포트 외 data subnet 접근 금지 |
| `db` | `app` subnet에서 TCP `db_port`, 관리 CIDR에서 SSH | `operations` subnet UDP `log_ingress_port` | DB 백업은 backup server/Object Storage 경유 |
| `management` | 관리 CIDR에서 SSH | VPC CIDR의 `management_egress_ports` | bastion/deploy/patch repo |
| `operations` | VPC CIDR에서 UDP `log_ingress_port`, 관리 CIDR에서 SSH | VPC CIDR의 `operations_polling_ports` | monitoring/log/backup/security tooling |

예외 rule은 `extra_security_group_rules`로만 추가한다. 이 값은 plan 리뷰에서 사유, 출발지, 목적지, 포트, 만료일을 확인한다.

## 클라우드 네이티브 Security Group 표준

| SG | Ingress | Egress | 비고 |
|---|---|---|---|
| `public_entrypoint` | `public_ingress_cidrs`에서 TCP 80/443 | VPC CIDR의 `entrypoint_backend_ports` | 외부 LB/Ingress 진입점 |
| `platform_admin` | 관리 CIDR에서 SSH | VPC CIDR의 `platform_admin_egress_ports` | 점검/운영 호스트용 |
| `devops_tools` | 관리 CIDR에서 SSH, `devops_access_cidrs`에서 Git/Jenkins 포트 | VPC CIDR의 `devops_internal_egress_ports` | GitLab/Gitea/Jenkins VM |
| NKS worker | NKS가 생성/관리하는 node security group | NKS cluster/add-on 요구사항 | `strict_sg_rules` 변경은 별도 PoC 후 적용 |
| Kubernetes workload | Kubernetes NetworkPolicy, Ingress/Gateway policy | Namespace/Service 기준 | Terraform foundation과 GitOps 경계를 분리 |

GitLab/Gitea/Jenkins admin password, runner token, registry credential은 Terraform 변수로 넣지 않는다. VM, volume, SG까지만 Terraform이 만들고 애플리케이션 설치/계정/credential은 별도 운영 절차로 관리한다.

## Network ACL 표준

Network ACL은 SG보다 앞에서 동작하는 coarse-grained 제어다. provider v1.0.8 표준 A 범위에 없으므로 요구 사업에서 콘솔/API로 구성한다.

| 대상 network | 기본 방향 |
|---|---|
| DMZ/Public | TCP 80/443 ingress, 승인된 관리 CIDR만 SSH/RDP. 그 외 deny |
| Private Web/App | VPC 내부 필요 구간만 allow, internet source deny |
| Data | App subnet의 DB 포트만 allow, 관리 CIDR은 승인 포트만 allow |
| Management/Operations | 관리 CIDR/VPN/전용회선만 allow |

NACL rule은 source와 destination을 쌍으로 검토한다. 운영 적용 전에는 Flow Log의 block/allow 결과로 오탐 차단 가능성을 확인한다.

## Outbound 표준

private/management subnet에서 외부로 나가는 통신은 다음 중 하나로 설계한다.

| 방식 | 기준 |
|---|---|
| NAT Gateway | OS patch, 외부 API 호출이 필요한 private VM/NKS node에 사용. 콘솔 선행 |
| Proxy/Patch repo | outbound 통제를 강하게 요구하는 업무에 사용 |
| Service Gateway | Object Storage/NCR 같은 NHN Cloud 서비스 private 접근에 사용 |
| Storage Gateway | Object Storage를 NFS 형태로 붙여야 할 때 검토 |

임시 `0.0.0.0/0` egress는 dev smoke에서만 허용하고 운영에는 남기지 않는다. 운영 plan에서 open egress가 보이면 사유와 만료일이 있어야 한다.

## 운영 보안 항목

| 항목 | 표준 |
|---|---|
| 계정/권한 | Terraform 실행 계정은 프로젝트 단위 최소 권한. 공유 계정 금지 |
| Remote state | Object Storage/S3 backend 사용 시 접근 key는 CI secret 또는 로컬 환경 변수 |
| Drift | 운영은 `terraform plan -refresh-only`로 점검하고 콘솔 수동 변경은 사유 기록 |
| Flow Log | public entry, bastion, DB, NKS worker, DevOps VM NIC 우선 활성화 |
| 보안관제 | Security Monitoring 또는 고객 관제 연동 경로 확정 |
| 취약점/백신/EDR | agent 설치는 image/Ansible/운영 절차로 관리. license key는 state 제외 |
| 백업 | DB dump, volume snapshot, Object Storage/NAS 보존 정책과 복구 테스트 포함 |
| DNS/TLS | DNS zone/record와 TLS 인증서 생명주기, 만료 알림을 운영 항목으로 관리 |
| Quota | instance, volume, LB, Floating IP, NKS node quota를 apply 전에 확인 |

## Plan 검증 게이트

적용 전 plan JSON에서 반드시 확인한다.

| 항목 | 차단 기준 |
|---|---|
| SG ingress | `0.0.0.0/0`은 TCP 80/443 외 차단 |
| SSH/RDP | public CIDR 공개 차단 |
| SG egress | `0.0.0.0/0` 전체 outbound는 운영 차단 |
| Routing table | Internet Gateway는 public routing table만 허용 |
| Floating IP | public LB 또는 승인된 bastion 외 사용 차단 |
| NKS | cluster replace, node image/version 변경은 별도 승인 |
| Object Storage | container delete는 별도 승인 |
| 민감값 | plan/state에 password, token, kubeconfig, license key 포함 금지 |

자동 점검은 `harness/scripts/policy-check.sh`를 사용한다.

```bash
./harness/scripts/plan-json.sh --terraform-root ./projects/customer-a/iaas-3tier/dev/terraform
./harness/scripts/policy-check.sh --plan-json ./harness/out/tfplan.json
```

자동 점검은 최소 기준이다. NACL, NAT Gateway, Service Gateway, Flow Log, WAF, 보안관제 연동은 Terraform plan에 나타나지 않을 수 있으므로 콘솔 체크리스트로 별도 검증한다.
