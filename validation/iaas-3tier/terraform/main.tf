locals {
  name_prefix = "${var.project_prefix}-${var.environment}"

  common_metadata = {
    project     = var.project_prefix
    environment = var.environment
    managed_by  = "terraform"
    standard    = "iaas-3tier"
  }

  egress_all = [
    {
      direction        = "egress"
      ethertype        = "IPv4"
      protocol         = null
      port_range_min   = null
      port_range_max   = null
      remote_ip_prefix = "0.0.0.0/0"
      description      = "allow outbound"
    }
  ]

  security_groups = {
    public_lb = {
      name = "${local.name_prefix}-public-lb-sg"
      rules = concat(
        local.egress_all,
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
        ]
      )
    }

    web = {
      name = "${local.name_prefix}-web-sg"
      rules = concat(
        local.egress_all,
        [
          {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = var.web_port
            port_range_max   = var.web_port
            remote_ip_prefix = var.subnets.dmz.cidr
            description      = "web from dmz load balancer"
          }
        ],
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
        ]
      )
    }

    was = {
      name = "${local.name_prefix}-was-sg"
      rules = concat(
        local.egress_all,
        [
          {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = var.was_port
            port_range_max   = var.was_port
            remote_ip_prefix = var.subnets.dmz.cidr
            description      = "was from web or internal load balancer"
          }
        ],
        [
          {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = var.was_port
            port_range_max   = var.was_port
            remote_ip_prefix = var.subnets.app.cidr
            description      = "was from internal load balancer subnet"
          }
        ],
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
        ]
      )
    }

    db = {
      name = "${local.name_prefix}-db-sg"
      rules = concat(
        local.egress_all,
        [
          {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "tcp"
            port_range_min   = var.db_port
            port_range_max   = var.db_port
            remote_ip_prefix = var.subnets.app.cidr
            description      = "db from was subnet"
          }
        ],
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
        ]
      )
    }

    management = {
      name = "${local.name_prefix}-management-sg"
      rules = concat(
        local.egress_all,
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
        ]
      )
    }

    operations = {
      name = "${local.name_prefix}-operations-sg"
      rules = concat(
        local.egress_all,
        [
          {
            direction        = "ingress"
            ethertype        = "IPv4"
            protocol         = "udp"
            port_range_min   = var.log_ingress_port
            port_range_max   = var.log_ingress_port
            remote_ip_prefix = var.vpc_cidr
            description      = "log collector from vpc"
          }
        ],
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
        ]
      )
    }
  }

  web_instances = {
    for index in range(var.web_count) : format("web-%02d", index + 1) => {
      name                = "${local.name_prefix}-web-${format("%02d", index + 1)}"
      flavor_id           = var.flavor_ids.web
      subnet_key          = "dmz"
      security_group_keys = ["web"]
      boot_volume_size    = var.boot_volume_size
    }
  }

  was_instances = {
    for index in range(var.was_count) : format("was-%02d", index + 1) => {
      name                = "${local.name_prefix}-was-${format("%02d", index + 1)}"
      flavor_id           = var.flavor_ids.was
      subnet_key          = "app"
      security_group_keys = ["was"]
      boot_volume_size    = var.boot_volume_size
    }
  }

  db_instances = {
    for index in range(var.db_count) : format("db-%02d", index + 1) => {
      name                = "${local.name_prefix}-db-${format("%02d", index + 1)}"
      flavor_id           = var.flavor_ids.db
      subnet_key          = "data"
      security_group_keys = ["db"]
      boot_volume_size    = var.boot_volume_size
    }
  }

  operations_instances = {
    for key, server in var.operations_servers : "ops-${key}" => {
      name                = coalesce(try(server.name, null), "${local.name_prefix}-${key}")
      flavor_id           = var.flavor_ids.ops
      subnet_key          = "operations"
      security_group_keys = ["operations"]
      boot_volume_size    = var.boot_volume_size
    }
  }

  bastion_instance = {
    bastion = {
      name                = "${local.name_prefix}-bastion"
      flavor_id           = var.flavor_ids.ops
      subnet_key          = "management"
      security_group_keys = ["management"]
      boot_volume_size    = var.boot_volume_size
    }
  }

  instance_specs = merge(
    local.web_instances,
    local.was_instances,
    local.db_instances,
    local.operations_instances,
    local.bastion_instance
  )

  data_volume_specs = merge(
    {
      for key, instance in local.db_instances : "${key}-data" => {
        instance_key      = key
        name              = "${instance.name}-data"
        size              = var.db_data_volume_size
        availability_zone = var.availability_zone
        volume_type       = var.db_data_volume_type
        description       = "DB data volume for ${instance.name}"
      }
    },
    {
      for key, server in var.operations_servers : "ops-${key}-data" => {
        instance_key      = "ops-${key}"
        name              = "${local.name_prefix}-${key}-data"
        size              = try(server.data_volume_size, 100)
        availability_zone = var.availability_zone
        volume_type       = try(server.volume_type, "General HDD")
        description       = "Operations data volume for ${key}"
      }
    }
  )

  load_balancers = {
    public = {
      name               = "${local.name_prefix}-public-lb"
      description        = "Public entry load balancer for web tier."
      vip_subnet_id      = module.network.subnet_ids["dmz"]
      security_group_ids = [module.security.security_group_ids["public_lb"]]
    }
    internal = {
      name               = "${local.name_prefix}-internal-lb"
      description        = "Internal load balancer for WAS tier."
      vip_subnet_id      = module.network.subnet_ids["app"]
      security_group_ids = [module.security.security_group_ids["was"]]
    }
  }

  listeners = {
    public_http = {
      name              = "${local.name_prefix}-public-http"
      load_balancer_key = "public"
      protocol          = "HTTP"
      protocol_port     = 80
    }
    internal_http = {
      name              = "${local.name_prefix}-internal-http"
      load_balancer_key = "internal"
      protocol          = "HTTP"
      protocol_port     = var.was_port
    }
  }

  pools = {
    public_web = {
      name         = "${local.name_prefix}-public-web-pool"
      listener_key = "public_http"
      protocol     = "HTTP"
      lb_method    = "ROUND_ROBIN"
      member_port  = var.web_port
    }
    internal_was = {
      name         = "${local.name_prefix}-internal-was-pool"
      listener_key = "internal_http"
      protocol     = "HTTP"
      lb_method    = "ROUND_ROBIN"
      member_port  = var.was_port
    }
  }

  lb_members = merge(
    {
      for key, instance in local.web_instances : "public-${key}" => {
        pool_key      = "public_web"
        subnet_id     = module.network.subnet_ids[instance.subnet_key]
        address       = module.compute.access_ip_v4[key]
        protocol_port = var.web_port
      }
    },
    {
      for key, instance in local.was_instances : "internal-${key}" => {
        pool_key      = "internal_was"
        subnet_id     = module.network.subnet_ids[instance.subnet_key]
        address       = module.compute.access_ip_v4[key]
        protocol_port = var.was_port
      }
    }
  )

  monitors = {
    public_web = {
      name           = "${local.name_prefix}-public-web-monitor"
      pool_key       = "public_web"
      type           = "HTTP"
      delay          = 20
      timeout        = 10
      max_retries    = 3
      url_path       = "/"
      http_method    = "GET"
      expected_codes = "200-399"
    }
    internal_was = {
      name           = "${local.name_prefix}-internal-was-monitor"
      pool_key       = "internal_was"
      type           = "HTTP"
      delay          = 20
      timeout        = 10
      max_retries    = 3
      url_path       = "/"
      http_method    = "GET"
      expected_codes = "200-399"
    }
  }
}

