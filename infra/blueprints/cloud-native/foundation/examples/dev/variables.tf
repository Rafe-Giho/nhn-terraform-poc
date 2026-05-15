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
  default     = "10.10.0.0/16"
}

variable "subnets" {
  description = "VPC subnet map."
  type = map(object({
    cidr              = string
    routing_table_key = optional(string)
  }))
  default = {
    ingress = {
      cidr              = "10.10.10.0/24"
      routing_table_key = "public"
    }
    nks-a = {
      cidr              = "10.10.20.0/24"
      routing_table_key = "private"
    }
    nks-b = {
      cidr              = "10.10.30.0/24"
      routing_table_key = "private"
    }
    devops = {
      cidr              = "10.10.40.0/24"
      routing_table_key = "management"
    }
    management = {
      cidr              = "10.10.50.0/24"
      routing_table_key = "management"
    }
  }
}

variable "public_internet_gateway_id" {
  description = "Existing Internet Gateway ID to attach only to the public routing table. Create/check this in the NHN Cloud console."
  type        = string
  default     = null
}

variable "public_ingress_cidrs" {
  description = "CIDRs allowed to reach public HTTP/HTTPS entrypoints."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "management_cidrs" {
  description = "CIDRs allowed for SSH/admin access. Leave empty to disable admin ingress."
  type        = list(string)
  default     = []
}

variable "devops_access_cidrs" {
  description = "CIDRs allowed to reach Git/Gitea/GitLab/Jenkins service ports on DevOps integration servers."
  type        = list(string)
  default     = []
}

variable "entrypoint_backend_ports" {
  description = "TCP backend ports that public entrypoint load balancers can reach inside the VPC."
  type        = list(number)
  default     = [80, 443]
}

variable "platform_admin_egress_ports" {
  description = "TCP ports that platform administration hosts can reach inside the VPC."
  type        = list(number)
  default     = [22, 443, 6443]
}

variable "devops_internal_egress_ports" {
  description = "TCP ports that DevOps integration servers can reach inside the VPC."
  type        = list(number)
  default     = [22, 80, 443, 6443, 50000]
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

variable "devops_servers" {
  description = "Optional VM-based DevOps integration servers such as GitLab, Gitea, and Jenkins. Application installation is handled outside Terraform."
  type = map(object({
    enabled                    = optional(bool, true)
    name                       = optional(string)
    role                       = optional(string)
    subnet_key                 = optional(string, "devops")
    flavor_id                  = string
    image_id                   = string
    key_pair                   = optional(string)
    availability_zone          = optional(string)
    fixed_ip_v4                = optional(string)
    ingress_ports              = optional(list(number), [])
    boot_volume_size           = optional(number, 80)
    boot_delete_on_termination = optional(bool, false)
    data_volume_size           = optional(number, 0)
    data_volume_type           = optional(string, "General HDD")
  }))
  default = {}
}

variable "object_storage_containers" {
  description = "Object Storage containers for artifacts, logs, backups, and exports."
  type = map(object({
    name         = optional(string)
    versioning   = optional(bool, true)
    content_type = optional(string)
    metadata     = optional(map(string), {})
  }))
  default = {
    artifacts = {
      metadata = {
        purpose = "ci-artifacts"
      }
    }
    backups = {
      metadata = {
        purpose = "backup"
      }
    }
    logs = {
      metadata = {
        purpose = "pipeline-logs"
      }
    }
  }
}

variable "nks_subnet_key" {
  description = "Subnet key to use for the NKS fixed subnet."
  type        = string
  default     = "nks-a"
}

variable "nks_cluster_name" {
  description = "NKS cluster name."
  type        = string
  default     = "platform"
}

variable "nks_node_count" {
  description = "Initial NKS worker node count."
  type        = number
  default     = 2
}

variable "nks_node_flavor_id" {
  description = "NKS worker flavor UUID. Check in NHN Cloud console or data source."
  type        = string
}

variable "nks_keypair_name" {
  description = "Existing keypair name for NKS worker SSH access."
  type        = string
}

variable "nks_node_image_id" {
  description = "NKS worker node image UUID."
  type        = string
}

variable "nks_kubernetes_version" {
  description = "NKS Kubernetes version label, for example v1.33.4."
  type        = string
}

variable "nks_availability_zone" {
  description = "Primary NKS availability zone."
  type        = string
  default     = "kr-pub-a"
}

variable "nks_boot_volume_size" {
  description = "NKS worker boot volume size in GB."
  type        = number
  default     = 50
}

variable "nks_boot_volume_type" {
  description = "NKS worker boot volume type."
  type        = string
  default     = "General HDD"
}

variable "nks_external_network_id" {
  description = "External network or Internet Gateway network UUID for NKS public endpoint."
  type        = string
}

variable "nks_external_subnet_id_list" {
  description = "Colon-separated external subnet UUID list for NKS."
  type        = string
}

variable "nks_calico_version" {
  description = "NKS Calico addon version."
  type        = string
}

variable "nks_calico_mode" {
  description = "NKS Calico mode."
  type        = string
  default     = "vxlan"
}

variable "nks_coredns_version" {
  description = "NKS CoreDNS addon version."
  type        = string
}

variable "nks_autoscaler" {
  description = "NKS cluster autoscaler labels."
  type = object({
    enabled                    = bool
    min_node_count             = number
    max_node_count             = number
    scale_down_enabled         = bool
    scale_down_delay_after_add = number
    scale_down_unneeded_time   = number
    scale_down_util_threshold  = number
  })
  default = {
    enabled                    = false
    min_node_count             = 2
    max_node_count             = 6
    scale_down_enabled         = false
    scale_down_delay_after_add = 10
    scale_down_unneeded_time   = 10
    scale_down_util_threshold  = 50
  }
}

variable "additional_nodegroups" {
  description = "Additional NKS node groups."
  type = map(object({
    name       = string
    node_count = optional(number, 1)
    flavor_id  = string
    image_id   = string
    version    = optional(string)
    labels     = map(string)
  }))
  default = {}
}
