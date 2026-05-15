# NHN Cloud IaaS 3-tier 표준 아키텍처

이 문서는 팀 표준 IaaS 3-tier 전환 설계를 정의한다. 실행 절차는 [IaaS 3-tier 구축 가이드](../../guides/iaas-3tier-build-guide.md)를 따른다.

![IaaS 3-tier 표준 아키텍처](../../assets/nhn-cloud-iaas-3tier-architecture.svg)

## 설계 기준

| 계층 | 기본 구성 | 접근 기준 |
|---|---|---|
| DMZ | Public LB, WAF/Reverse Proxy, 승인된 bastion | `public` routing table. 외부는 LB/WAF로만 진입 |
| Web | Web 서버 | `private` routing table. DMZ LB/Proxy에서만 접근 |
| Application | Internal LB, WAS 서버, 배치 서버 | `private` routing table. Web 계층 또는 internal LB에서만 접근 |
| Data | DB 서버, DB volume, 백업 volume, NAS | `private` routing table. WAS 계층에서 필요한 DB 포트만 허용 |
| Management | Bastion, 배포 서버, 패치 저장소 | `management` routing table. 관리 CIDR, VPN, 전용회선 경유 접근 |
| Operations | Monitoring, Log, Backup, 백신/EDR, 취약점 점검 | `management` routing table. 업무 트래픽과 운영 트래픽 분리 |

## Terraform Blueprint

실행 가능한 예시는 [infra/blueprints/iaas-3tier/examples/dev](../../../infra/blueprints/iaas-3tier/examples/dev)에 있다.

이 blueprint가 생성하는 주요 범위:

- VPC, public/private/management routing table, 역할별 subnet
- 계층별 security group
- Web/WAS/DB/운영 서버 compute instance
- DB/운영 서버용 block storage와 attachment
- public/internal load balancer, listener, pool, member, health monitor
- Object Storage container

## 운영 기준

- SSH/RDP는 public CIDR 전체에 열지 않는다.
- Internet Gateway는 `public` routing table에만 연결한다.
- Web/WAS/DB/운영 솔루션 서버는 public routing table에 직접 연결하지 않는다.
- Security Group은 기본 outbound 전체 허용 rule을 삭제하고 계층별 egress를 명시한다.
- Network ACL과 Flow Log는 요구 사업에서 콘솔/API로 선행 구성한다.
- private/management outbound는 NAT Gateway, proxy, patch repository, Service Gateway 중 하나로 설계한다.
- 운영 DB, 대용량 volume, NAS, dedicated LB는 별도 승인 후 적용한다.
- WAF, VPN, Transit Hub, NAT Gateway, Service Gateway는 콘솔 선행 생성 또는 별도 PoC 후 편입한다.
- 운영 솔루션 license key와 agent token은 Terraform state에 남기지 않는다.

보안 상세 기준은 [NHN Cloud 보안 표준 설계](./security.md)를 따른다.
