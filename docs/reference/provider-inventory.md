# NHN Cloud Provider Inventory

Generated from `./.provider-src/nhncloud/provider.go` at `v1.0.8 / 14725d0`.

이 문서는 provider의 `ResourcesMap`과 `DataSourcesMap`에 등록된 전체 목록이다. Resource type이 등록되어 있다는 뜻이지, NHN Cloud 운영 환경에서 모두 동일하게 권장된다는 뜻은 아니다.

Terraform Registry에서 `nhn-cloud/nhncloud` `v1.0.8` provider를 내려받아 `terraform providers schema -json`으로 대조했다. Registry schema와 이 문서의 resource/data source 이름 차이는 없다.

구분:

- `provider docs`: provider 저장소의 `docs/resources` 또는 `docs/data-sources`에 문서 파일이 있는 항목
- `provider code`: provider 코드에는 등록되어 있으나 docs 파일이 없는 항목
- 운영 우선순위는 scope 문서의 A/B/C 등급을 따른다.

요약:

- Resources: 110개
- Data sources: 53개
- Registry schema diff: resource 0개, data source 0개

표기 기준:

- `Resource`: Terraform state에 등록되어 생성/수정/삭제 생명주기를 관리하는 대상
- `Data source`: 이미 존재하는 리소스를 조회해 ID나 속성을 참조하는 대상
- `Meaning`: 리소스/데이터소스가 의미하는 NHN Cloud 또는 OpenStack 호환 API 객체
- `Source`: provider 저장소 문서화 여부. `provider code` 항목은 운영 적용 전 dev smoke 검증이 필요하다.

## Resource Lifecycle Summary

`v1.0.8` provider source의 각 resource schema에서 `Create`, `Update`, `Delete`, `Importer`, `ForceNew` 여부를 재계산한 기준이다.

| 항목 | 개수 | 의미 |
|---|---:|---|
| 전체 resource | 110 | Terraform resource로 선언 가능한 provider 등록 리소스 |
| `Create` 지원 | 110 | Terraform으로 신규 생성 함수가 있음 |
| `Delete` 지원 | 110 | Terraform destroy 시 삭제 함수가 있음 |
| `Update` 지원 | 85 | 일부 속성을 in-place 변경 가능 |
| `Update` 미지원 | 25 | 변경 시 재생성, detach/attach, 작업 resource 재실행 가능성 큼 |
| `Importer` 지원 | 98 | 기존 콘솔/수동 생성 리소스를 `terraform import`로 state 편입 가능 |
| `Importer` 미지원 | 12 | 기존 리소스 직접 인수는 어렵고 Terraform 생성, data source, 변수 주입 중 선택 필요 |

`ForceNew fields`는 provider schema에서 `ForceNew: true`로 선언된 필드 개수다. 값이 0보다 크면 해당 필드 변경 시 in-place update가 아니라 replace가 발생할 수 있다.

## Resources

