################################################################################
# VPC
################################################################################
variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    name                   = optional(string)
    cidr                   = optional(string)
    enable_ipv6            = optional(bool)
    instance_tenancy       = optional(string)
    azs                    = optional(list(string))
    private_subnets        = optional(list(string))
    public_subnets         = optional(list(string))
    database_subnets       = optional(list(string))
    enable_nat_gateway     = optional(bool)
    single_nat_gateway     = optional(bool)
    one_nat_gateway_per_az = optional(bool)
    enable_dns_hostnames   = optional(bool)
    enable_dns_support     = optional(bool)
    tags                   = optional(map(string))
  }))
  default = {}
}

################################################################################
# Security Group
################################################################################
variable "sgs" {
  description = "Map of Security Group configurations"
  type = map(object({
    create              = optional(bool)
    name                = optional(string)
    description         = optional(string)
    vpc_key             = optional(string)
    ingress_cidr_blocks = optional(list(string))
    ingress_rules       = optional(list(string))
    egress_cidr_blocks  = optional(list(string))
    egress_rules        = optional(list(string))
    tags                = optional(map(string))
  }))
  default = {}
}

variable "sg_rules" {
  description = "Security group rules configuration"
  type = map(object({
    sg_key        = optional(string)
    source_sg_key = optional(string)
    type          = optional(string)
    from_port     = optional(number)
    to_port       = optional(number)
    protocol      = optional(string)
    description   = optional(string)
  }))
  default = {}
}

################################################################################
# Route 53 Zone
################################################################################
variable "route53_zones" {
  description = "Map of Route53 zone configurations"
  type = map(object({
    zones = optional(map(object({
      domain_name = optional(string)
      comment     = optional(string)
      tags        = optional(map(string))
    })))
    tags = optional(map(string))
  }))
  default = {}
}

################################################################################
# ACM
################################################################################
variable "acms" {
  description = "Map of ACM certificate configurations"
  type = map(object({
    zone_key                  = optional(string)
    domain_name               = optional(string)
    zone_id                   = optional(string)
    export                    = optional(string)
    validation_method         = optional(string)
    key_algorithm             = optional(string)
    subject_alternative_names = optional(list(string))
    tags                      = optional(map(string))
  }))
  default = {}
}

################################################################################
# ALB
################################################################################
variable "albs" {
  description = "Map of Application Load Balancer configurations"
  type = map(object({
    name               = optional(string)
    load_balancer_type = optional(string)
    internal           = optional(bool)
    ip_address_type    = optional(string)
    vpc_key            = optional(string)
    sg_key             = optional(string)
    listeners          = optional(map(any))
    target_groups      = optional(map(any))
    tags               = optional(map(string))
  }))
  default = {}
}

################################################################################
# Route53 Records
################################################################################
variable "route53_records" {
  description = "Map of Route53 record configurations"
  type = map(object({
    records = optional(list(object({
      alias_key = optional(string)
      name      = optional(string)
      type      = optional(string)
      alias     = optional(object({
        name                   = optional(string)
        zone_id                = optional(string)
        evaluate_target_health = optional(bool)
      }))
    })))
  }))
  default = {}
}

################################################################################
# ECS
################################################################################
# variable "ecs_clusters" {
#   description = "Map of ECS Cluster configurations"
#   type = map(object({
#     cluster_name                        = string
#     default_capacity_provider_strategy  = optional(map(any))
#     cluster_setting                     = optional(list(map(string)))
#     cluster_configuration              = optional(map(any))
#     services                           = optional(map(any))
#   }))
# }

# variable "dbs" {
#   description = "Map of RDS database configurations"
#   type = map(object({
#     allocated_storage                 = number
#     auto_minor_version_upgrade        = bool
#     backup_retention_period           = number
#     backup_window                     = string
#     ca_cert_identifier                = optional(string)
#     copy_tags_to_snapshot             = bool
#     create_cloudwatch_log_group       = optional(bool)
#     create_db_subnet_group            = bool
#     create_monitoring_role            = bool
#     db_name                           = string
#     db_subnet_group_description       = optional(string)
#     db_subnet_group_name              = optional(string)
#     dedicated_log_volume              = optional(bool)
#     enabled_cloudwatch_logs_exports   = optional(list(string))
#     engine                            = string
#     engine_lifecycle_support          = string
#     engine_version                    = string
#     family                            = string
#     identifier                        = string
#     instance_class                    = string
#     iops                              = optional(number)
#     kms_key_id                        = optional(string)
#     maintenance_window                = string
#     major_engine_version              = string
#     manage_master_user_password       = bool
#     master_user_secret_kms_key_id     = optional(string)
#     max_allocated_storage             = optional(number)
#     monitoring_interval               = optional(number)
#     monitoring_role_description       = optional(string)
#     monitoring_role_name              = optional(string)
#     multi_az                          = bool
#     network_type                      = string
#     performance_insights_enabled      = bool
#     performance_insights_kms_key_id       = optional(string)
#     performance_insights_retention_period = optional(number)
#     port                              = number
#     publicly_accessible               = bool
#     sg_key                            = string
#     storage_encrypted                 = bool
#     storage_type                      = string
#     tags                              = map(string)
#     username                          = string
#     vpc_key                           = string
#   }))
# }

