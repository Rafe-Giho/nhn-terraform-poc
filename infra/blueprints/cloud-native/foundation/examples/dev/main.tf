locals {
  name_prefix = "${var.project_prefix}-${var.environment}"

  common_metadata = {
    project     = var.project_prefix
    environment = var.environment
    managed_by  = "terraform"
  }

  devops_enabled_servers = {
    for key, server in var.devops_servers : key => server
    if try(server.enabled, true)
  }

  devops_service_ports = distinct(flatten([
    for server in values(local.devops_enabled_servers) : try(server.ingress_ports, [])
  ]))

  security_groups = {
    public_entrypoint = {
      name        = "${local.name_prefix}-public-entrypoint-sg"
      description = "Public entrypoint security group for external HTTP/HTTPS traffic."
      rules = concat(
        flatten([
          for port in var.entrypoint_backend_ports : [
            {
              direction        = "egress"
              ethertype        = "IPv4"
              protocol         = "tcp"
              port_range_min   = port
              port_range_max   = port
              remote_ip_prefix = var.vpc_cidr
              description      = "entrypoint to private service port ${port}"
            }
          ]
        ]),
        [
          for cidr in var.public_ingress_cidrs : {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = 80
            port_range_max   = 80
            remote_ip_prefix = cidr
            description      = "public http"
          }
        ],
        [
          for cidr in var.public_ingress_cidrs : {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = 443
            port_range_max   = 443
            remote_ip_prefix = cidr
            description      = "public https"
          }
        ],
        try(var.extra_security_group_rules["public_entrypoint"], [])
      )
    }

    platform_admin = {
      name        = "${local.name_prefix}-platform-admin-sg"
      description = "Platform administration security group. Admin ingress is restricted to approved CIDRs."
      rules = concat(
        flatten([
          for port in var.platform_admin_egress_ports : [
            {
              direction        = "egress"
              ethertype        = "IPv4"
              protocol         = "tcp"
              port_range_min   = port
              port_range_max   = port
              remote_ip_prefix = var.vpc_cidr
              description      = "platform admin to vpc port ${port}"
            }
          ]
        ]),
        [
          for cidr in var.management_cidrs : {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = 22
            port_range_max   = 22
            remote_ip_prefix = cidr
            description      = "ssh from management cidr"
          }
        ],
        try(var.extra_security_group_rules["platform_admin"], [])
      )
    }

    devops_tools = {
      name        = "${local.name_prefix}-devops-tools-sg"
      description = "DevOps integration server security group for GitLab/Gitea/Jenkins VM hosts."
      rules = concat(
        flatten([
          for port in var.devops_internal_egress_ports : [
            {
              direction        = "egress"
              ethertype        = "IPv4"
              protocol         = "tcp"
              port_range_min   = port
              port_range_max   = port
              remote_ip_prefix = var.vpc_cidr
              description      = "devops to vpc port ${port}"
            }
          ]
        ]),
        [
          for cidr in var.management_cidrs : {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = 22
            port_range_max   = 22
            remote_ip_prefix = cidr
            description      = "ssh from management cidr"
          }
        ],
        flatten([
          for port in local.devops_service_ports : [
            for cidr in var.devops_access_cidrs : {
              direction        = "ingress"
              ethertype        = "IPv4"
              protocol         = "tcp"
              port_range_min   = port
              port_range_max   = port
              remote_ip_prefix = cidr
              description      = "devops service port ${port}"
            }
          ]
        ]),
        try(var.extra_security_group_rules["devops_tools"], [])
      )
    }
  }

  nks_labels = {
    kube_tag                      = var.nks_kubernetes_version
    availability_zone             = var.nks_availability_zone
    boot_volume_size              = tostring(var.nks_boot_volume_size)
    boot_volume_type              = var.nks_boot_volume_type
    ca_enable                     = tostring(var.nks_autoscaler.enabled)
    ca_max_node_count             = tostring(var.nks_autoscaler.max_node_count)
    ca_min_node_count             = tostring(var.nks_autoscaler.min_node_count)
    ca_scale_down_delay_after_add = tostring(var.nks_autoscaler.scale_down_delay_after_add)
    ca_scale_down_enable          = tostring(var.nks_autoscaler.scale_down_enabled)
    ca_scale_down_unneeded_time   = tostring(var.nks_autoscaler.scale_down_unneeded_time)
    ca_scale_down_util_thresh     = tostring(var.nks_autoscaler.scale_down_util_threshold)
    cert_manager_api              = "True"
    clusterautoscale              = "nodegroupfeature"
    external_network_id           = var.nks_external_network_id
    external_subnet_id_list       = var.nks_external_subnet_id_list
    master_lb_floating_ip_enabled = "true"
    node_image                    = var.nks_node_image_id
    strict_sg_rules               = "false"
  }
}