| Area | Resource | Meaning | Create | Update | Delete | Import | ForceNew fields | Source |
|---|---|---|---|---|---|---|---:|---|
| blockstorage | `nhncloud_blockstorage_qos_association_v3` | Block Storage volume type에 QoS 정책을 연결하는 리소스 | yes | no | yes | yes | 3 | provider code |
| blockstorage | `nhncloud_blockstorage_qos_v3` | Block Storage QoS 정책/spec을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| blockstorage | `nhncloud_blockstorage_quotaset_v2` | Block Storage v2 프로젝트 quota를 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| blockstorage | `nhncloud_blockstorage_quotaset_v3` | Block Storage v3 프로젝트 quota를 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_v1` | Block Storage v1 volume을 생성/관리하는 리소스 | yes | yes | yes | yes | 7 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_v2` | Block Storage v2 volume을 생성/관리하는 리소스 | yes | yes | yes | yes | 14 | provider docs |
| blockstorage | `nhncloud_blockstorage_volume_v3` | Block Storage v3 volume을 생성/관리하는 리소스 | yes | yes | yes | yes | 13 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_attach_v2` | Block Storage v2 volume attach 정보를 관리하는 리소스 | yes | no | yes | no | 13 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_attach_v3` | Block Storage v3 volume attach 정보를 관리하는 리소스 | yes | no | yes | no | 12 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_type_access_v3` | private volume type의 project 접근 권한을 관리하는 리소스 | yes | no | yes | yes | 3 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_type_v3` | Block Storage volume type을 관리하는 리소스 | yes | yes | yes | yes | 1 | provider code |
| compute | `nhncloud_compute_aggregate_v2` | Compute host aggregate를 관리하는 관리자 성격 리소스 | yes | yes | yes | yes | 1 | provider code |
| compute | `nhncloud_compute_flavor_v2` | VM flavor, 즉 vCPU/Memory/Disk 사양 정의를 관리하는 리소스 | yes | yes | yes | yes | 10 | provider code |
| compute | `nhncloud_compute_flavor_access_v2` | private flavor의 project 접근 권한을 관리하는 리소스 | yes | no | yes | yes | 3 | provider code |
| compute | `nhncloud_compute_instance_v2` | Compute Instance VM을 생성/관리하는 리소스 | yes | yes | yes | yes | 33 | provider docs |
| compute | `nhncloud_compute_interface_attach_v2` | VM에 network port/NIC를 연결하는 리소스 | yes | no | yes | yes | 5 | provider code |
| compute | `nhncloud_compute_keypair_v2` | VM SSH 접속용 key pair를 생성하거나 public key를 등록하는 리소스 | yes | no | yes | yes | 5 | provider docs |
| compute | `nhncloud_compute_secgroup_v2` | legacy Compute security group을 관리하는 리소스 | yes | yes | yes | yes | 1 | provider code |
| compute | `nhncloud_compute_servergroup_v2` | VM affinity/anti-affinity server group을 관리하는 리소스 | yes | yes | yes | yes | 6 | provider code |
| compute | `nhncloud_compute_quotaset_v2` | Compute 프로젝트 quota를 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| compute | `nhncloud_compute_floatingip_v2` | legacy Compute Floating IP를 관리하는 리소스 | yes | no | yes | yes | 2 | provider code |
| compute | `nhncloud_compute_floatingip_associate_v2` | legacy Compute Floating IP를 VM에 연결하는 리소스 | yes | no | yes | yes | 5 | provider code |
| compute | `nhncloud_compute_volume_attach_v2` | Block Storage volume을 VM에 연결하는 리소스 | yes | no | yes | yes | 5 | provider docs |
| kubernetes | `nhncloud_kubernetes_cluster_v1` | NKS Kubernetes cluster를 생성/관리하는 리소스 | yes | no | yes | yes | 13 | provider docs |
| kubernetes | `nhncloud_kubernetes_cluster_resize_v1` | NKS cluster 기본 node 수를 증감하는 작업 리소스 | yes | yes | yes | no | 3 | provider docs |
| kubernetes | `nhncloud_kubernetes_nodegroup_v1` | NKS node group을 생성/관리하는 리소스 | yes | yes | yes | yes | 7 | provider docs |
| kubernetes | `nhncloud_kubernetes_nodegroup_upgrade_v1` | NKS node group version/image upgrade 작업 리소스 | yes | yes | yes | no | 3 | provider docs |
| kubernetes | `nhncloud_kubernetes_clustertemplate_v1` | Kubernetes cluster template 정보를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| db | `nhncloud_db_instance_v1` | DB instance를 생성/관리하는 리소스 | yes | yes | yes | no | 20 | provider code |
| db | `nhncloud_db_user_v1` | DB 사용자 계정을 관리하는 리소스 | yes | no | yes | no | 5 | provider code |
| db | `nhncloud_db_configuration_v1` | DB parameter/configuration set을 관리하는 리소스 | yes | no | yes | no | 10 | provider code |
| db | `nhncloud_db_database_v1` | DB instance 내부 database/schema를 관리하는 리소스 | yes | no | yes | yes | 3 | provider code |
| dns | `nhncloud_dns_recordset_v2` | DNS zone 안의 record set을 관리하는 리소스 | yes | yes | yes | yes | 6 | provider code |
| dns | `nhncloud_dns_zone_v2` | DNS zone을 생성/관리하는 리소스 | yes | yes | yes | yes | 6 | provider code |
| dns | `nhncloud_dns_transfer_request_v2` | DNS zone ownership transfer 요청을 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| dns | `nhncloud_dns_transfer_accept_v2` | DNS zone ownership transfer 수락을 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| fw | `nhncloud_fw_firewall_v1` | FWaaS firewall instance를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| fw | `nhncloud_fw_policy_v1` | Firewall rule 목록과 순서를 묶는 policy 리소스 | yes | yes | yes | yes | 3 | provider code |
| fw | `nhncloud_fw_rule_v1` | Firewall 허용/차단 rule을 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| identity | `nhncloud_identity_endpoint_v3` | Identity service endpoint를 관리하는 Keystone 계열 리소스 | yes | yes | yes | yes | 1 | provider code |
| identity | `nhncloud_identity_project_v3` | Identity project/tenant를 관리하는 Keystone 계열 리소스 | yes | yes | yes | yes | 4 | provider code |
| identity | `nhncloud_identity_role_v3` | Identity role을 관리하는 Keystone 계열 리소스 | yes | yes | yes | yes | 1 | provider code |
| identity | `nhncloud_identity_role_assignment_v3` | user/group/project/domain에 role을 할당하는 리소스 | yes | no | yes | yes | 6 | provider code |
| identity | `nhncloud_identity_service_v3` | Identity service catalog의 service를 관리하는 리소스 | yes | yes | yes | yes | 1 | provider code |
| identity | `nhncloud_identity_user_v3` | Identity user 계정을 관리하는 Keystone 계열 리소스 | yes | yes | yes | yes | 1 | provider code |
| identity | `nhncloud_identity_user_membership_v3` | user의 group membership을 관리하는 리소스 | yes | no | yes | yes | 3 | provider code |
| identity | `nhncloud_identity_group_v3` | Identity group을 관리하는 Keystone 계열 리소스 | yes | yes | yes | yes | 2 | provider code |
| identity | `nhncloud_identity_application_credential_v3` | application credential을 관리하는 Keystone 계열 리소스 | yes | no | yes | yes | 12 | provider code |
| identity | `nhncloud_identity_ec2_credential_v3` | EC2/S3 호환 credential을 관리하는 Keystone 계열 리소스 | yes | no | yes | yes | 6 | provider code |
| images | `nhncloud_images_image_v2` | VM boot image 또는 custom image metadata를 관리하는 리소스 | yes | yes | yes | yes | 7 | provider code |
| images | `nhncloud_images_image_access_v2` | private image의 project 공유 권한을 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| images | `nhncloud_images_image_access_accept_v2` | 공유받은 private image 접근을 수락하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| lb | `nhncloud_lb_member_v1` | legacy LB v1 backend member를 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| lb | `nhncloud_lb_monitor_v1` | legacy LB v1 health monitor를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| lb | `nhncloud_lb_pool_v1` | legacy LB v1 backend pool을 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| lb | `nhncloud_lb_vip_v1` | legacy LB v1 VIP를 관리하는 리소스 | yes | yes | yes | yes | 6 | provider code |
| lb | `nhncloud_lb_loadbalancer_v2` | Load Balancer v2 본체를 생성/관리하는 리소스 | yes | yes | yes | yes | 9 | provider docs |
| lb | `nhncloud_lb_listener_v2` | LB frontend listener, protocol, port를 관리하는 리소스 | yes | yes | yes | yes | 5 | provider docs |
| lb | `nhncloud_lb_pool_v2` | LB backend pool과 balancing method를 관리하는 리소스 | yes | yes | yes | yes | 10 | provider docs |
| lb | `nhncloud_lb_member_v2` | LB backend member 서버 IP/port를 관리하는 리소스 | yes | yes | yes | yes | 7 | provider docs |
| lb | `nhncloud_lb_members_v2` | LB pool의 backend member 목록 전체를 일괄 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| lb | `nhncloud_lb_monitor_v2` | LB backend health check를 관리하는 리소스 | yes | yes | yes | yes | 4 | provider docs |
| lb | `nhncloud_lb_l7policy_v2` | HTTP layer 7 routing policy를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| lb | `nhncloud_lb_l7rule_v2` | L7 policy에 연결되는 path/header/host rule을 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| lb | `nhncloud_lb_quota_v2` | Load Balancer quota를 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| networking | `nhncloud_networking_floatingip_v2` | 공인 Floating IP를 생성/관리하는 리소스 | yes | yes | yes | yes | 7 | provider docs |
| networking | `nhncloud_networking_floatingip_associate_v2` | Floating IP를 port 또는 VM에 연결하는 리소스 | yes | yes | yes | yes | 2 | provider docs |
| networking | `nhncloud_networking_network_v2` | OpenStack Neutron network를 관리하는 generic 리소스 | yes | yes | yes | yes | 5 | provider code |
| networking | `nhncloud_networking_vpc_v2` | NHN Cloud VPC를 생성/관리하는 리소스 | yes | yes | yes | yes | 2 | provider docs |
| networking | `nhncloud_networking_port_v2` | subnet 위의 network port/NIC를 관리하는 리소스 | yes | yes | yes | yes | 7 | provider docs |
| networking | `nhncloud_networking_rbac_policy_v2` | Neutron network RBAC policy를 관리하는 리소스 | yes | yes | yes | yes | 4 | provider code |
| networking | `nhncloud_networking_port_secgroup_associate_v2` | port와 security group 연결을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| networking | `nhncloud_networking_qos_bandwidth_limit_rule_v2` | network QoS bandwidth limit rule을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| networking | `nhncloud_networking_qos_dscp_marking_rule_v2` | network QoS DSCP marking rule을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| networking | `nhncloud_networking_qos_minimum_bandwidth_rule_v2` | network QoS minimum bandwidth rule을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| networking | `nhncloud_networking_qos_policy_v2` | network QoS policy를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| networking | `nhncloud_networking_quota_v2` | Networking quota를 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| networking | `nhncloud_networking_router_v2` | Neutron router를 관리하는 generic 리소스 | yes | yes | yes | yes | 5 | provider code |
| networking | `nhncloud_networking_router_interface_v2` | router와 subnet interface 연결을 관리하는 리소스 | yes | yes | yes | yes | 4 | provider code |
| networking | `nhncloud_networking_router_route_v2` | router static route를 관리하는 리소스 | yes | no | yes | yes | 4 | provider code |
| networking | `nhncloud_networking_secgroup_v2` | VPC security group을 생성/관리하는 리소스 | yes | yes | yes | yes | 3 | provider docs |
| networking | `nhncloud_networking_secgroup_rule_v2` | security group ingress/egress rule을 관리하는 리소스 | yes | no | yes | yes | 11 | provider docs |
| networking | `nhncloud_networking_subnet_v2` | OpenStack Neutron subnet을 관리하는 generic 리소스 | yes | yes | yes | yes | 10 | provider code |
| networking | `nhncloud_networking_vpcsubnet_v2` | NHN Cloud VPC subnet을 생성/관리하는 리소스 | yes | yes | yes | yes | 4 | provider docs |
| networking | `nhncloud_networking_subnet_route_v2` | subnet host route를 관리하는 리소스 | yes | no | yes | yes | 4 | provider code |
| networking | `nhncloud_networking_subnetpool_v2` | subnet pool을 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| networking | `nhncloud_networking_addressscope_v2` | address scope를 관리하는 Neutron 계열 리소스 | yes | yes | yes | yes | 3 | provider code |
| networking | `nhncloud_networking_trunk_v2` | trunk port와 subport를 관리하는 리소스 | yes | yes | yes | no | 3 | provider code |
| networking | `nhncloud_networking_portforwarding_v2` | Floating IP port forwarding rule을 관리하는 리소스 | yes | yes | yes | no | 2 | provider code |
| objectstorage | `nhncloud_objectstorage_container_v1` | Object Storage container/bucket을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| objectstorage | `nhncloud_objectstorage_object_v1` | Object Storage object/file을 관리하는 리소스 | yes | yes | yes | no | 3 | provider code |
| objectstorage | `nhncloud_objectstorage_tempurl_v1` | Object Storage temporary URL을 생성/관리하는 리소스 | yes | no | yes | no | 7 | provider code |
| orchestration | `nhncloud_orchestration_stack_v1` | Heat orchestration stack을 관리하는 리소스 | yes | yes | yes | yes | 2 | provider code |
| vpnaas | `nhncloud_vpnaas_ipsec_policy_v2` | VPNaaS IPsec policy를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| vpnaas | `nhncloud_vpnaas_service_v2` | VPNaaS service를 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| vpnaas | `nhncloud_vpnaas_ike_policy_v2` | VPNaaS IKE policy를 관리하는 리소스 | yes | yes | yes | yes | 3 | provider code |
| vpnaas | `nhncloud_vpnaas_endpoint_group_v2` | VPN endpoint group을 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| vpnaas | `nhncloud_vpnaas_site_connection_v2` | site-to-site IPsec VPN connection을 관리하는 리소스 | yes | yes | yes | yes | 6 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_securityservice_v2` | Shared File System 보안 서비스 설정을 관리하는 리소스 | yes | yes | yes | yes | 1 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_sharenetwork_v2` | Shared File System share network를 관리하는 리소스 | yes | yes | yes | yes | 1 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_share_v2` | Shared File System share를 생성/관리하는 리소스 | yes | yes | yes | yes | 6 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_share_access_v2` | share 접근 권한을 관리하는 리소스 | yes | yes | yes | yes | 5 | provider code |
| keymanager | `nhncloud_keymanager_secret_v1` | Key Manager secret을 저장/관리하는 리소스 | yes | yes | yes | yes | 10 | provider docs |
| keymanager | `nhncloud_keymanager_container_v1` | certificate 등 여러 secret을 묶는 Key Manager container 리소스 | yes | yes | yes | yes | 3 | provider docs |
| keymanager | `nhncloud_keymanager_order_v1` | Key Manager certificate/key order를 관리하는 리소스 | yes | no | yes | yes | 9 | provider code |
| networking | `nhncloud_networking_routingtable_v2` | NHN Cloud VPC routing table을 생성/관리하는 리소스 | yes | yes | yes | yes | 1 | provider docs |
| networking | `nhncloud_networking_routingtable_attach_gateway_v2` | routing table에 gateway를 연결하는 리소스 | yes | no | yes | no | 2 | provider docs |
| nas | `nhncloud_nas_storage_volume_v1` | NHN Cloud NAS volume을 생성/관리하는 리소스 | yes | yes | yes | yes | 4 | provider docs |
| nas | `nhncloud_nas_storage_volume_interface_v1` | NAS volume network interface를 관리하는 리소스 | yes | no | yes | yes | 3 | provider docs |
| nas | `nhncloud_nas_storage_volume_mirror_v1` | NAS volume mirror/replication을 관리하는 리소스 | yes | yes | yes | yes | 7 | provider docs |

