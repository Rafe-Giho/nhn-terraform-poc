# NHN Cloud 네트워크 표준 설계

이 문서는 IaaS 3-tier와 클라우드 네이티브 표준안이 공통으로 따르는 NHN Cloud VPC 네트워크 기준을 정의한다.

## 기본 원칙

표준 기본형은 `VPC 1개 + 다중 subnet + 다중 routing table`이다.

NHN Cloud에서 VPC는 논리적으로 격리된 private network다. public/private 구분은 VPC 이름으로 나누는 것이 아니라 subnet이 연결된 routing table과 Internet Gateway 연결 여부로 판단한다.

```text
VPC
  public routing table      -> Internet Gateway 연결
  private routing table     -> Internet Gateway 미연결
  management routing table  -> 운영자 접근, VPN/전용회선/접근통제 경로

  public subnet      -> public routing table
  private subnet     -> private routing table
  management subnet  -> management routing table
```

보안 경계는 routing table만으로 완성되지 않는다. NHN Cloud VPC 내 subnet 간 통신은 기본적으로 가능하므로, 계층 간 접근 제어는 security group, 필요 시 Network ACL/보안 장비/운영 정책으로 함께 통제한다.

## Public VPC와 Private VPC를 나누는 경우

기본 표준에서는 VPC를 둘로 나누지 않는다. 다음 조건이 있을 때만 Public VPC와 Private VPC 분리를 별도 설계로 승격한다.

| 조건 | 판단 |
|---|---|
| 조직/보안 도메인이 완전히 다름 | 프로젝트, 권한, 감사 경계를 VPC 단위로 분리 |
| 인터넷망/업무망/운영망이 VPC 단위 격리를 요구 | Peering, Transit Hub, VPN, Direct Connect 설계 필요 |
| 중앙 보안 VPC 또는 허브 VPC가 이미 존재 | Spoke VPC는 업무 단위로 분리 |
| 규정상 같은 VPC 내 subnet 간 접근 가능성을 허용하지 않음 | 다중 VPC 또는 별도 프로젝트 검토 |

팀원에게 “필요하면 알아서 Public VPC/Private VPC를 만들라”고 두지 않는다. 다중 VPC는 표준 예외 패턴으로 설계 검토 후 적용한다.

## IaaS 3-tier 표준 매핑

| Subnet | Routing table | 배치 리소스 | 기준 |
|---|---|---|---|
| `dmz` | `public` | Public LB, WAF/Reverse Proxy, 승인된 bastion/FIP | 외부 진입점만 배치 |
| `web` | `private` | Web 서버 | DMZ LB/Proxy에서만 접근 |
| `app` | `private` | Internal LB, WAS, batch | Web/Internal LB에서만 접근 |
| `data` | `private` | DB, DB volume, NAS | WAS 계층에서 DB 포트만 허용 |
| `management` | `management` | Bastion, deploy, patch repo | 관리 CIDR/VPN/전용회선에서만 접근 |
| `operations` | `management` | Monitoring, log, backup, 보안 솔루션 | 운영 트래픽 분리 |

## 클라우드 네이티브 표준 매핑

| Subnet | Routing table | 배치 리소스 | 기준 |
|---|---|---|---|
| `ingress` | `public` | Public LB, Ingress/Gateway 진입점 | 외부 서비스 진입점 |
| `nks-a` | `private` | NKS worker node group | workload 실행 |
| `nks-b` | `private` | 추가 NKS worker node group | AZ/역할 분산 |
| `devops` | `management` | GitLab/Gitea/Jenkins VM | 직접 public 노출 금지. 필요 시 LB/WAF 경유 |
| `management` | `management` | 운영자 접근, runner 관리, 점검 서버 | 관리 경로 제한 |

## Terraform 구현 기준

`infra/modules/network`는 다음 범위를 생성한다.

- `nhncloud_networking_vpc_v2`
- `nhncloud_networking_routingtable_v2`
- `nhncloud_networking_routingtable_attach_gateway_v2`
- `nhncloud_networking_vpcsubnet_v2`

`routing_tables` 변수로 public/private/management routing table을 정의하고, `subnets[*].routing_table_key`로 각 subnet을 어떤 routing table에 연결할지 명시한다.

Internet Gateway는 `public` routing table에만 연결한다. private/management routing table에 Internet Gateway를 연결하려면 설계 검토와 승인 후 예외로 처리한다.

## Routing table 표준

| Routing table | 기본 gateway | 배치 subnet | 기준 |
|---|---|---|---|
| `public` | Internet Gateway | `dmz`, `ingress` | 외부에서 시작되는 서비스 진입점만 배치 |
| `private` | 없음 | `web`, `app`, `data`, `nks-a`, `nks-b` | 업무 서버와 NKS worker 기본 위치 |
| `management` | 없음 | `management`, `operations`, `devops` | 운영자 접근, DevOps, 관제/백업/보안 솔루션 |

private/management outbound가 필요하면 routing table에 Internet Gateway를 직접 붙이지 않는다. NAT Gateway, proxy, patch repository, Service Gateway 중 하나를 선택해 설계한다.

| 요구사항 | 표준 경로 |
|---|---|
| OS patch, 외부 vendor repo 접근 | NAT Gateway 또는 사내 proxy |
| Object Storage/NCR private 접근 | Service Gateway |
| Object Storage 파일시스템 마운트 | Storage Gateway 검토 |
| 고객망/온프레미스 연동 | VPN, 전용회선, Transit Hub |
| 운영자 SSH/RDP | Cloud Access, bastion, VPN/전용회선, 접근통제 |

NAT Gateway, Service Gateway, Flow Log, Network ACL은 provider v1.0.8 표준 A 범위에 없으므로 Terraform plan에 나타나지 않을 수 있다. 구축 가이드에서는 콘솔 선행 값과 검증 결과를 별도로 기록한다.

## Security Group과 Network ACL 역할

Security Group은 instance/NIC 단위의 allow 정책이다. Network ACL은 network 앞단에서 allow/deny를 모두 처리하며 SG보다 먼저 적용된다.

| 계층 | Security Group | Network ACL |
|---|---|---|
| 적용 단위 | instance 또는 network interface | network, instance |
| 정책 성격 | 허용 정책 중심 | 허용 또는 차단 |
| 표준 적용 | Terraform으로 생성/관리 | 콘솔/API 선행, 요구 사업만 적용 |
| 검증 | plan JSON과 `policy-check.sh` | 콘솔 설정, Flow Log 결과 |

보안 그룹 표준은 [NHN Cloud 보안 표준 설계](./security.md)를 따른다.

## 검토 기준

plan 검토 시 다음을 확인한다.

- `public` routing table에만 Internet Gateway attachment가 있는지
- DB, NKS worker, DevOps VM이 public routing table에 연결되지 않았는지
- public subnet에는 LB/WAF/승인된 bastion 외 compute가 배치되지 않았는지
- private/management subnet의 외부 통신 요구가 NAT, proxy, service gateway, VPN/전용회선 설계와 충돌하지 않는지
- subnet CIDR이 기존 고객망, VPN, 전용회선, Peering 대역과 겹치지 않는지
- subnet 간 통신은 security group으로 최소 허용만 열었는지
- NACL, Flow Log, NAT Gateway, Service Gateway처럼 Terraform 밖에서 준비한 항목이 실제 리전/프로젝트/VPC와 일치하는지