module "network" {
  source = "../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  subnets             = var.subnets
  internet_gateway_id = var.internet_gateway_id
}

module "security" {
  source = "../modules/security"

  security_groups = local.security_groups
}

module "compute" {
  source = "../modules/compute"

  instances = {
    for key, instance in local.instance_specs : key => {
      name                  = instance.name
      flavor_id             = instance.flavor_id
      key_pair              = var.keypair_name
      availability_zone     = var.availability_zone
      network_id            = module.network.vpc_id
      subnet_id             = module.network.subnet_ids[instance.subnet_key]
      security_groups       = [for sg_key in instance.security_group_keys : module.security.security_group_names[sg_key]]
      boot_image_id         = var.image_id
      boot_volume_size      = instance.boot_volume_size
      boot_destination_type = var.boot_destination_type
    }
  }
}

module "block_storage" {
  source = "../modules/block-storage"

  volumes = {
    for key, volume in local.data_volume_specs : key => {
      name              = volume.name
      size              = volume.size
      description       = volume.description
      availability_zone = volume.availability_zone
      volume_type       = volume.volume_type
    }
  }

  instance_ids = module.compute.instance_ids

  attachments = {
    for key, volume in local.data_volume_specs : key => {
      volume_key   = key
      instance_key = volume.instance_key
    }
  }
}

module "load_balancer" {
  source = "../modules/load-balancer"

  load_balancers = local.load_balancers
  listeners      = local.listeners
  pools          = local.pools
  members        = local.lb_members
  monitors       = local.monitors
}

module "object_storage" {
  source = "../modules/object-storage"

  name_prefix = local.name_prefix
  containers  = var.object_storage_containers
  metadata    = local.common_metadata
}