## Data Sources

| Area | Data source | Meaning | Source |
|---|---|---|---|
| blockstorage | `nhncloud_blockstorage_availability_zones_v3` | Block Storage 사용 가능 zone 목록을 조회하는 데이터소스 | provider code |
| blockstorage | `nhncloud_blockstorage_snapshot_v2` | Block Storage v2 snapshot 정보를 조회하는 데이터소스 | provider docs |
| blockstorage | `nhncloud_blockstorage_snapshot_v3` | Block Storage v3 snapshot 정보를 조회하는 데이터소스 | provider code |
| blockstorage | `nhncloud_blockstorage_volume_v2` | 기존 Block Storage v2 volume 정보를 조회하는 데이터소스 | provider docs |
| blockstorage | `nhncloud_blockstorage_volume_v3` | 기존 Block Storage v3 volume 정보를 조회하는 데이터소스 | provider code |
| blockstorage | `nhncloud_blockstorage_quotaset_v3` | Block Storage v3 quota 정보를 조회하는 데이터소스 | provider code |
| compute | `nhncloud_compute_aggregate_v2` | Compute host aggregate 정보를 조회하는 데이터소스 | provider code |
| compute | `nhncloud_compute_availability_zones_v2` | Compute availability zone 목록을 조회하는 데이터소스 | provider code |
| compute | `nhncloud_compute_instance_v2` | 기존 Compute Instance VM 정보를 조회하는 데이터소스 | provider code |
| compute | `nhncloud_compute_flavor_v2` | VM flavor ID와 extra spec을 조회하는 데이터소스 | provider docs |
| compute | `nhncloud_compute_hypervisor_v2` | Compute hypervisor 정보를 조회하는 관리자 성격 데이터소스 | provider code |
| compute | `nhncloud_compute_keypair_v2` | 기존 SSH key pair 정보를 조회하는 데이터소스 | provider docs |
| compute | `nhncloud_compute_quotaset_v2` | Compute quota 정보를 조회하는 데이터소스 | provider code |
| compute | `nhncloud_compute_limits_v2` | Compute limit/usage 정보를 조회하는 데이터소스 | provider code |
| kubernetes | `nhncloud_kubernetes_nodegroup_v1` | 기존 NKS node group 정보를 조회하는 데이터소스 | provider docs |
| kubernetes | `nhncloud_kubernetes_cluster_v1` | 기존 NKS cluster 정보를 조회하는 데이터소스 | provider docs |
| kubernetes | `nhncloud_kubernetes_clustertemplate_v1` | Kubernetes cluster template 정보를 조회하는 데이터소스 | provider code |
| dns | `nhncloud_dns_zone_v2` | 기존 DNS zone 정보를 조회하는 데이터소스 | provider code |
| fw | `nhncloud_fw_policy_v1` | 기존 firewall policy 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_role_v3` | Identity role 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_project_v3` | Identity project/tenant 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_user_v3` | Identity user 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_auth_scope_v3` | 현재 인증 token의 scope 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_endpoint_v3` | Identity service endpoint 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_service_v3` | Identity service catalog 정보를 조회하는 데이터소스 | provider code |
| identity | `nhncloud_identity_group_v3` | Identity group 정보를 조회하는 데이터소스 | provider code |
| images | `nhncloud_images_image_v2` | image name/tag 조건으로 VM image ID와 속성을 조회하는 데이터소스 | provider docs |
| images | `nhncloud_images_image_ids_v2` | 조건에 맞는 image ID 목록을 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_addressscope_v2` | Neutron address scope 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_network_v2` | OpenStack Neutron network 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_vpc_v2` | 기존 NHN Cloud VPC ID와 속성을 조회하는 데이터소스 | provider docs |
| networking | `nhncloud_networking_qos_bandwidth_limit_rule_v2` | network QoS bandwidth limit rule 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_qos_dscp_marking_rule_v2` | network QoS DSCP marking rule 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_qos_minimum_bandwidth_rule_v2` | network QoS minimum bandwidth rule 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_qos_policy_v2` | network QoS policy 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_quota_v2` | Networking quota 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_subnet_v2` | OpenStack Neutron subnet 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_vpcsubnet_v2` | 기존 NHN Cloud VPC subnet ID와 속성을 조회하는 데이터소스 | provider docs |
| networking | `nhncloud_networking_subnet_ids_v2` | 조건에 맞는 subnet ID 목록을 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_secgroup_v2` | 기존 security group ID와 속성을 조회하는 데이터소스 | provider docs |
| networking | `nhncloud_networking_subnetpool_v2` | subnet pool 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_floatingip_v2` | 기존 Floating IP ID와 속성을 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_router_v2` | Neutron router 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_port_v2` | network port/NIC 정보를 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_port_ids_v2` | 조건에 맞는 network port ID 목록을 조회하는 데이터소스 | provider code |
| networking | `nhncloud_networking_trunk_v2` | trunk port 정보를 조회하는 데이터소스 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_availability_zones_v2` | Shared File System 사용 가능 zone 목록을 조회하는 데이터소스 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_sharenetwork_v2` | 기존 share network 정보를 조회하는 데이터소스 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_share_v2` | 기존 share 정보를 조회하는 데이터소스 | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_snapshot_v2` | Shared File System snapshot 정보를 조회하는 데이터소스 | provider code |
| keymanager | `nhncloud_keymanager_secret_v1` | 기존 Key Manager secret 정보를 조회하는 데이터소스 | provider docs |
| keymanager | `nhncloud_keymanager_container_v1` | 기존 Key Manager container 정보를 조회하는 데이터소스 | provider docs |
| networking | `nhncloud_networking_routingtable_v2` | 기존 NHN Cloud VPC routing table 정보를 조회하는 데이터소스 | provider docs |
