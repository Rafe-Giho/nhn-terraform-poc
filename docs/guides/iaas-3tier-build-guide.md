# NHN Cloud IaaS 3-tier 구축 가이드

기준 provider: `nhn-cloud/nhncloud` `= 1.0.8`

대상: 클라우드 전환 사업의 VM 기반 Web/WAS/DB 3-tier 구조

아키텍처:

![IaaS 3-tier 표준 아키텍처](../assets/nhn-cloud-iaas-3tier-architecture.svg)

## 1. 적용 범위

이 가이드는 기존 업무시스템을 NHN Cloud Compute 기반으로 이전할 때 사용한다. Web, WAS, DB 계층을 분리하고, 모니터링/로그/백업/보안 솔루션 서버를 운영망에 배치하는 구조를 기준으로 한다.

현재 저장소에는 이 구조의 기본 Terraform 코드가 `infra/blueprints/iaas-3tier/examples/dev`에 구현되어 있다. Web/WAS/DB/운영 서버, public/internal LB, 데이터 볼륨, Object Storage까지 기본 blueprint로 구성한다.

## 2. 권장 stack 구조

```text
infra/
  envs/
    blueprints/iaas-3tier/examples/dev/
      versions.tf
      providers.tf
      variables.tf
      main.tf
      outputs.tf
      terraform.tfvars.example
  modules/
    network/
    security/
    compute/
    load-balancer/
    block-storage/
    object-storage/
```

환경별 운영에서는 이 blueprint를 사업 저장소로 복사한 뒤 `dev`, `stage`, `prod` state를 분리한다.

## 3. 콘솔 선행 확인 값

| 항목 | 필수 | 사용 위치 |
|---|---:|---|
| Tenant/Project ID, API Endpoint, API Password | 예 | provider 인증 |
| Region | 예 | provider 설정 |
| Internet Gateway ID | 조건부 | public subnet routing |
| External network ID | 조건부 | Floating IP, public LB |
| VM image UUID | 예 | Web/WAS/DB/운영 서버 |
| VM flavor UUID | 예 | 서버 사양 |
| Keypair name | 예 | VM SSH 접근 |
| DNS zone/record | 조건부 | 업무 URL 연결 |
| TLS 인증서/Key Manager ref | 조건부 | HTTPS termination |
| DB 라이선스/HA/백업 정책 | 예 | DB 계층 설계 |
| WAF/백신/EDR/보안관제 솔루션 | 조건부 | 운영 솔루션 서버 또는 agent |
| VPN/전용회선/Transit/NAT | 조건부 | 고객망 연동 |
| Quota | 예 | instance, volume, LB, Floating IP 생성 가능성 |

VPN, 전용회선, Transit Hub, NAT Gateway, WAF 같은 항목은 provider 표준 A 범위 밖으로 보고 콘솔 선행 생성 또는 별도 PoC 후 Terraform 편입을 판단한다.

## 4. Terraform 생성/관리 범위

| 영역 | 대표 resource | 기준 |
|---|---|---|
| VPC/Subnet/Routing | `nhncloud_networking_vpc_v2`, `nhncloud_networking_vpcsubnet_v2`, `nhncloud_networking_routingtable_v2` | 표준 모듈 |
| Security Group | `nhncloud_networking_secgroup_v2`, `nhncloud_networking_secgroup_rule_v2` | 계층별 allow rule |
| Floating IP | `nhncloud_networking_floatingip_v2`, `nhncloud_networking_floatingip_associate_v2` | public LB 또는 bastion 제한 |
| Compute | `nhncloud_compute_instance_v2`, `nhncloud_compute_keypair_v2` | Web/WAS/DB/운영 서버 |
| Block Storage | `nhncloud_blockstorage_volume_v2`, `nhncloud_compute_volume_attach_v2` | DB, 로그, 백업, 솔루션 데이터 |
| Load Balancer | `nhncloud_lb_loadbalancer_v2`, `nhncloud_lb_listener_v2`, `nhncloud_lb_pool_v2`, `nhncloud_lb_member_v2`, `nhncloud_lb_monitor_v2` | public/internal LB |
| Object Storage | `nhncloud_objectstorage_container_v1` | 백업, 로그 아카이브, 배포 산출물 |
| NAS | `nhncloud_nas_storage_volume_v1`, `nhncloud_nas_storage_volume_interface_v1` | 공유 파일 저장소 |

Managed DB 리소스는 provider 코드에 있으나 운영 표준 편입 전 별도 PoC가 필요하다.