module "network" {
  source = "../../../../../modules/network"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
  routing_tables = {
    public = {
      internet_gateway_id = var.public_internet_gateway_id
    }
    private    = {}
    management = {}
  }
  default_routing_table_key = "private"
  subnets                   = var.subnets
}

module "security" {
  source = "../../../../../modules/security"

  security_groups = local.security_groups
}

module "object_storage" {
  source = "../../../../../modules/object-storage"

  name_prefix = local.name_prefix
  containers  = var.object_storage_containers
  metadata    = local.common_metadata
}

module "devops_compute" {
  source = "../../../../../modules/compute"

  instances = {
    for key, server in local.devops_enabled_servers : key => {
      name                       = coalesce(try(server.name, null), "${local.name_prefix}-${key}")
      flavor_id                  = server.flavor_id
      key_pair                   = coalesce(try(server.key_pair, null), var.nks_keypair_name)
      availability_zone          = try(server.availability_zone, null)
      network_id                 = module.network.vpc_id
      subnet_id                  = module.network.subnet_ids[coalesce(try(server.subnet_key, null), "devops")]
      fixed_ip_v4                = try(server.fixed_ip_v4, null)
      security_groups            = [module.security.security_group_names["devops_tools"]]
      boot_image_id              = server.image_id
      boot_volume_size           = try(server.boot_volume_size, 80)
      boot_delete_on_termination = try(server.boot_delete_on_termination, false)
    }
  }
}

module "devops_block_storage" {
  source = "../../../../../modules/block-storage"

  volumes = {
    for key, server in local.devops_enabled_servers : key => {
      name              = format("%s-data", coalesce(try(server.name, null), format("%s-%s", local.name_prefix, key)))
      size              = try(server.data_volume_size, 0)
      availability_zone = try(server.availability_zone, null)
      volume_type       = try(server.data_volume_type, "General HDD")
      description       = "Data volume for ${try(server.role, key)} DevOps integration server"
    }
    if try(server.data_volume_size, 0) > 0
  }

  instance_ids = module.devops_compute.instance_ids
  attachments = {
    for key, server in local.devops_enabled_servers : key => {
      volume_key   = key
      instance_key = key
    }
    if try(server.data_volume_size, 0) > 0
  }
}

module "nks" {
  source = "../../../../../modules/nks"

  cluster = {
    name                = "${local.name_prefix}-${var.nks_cluster_name}"
    cluster_template_id = "iaas_console"
    fixed_network       = module.network.vpc_id
    fixed_subnet        = module.network.subnet_ids[var.nks_subnet_key]
    flavor_id           = var.nks_node_flavor_id
    keypair             = var.nks_keypair_name
    node_count          = var.nks_node_count
    labels              = local.nks_labels
    addons = [
      {
        name    = "calico"
        version = var.nks_calico_version
        options = {
          mode = var.nks_calico_mode
        }
      },
      {
        name    = "coredns"
        version = var.nks_coredns_version
      }
    ]
  }

  nodegroups = var.additional_nodegroups
}
