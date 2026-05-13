# NHN Cloud Provider Inventory

Generated from `.\.provider-src\nhncloud\provider.go` at `v1.0.8 / 14725d0`.

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

## Resources

| Area | Resource | Source |
|---|---|---|
| blockstorage | `nhncloud_blockstorage_qos_association_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_qos_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_quotaset_v2` | provider code |
| blockstorage | `nhncloud_blockstorage_quotaset_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_v1` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_v2` | provider docs |
| blockstorage | `nhncloud_blockstorage_volume_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_attach_v2` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_attach_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_type_access_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_type_v3` | provider code |
| compute | `nhncloud_compute_aggregate_v2` | provider code |
| compute | `nhncloud_compute_flavor_v2` | provider code |
| compute | `nhncloud_compute_flavor_access_v2` | provider code |
| compute | `nhncloud_compute_instance_v2` | provider docs |
| compute | `nhncloud_compute_interface_attach_v2` | provider code |
| compute | `nhncloud_compute_keypair_v2` | provider docs |
| compute | `nhncloud_compute_secgroup_v2` | provider code |
| compute | `nhncloud_compute_servergroup_v2` | provider code |
| compute | `nhncloud_compute_quotaset_v2` | provider code |
| compute | `nhncloud_compute_floatingip_v2` | provider code |
| compute | `nhncloud_compute_floatingip_associate_v2` | provider code |
| compute | `nhncloud_compute_volume_attach_v2` | provider docs |
| kubernetes | `nhncloud_kubernetes_cluster_v1` | provider docs |
| kubernetes | `nhncloud_kubernetes_cluster_resize_v1` | provider docs |
| kubernetes | `nhncloud_kubernetes_nodegroup_v1` | provider docs |
| kubernetes | `nhncloud_kubernetes_nodegroup_upgrade_v1` | provider docs |
| kubernetes | `nhncloud_kubernetes_clustertemplate_v1` | provider code |
| db | `nhncloud_db_instance_v1` | provider code |
| db | `nhncloud_db_user_v1` | provider code |
| db | `nhncloud_db_configuration_v1` | provider code |
| db | `nhncloud_db_database_v1` | provider code |
| dns | `nhncloud_dns_recordset_v2` | provider code |
| dns | `nhncloud_dns_zone_v2` | provider code |
| dns | `nhncloud_dns_transfer_request_v2` | provider code |
| dns | `nhncloud_dns_transfer_accept_v2` | provider code |
| fw | `nhncloud_fw_firewall_v1` | provider code |
| fw | `nhncloud_fw_policy_v1` | provider code |
| fw | `nhncloud_fw_rule_v1` | provider code |
| identity | `nhncloud_identity_endpoint_v3` | provider code |
| identity | `nhncloud_identity_project_v3` | provider code |
| identity | `nhncloud_identity_role_v3` | provider code |
| identity | `nhncloud_identity_role_assignment_v3` | provider code |
| identity | `nhncloud_identity_service_v3` | provider code |
| identity | `nhncloud_identity_user_v3` | provider code |
| identity | `nhncloud_identity_user_membership_v3` | provider code |
| identity | `nhncloud_identity_group_v3` | provider code |
| identity | `nhncloud_identity_application_credential_v3` | provider code |
| identity | `nhncloud_identity_ec2_credential_v3` | provider code |
| images | `nhncloud_images_image_v2` | provider code |
| images | `nhncloud_images_image_access_v2` | provider code |
| images | `nhncloud_images_image_access_accept_v2` | provider code |
| lb | `nhncloud_lb_member_v1` | provider code |
| lb | `nhncloud_lb_monitor_v1` | provider code |
| lb | `nhncloud_lb_pool_v1` | provider code |
| lb | `nhncloud_lb_vip_v1` | provider code |
| lb | `nhncloud_lb_loadbalancer_v2` | provider docs |
| lb | `nhncloud_lb_listener_v2` | provider docs |
| lb | `nhncloud_lb_pool_v2` | provider docs |
| lb | `nhncloud_lb_member_v2` | provider docs |
| lb | `nhncloud_lb_members_v2` | provider code |
| lb | `nhncloud_lb_monitor_v2` | provider docs |
| lb | `nhncloud_lb_l7policy_v2` | provider code |
| lb | `nhncloud_lb_l7rule_v2` | provider code |
| lb | `nhncloud_lb_quota_v2` | provider code |
| networking | `nhncloud_networking_floatingip_v2` | provider docs |
| networking | `nhncloud_networking_floatingip_associate_v2` | provider docs |
| networking | `nhncloud_networking_network_v2` | provider code |
| networking | `nhncloud_networking_vpc_v2` | provider docs |
| networking | `nhncloud_networking_port_v2` | provider docs |
| networking | `nhncloud_networking_rbac_policy_v2` | provider code |
| networking | `nhncloud_networking_port_secgroup_associate_v2` | provider code |
| networking | `nhncloud_networking_qos_bandwidth_limit_rule_v2` | provider code |
| networking | `nhncloud_networking_qos_dscp_marking_rule_v2` | provider code |
| networking | `nhncloud_networking_qos_minimum_bandwidth_rule_v2` | provider code |
| networking | `nhncloud_networking_qos_policy_v2` | provider code |
| networking | `nhncloud_networking_quota_v2` | provider code |
| networking | `nhncloud_networking_router_v2` | provider code |
| networking | `nhncloud_networking_router_interface_v2` | provider code |
| networking | `nhncloud_networking_router_route_v2` | provider code |
| networking | `nhncloud_networking_secgroup_v2` | provider docs |
| networking | `nhncloud_networking_secgroup_rule_v2` | provider docs |
| networking | `nhncloud_networking_subnet_v2` | provider code |
| networking | `nhncloud_networking_vpcsubnet_v2` | provider docs |
| networking | `nhncloud_networking_subnet_route_v2` | provider code |
| networking | `nhncloud_networking_subnetpool_v2` | provider code |
| networking | `nhncloud_networking_addressscope_v2` | provider code |
| networking | `nhncloud_networking_trunk_v2` | provider code |
| networking | `nhncloud_networking_portforwarding_v2` | provider code |
| objectstorage | `nhncloud_objectstorage_container_v1` | provider code |
| objectstorage | `nhncloud_objectstorage_object_v1` | provider code |
| objectstorage | `nhncloud_objectstorage_tempurl_v1` | provider code |
| orchestration | `nhncloud_orchestration_stack_v1` | provider code |
| vpnaas | `nhncloud_vpnaas_ipsec_policy_v2` | provider code |
| vpnaas | `nhncloud_vpnaas_service_v2` | provider code |
| vpnaas | `nhncloud_vpnaas_ike_policy_v2` | provider code |
| vpnaas | `nhncloud_vpnaas_endpoint_group_v2` | provider code |
| vpnaas | `nhncloud_vpnaas_site_connection_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_securityservice_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_sharenetwork_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_share_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_share_access_v2` | provider code |
| keymanager | `nhncloud_keymanager_secret_v1` | provider docs |
| keymanager | `nhncloud_keymanager_container_v1` | provider docs |
| keymanager | `nhncloud_keymanager_order_v1` | provider code |
| networking | `nhncloud_networking_routingtable_v2` | provider docs |
| networking | `nhncloud_networking_routingtable_attach_gateway_v2` | provider docs |
| nas | `nhncloud_nas_storage_volume_v1` | provider docs |
| nas | `nhncloud_nas_storage_volume_interface_v1` | provider docs |
| nas | `nhncloud_nas_storage_volume_mirror_v1` | provider docs |

