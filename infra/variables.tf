variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    name                    = string
    cidr                   = string
    azs                    = list(string)
    private_subnets        = list(string)
    public_subnets         = list(string)
    database_subnets       = list(string)
    enable_nat_gateway     = bool
    enable_vpn_gateway     = bool
    enable_dns_hostnames   = optional(bool)
    enable_dns_support     = optional(bool)
    single_nat_gateway     = optional(bool)
    one_nat_gateway_per_az = optional(bool)
    tags                   = map(string)
  }))
}

variable "sgs" {
  description = "Map of Security Group configurations"
  type = map(object({
    name                                  = string
    description                          = string
    ingress_cidr_blocks                  = list(string)
    ingress_rules                        = list(string)
    egress_rules                         = list(string)
    egress_with_source_security_group_id = optional(list(map(any)))
    tags                                 = map(string)
  }))
}

variable "albs" {
  description = "Map of Application Load Balancer configurations"
  type = map(object({
    name                = string
    load_balancer_type = string
    internal           = bool
    ip_address_type    = string
    vpc_key            = string
    sg_key             = string
    listeners          = map(any)
    target_groups      = map(any)
    tags               = map(string)
  }))
}

variable "ecs_clusters" {
  description = "Map of ECS Cluster configurations"
  type = map(object({
    cluster_name                        = string
    default_capacity_provider_strategy  = optional(map(any))
    cluster_setting                     = optional(list(map(string)))
    cluster_configuration              = optional(map(any))
    services                           = optional(map(any))
  }))
}

