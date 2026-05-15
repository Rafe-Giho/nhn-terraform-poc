variable "nhncloud_user_name" {
  description = "NHN Cloud account ID."
  type        = string
  sensitive   = true
}

variable "nhncloud_tenant_id" {
  description = "NHN Cloud tenant/project ID."
  type        = string
  sensitive   = true
}

variable "nhncloud_password" {
  description = "NHN Cloud API password."
  type        = string
  sensitive   = true
}

variable "nhncloud_auth_url" {
  description = "NHN Cloud Identity API endpoint."
  type        = string
}

variable "nhncloud_region" {
  description = "NHN Cloud region."
  type        = string
  default     = "KR1"
}

variable "project_prefix" {
  description = "Prefix used for resource names."
  type        = string
  default     = "nhn-poc"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnets" {
  description = "3-tier VPC subnet map."
  type = map(object({
    cidr              = string
    routing_table_key = optional(string)
  }))
  default = {
    dmz = {
      cidr              = "10.20.10.0/24"
      routing_table_key = "public"
    }
    web = {
      cidr              = "10.20.20.0/24"
      routing_table_key = "private"
    }
    app = {
      cidr              = "10.20.30.0/24"
      routing_table_key = "private"
    }
    data = {
      cidr              = "10.20.40.0/24"
      routing_table_key = "private"
    }
    management = {
      cidr              = "10.20.50.0/24"
      routing_table_key = "management"
    }
    operations = {
      cidr              = "10.20.60.0/24"
      routing_table_key = "management"
    }
  }
}

variable "public_internet_gateway_id" {
  description = "Existing Internet Gateway ID to attach only to the public routing table."
  type        = string
  default     = null
}

variable "public_ingress_cidrs" {
  description = "CIDRs allowed to reach public HTTP/HTTPS entrypoints."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "management_cidrs" {
  description = "CIDRs allowed for SSH/admin access."
  type        = list(string)
  default     = []
}

variable "keypair_name" {
  description = "Existing keypair name for VM SSH access."
  type        = string
}

variable "image_id" {
  description = "Base image UUID for Web/WAS/DB/operations instances."
  type        = string
}

variable "availability_zone" {
  description = "Primary availability zone."
  type        = string
  default     = "kr-pub-a"
}

variable "flavor_ids" {
  description = "Flavor IDs by tier."
  type = object({
    web = string
    was = string
    db  = string
    ops = string
  })
}

variable "web_count" {
  description = "Number of Web servers."
  type        = number
  default     = 2
}

variable "was_count" {
  description = "Number of WAS servers."
  type        = number
  default     = 2
}

variable "db_count" {
  description = "Number of DB servers."
  type        = number
  default     = 1
}

variable "boot_volume_size" {
  description = "Default boot volume size in GB."
  type        = number
  default     = 50
}

variable "boot_destination_type" {
  description = "Boot block device destination type. Use volume for non-U2 flavors."
  type        = string
  default     = "volume"
}

variable "web_port" {
  description = "Web service member port."
  type        = number
  default     = 80
}

variable "was_port" {
  description = "WAS service member port."
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "DB service port."
  type        = number
  default     = 3306
}

variable "log_ingress_port" {
  description = "Operations log collector ingress port."
  type        = number
  default     = 514
}

variable "management_egress_ports" {
  description = "TCP ports that bastion/management hosts can reach inside the VPC."
  type        = list(number)
  default     = [22]
}

variable "operations_polling_ports" {
  description = "TCP agent ports that operations servers can poll inside the VPC."
  type        = list(number)
  default     = [9100]
}

variable "extra_security_group_rules" {
  description = "Project-specific additional security group rules by standard group key. Use only after design review."
  type = map(list(object({
    direction        = string
    ethertype        = optional(string, "IPv4")
    protocol         = optional(string)
    port_range_min   = optional(number)
    port_range_max   = optional(number)
    remote_ip_prefix = optional(string)
    remote_group_id  = optional(string)
    description      = optional(string)
  })))
  default = {}
}

variable "operations_servers" {
  description = "Operations servers to create."
  type = map(object({
    name             = optional(string)
    data_volume_size = optional(number, 100)
    volume_type      = optional(string, "General HDD")
  }))
  default = {
    monitoring = {
      data_volume_size = 100
    }
    logging = {
      data_volume_size = 200
    }
    backup = {
      data_volume_size = 300
    }
  }
}

variable "db_data_volume_size" {
  description = "DB data volume size in GB."
  type        = number
  default     = 200
}

variable "db_data_volume_type" {
  description = "DB data volume type."
  type        = string
  default     = "General SSD"
}

variable "object_storage_containers" {
  description = "Object Storage containers for backups, logs, artifacts, and install files."
  type = map(object({
    name         = optional(string)
    versioning   = optional(bool, true)
    content_type = optional(string)
    metadata     = optional(map(string), {})
  }))
  default = {
    artifacts = {
      metadata = {
        purpose = "release-artifacts"
      }
    }
    backups = {
      metadata = {
        purpose = "backup"
      }
    }
    logs = {
      metadata = {
        purpose = "log-archive"
      }
    }
    install_files = {
      metadata = {
        purpose = "solution-install-files"
      }
    }
  }
}