## Data Sources

| Area | Data source | Source |
|---|---|---|
| blockstorage | `nhncloud_blockstorage_availability_zones_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_snapshot_v2` | provider docs |
| blockstorage | `nhncloud_blockstorage_snapshot_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_volume_v2` | provider docs |
| blockstorage | `nhncloud_blockstorage_volume_v3` | provider code |
| blockstorage | `nhncloud_blockstorage_quotaset_v3` | provider code |
| compute | `nhncloud_compute_aggregate_v2` | provider code |
| compute | `nhncloud_compute_availability_zones_v2` | provider code |
| compute | `nhncloud_compute_instance_v2` | provider code |
| compute | `nhncloud_compute_flavor_v2` | provider docs |
| compute | `nhncloud_compute_hypervisor_v2` | provider code |
| compute | `nhncloud_compute_keypair_v2` | provider docs |
| compute | `nhncloud_compute_quotaset_v2` | provider code |
| compute | `nhncloud_compute_limits_v2` | provider code |
| kubernetes | `nhncloud_kubernetes_nodegroup_v1` | provider docs |
| kubernetes | `nhncloud_kubernetes_cluster_v1` | provider docs |
| kubernetes | `nhncloud_kubernetes_clustertemplate_v1` | provider code |
| dns | `nhncloud_dns_zone_v2` | provider code |
| fw | `nhncloud_fw_policy_v1` | provider code |
| identity | `nhncloud_identity_role_v3` | provider code |
| identity | `nhncloud_identity_project_v3` | provider code |
| identity | `nhncloud_identity_user_v3` | provider code |
| identity | `nhncloud_identity_auth_scope_v3` | provider code |
| identity | `nhncloud_identity_endpoint_v3` | provider code |
| identity | `nhncloud_identity_service_v3` | provider code |
| identity | `nhncloud_identity_group_v3` | provider code |
| images | `nhncloud_images_image_v2` | provider docs |
| images | `nhncloud_images_image_ids_v2` | provider code |
| networking | `nhncloud_networking_addressscope_v2` | provider code |
| networking | `nhncloud_networking_network_v2` | provider code |
| networking | `nhncloud_networking_vpc_v2` | provider docs |
| networking | `nhncloud_networking_qos_bandwidth_limit_rule_v2` | provider code |
| networking | `nhncloud_networking_qos_dscp_marking_rule_v2` | provider code |
| networking | `nhncloud_networking_qos_minimum_bandwidth_rule_v2` | provider code |
| networking | `nhncloud_networking_qos_policy_v2` | provider code |
| networking | `nhncloud_networking_quota_v2` | provider code |
| networking | `nhncloud_networking_subnet_v2` | provider code |
| networking | `nhncloud_networking_vpcsubnet_v2` | provider docs |
| networking | `nhncloud_networking_subnet_ids_v2` | provider code |
| networking | `nhncloud_networking_secgroup_v2` | provider docs |
| networking | `nhncloud_networking_subnetpool_v2` | provider code |
| networking | `nhncloud_networking_floatingip_v2` | provider code |
| networking | `nhncloud_networking_router_v2` | provider code |
| networking | `nhncloud_networking_port_v2` | provider code |
| networking | `nhncloud_networking_port_ids_v2` | provider code |
| networking | `nhncloud_networking_trunk_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_availability_zones_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_sharenetwork_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_share_v2` | provider code |
| sharedfilesystem | `nhncloud_sharedfilesystem_snapshot_v2` | provider code |
| keymanager | `nhncloud_keymanager_secret_v1` | provider docs |
| keymanager | `nhncloud_keymanager_container_v1` | provider docs |
| networking | `nhncloud_networking_routingtable_v2` | provider docs |
