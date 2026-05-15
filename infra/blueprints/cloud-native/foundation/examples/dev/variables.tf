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
    cidr = string
  }))
  default = {
    app-a = {
      cidr = "10.10.10.0/24"
    }
    app-b = {
      cidr = "10.10.20.0/24"
    }
  }
}

variable "internet_gateway_id" {
  description = "Existing Internet Gateway ID to attach to the routing table. Create/check this in the NHN Cloud console."
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
  default     = "app-a"
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