## 5. 계층별 설계 기준

| 계층 | 기본 구성 | 접근 기준 |
|---|---|---|
| DMZ | Public LB, WAF/Reverse Proxy, Web 서버 | 외부는 80/443만 허용. Web 서버 직접 SSH/RDP 금지 |
| Application | Internal LB, WAS 서버, 배치 서버 | Web 계층 또는 internal LB에서만 WAS 포트 허용 |
| Data | DB 서버, DB volume, 백업 volume, NAS | WAS 계층에서 DB 포트만 허용 |
| Management | Bastion, 배포 서버, 패치 저장소 | 관리 CIDR, VPN, 전용회선에서만 접근 |
| Operations | Monitoring, Log, Backup, 백신/EDR, 취약점 점검 | 업무 트래픽과 운영 트래픽 분리 |

보안 그룹은 deny-all을 전제로 필요한 방향만 허용한다. SSH/RDP는 public CIDR 전체 허용을 금지한다.

## 6. 구축 순서

1. 주소 체계, subnet, routing, 보안 그룹 기준을 확정한다.
2. `network` 모듈로 VPC, routing table, subnet을 만든다.
3. `security` 모듈로 DMZ, Application, Data, Management, Operations 보안 그룹을 만든다.
4. `load-balancer` 모듈로 public LB와 internal LB를 구성한다.
5. `compute` 모듈로 Web/WAS/DB/운영 솔루션 서버를 만든다.
6. `block-storage` 모듈로 DB/log/backup volume을 생성하고 instance에 attach한다.
7. `object-storage`와 NAS를 백업, 로그, 배포 산출물 저장소로 구성한다.
8. OS hardening, agent, monitoring, backup client 설치는 image, Ansible, 솔루션 설치 절차로 수행한다.
9. plan JSON으로 삭제/교체, 공개 인바운드, 계층 간 접근 위반을 검토한다.
10. 사용자 승인 후 dev 최소 구성부터 apply한다.

## 7. 실행 명령

아래 명령은 `infra/blueprints/iaas-3tier/examples/dev` blueprint에서 사용한다.

```bash
cp ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars.example ./infra/blueprints/iaas-3tier/examples/dev/terraform.tfvars

terraform -chdir=infra/blueprints/iaas-3tier/examples/dev init -backend=false
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev fmt -recursive
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev validate
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev plan -out=tfplan
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev show -json tfplan > ./harness/out/iaas-3tier-dev-plan.json
```

적용은 plan 검토와 승인 후 실행한다.

```bash
terraform -chdir=infra/blueprints/iaas-3tier/examples/dev apply tfplan
```

## 8. 검증 항목

| 검증 | 기준 |
|---|---|
| Routing | DMZ, Application, Data, Management subnet routing이 설계와 일치 |
| Security Group | 외부 공개는 LB/WAF만 허용, Web/WAS/DB 직접 public 접근 없음 |
| LB | listener, pool, member, health monitor 정상 |
| Web/WAS | Web에서 WAS 접근, WAS 직접 외부 노출 없음 |
| WAS/DB | WAS에서 DB 포트 접근, 그 외 차단 |
| Volume | DB/log/backup volume attach와 mount 확인 |
| Backup | DB dump, file backup, Object Storage/NAS 저장 확인 |
| Monitoring | Web/WAS/DB/운영 서버 agent 수집 확인 |
| Logging | 시스템/애플리케이션 로그 수집과 보존 경로 확인 |
| Access | bastion 또는 접근통제 경유 접속만 가능 |

## 9. 완료 기준

- VPC/subnet/routing/security group plan 리뷰 완료
- Web/WAS/DB/운영 솔루션 서버 생성 또는 import 완료
- LB health check와 계층별 접근 테스트 완료
- DB backup/restore smoke 완료
- 모니터링, 로그, 백업 agent 수집 확인
- SSH/RDP 접근 경로가 관리망으로 제한됨
- Object Storage/NAS 백업 저장 경로 확인
- 콘솔 선행 리소스와 Terraform 변수 값 대조 완료

## 10. 운영 주의사항

- 운영 `terraform destroy`는 금지한다.
- 운영 VM image/flavor/volume 변경은 재기동 또는 교체 영향을 검토한다.
- LB listener, pool, member 교체는 서비스 중단 가능성을 검토한다.
- 운영 솔루션 license key와 agent token은 Terraform 변수나 state에 저장하지 않는다.
- DB HA, 백업, 감사 정책은 Terraform apply 전에 운영 설계서로 확정한다.
