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
    load_balancer_type    = optional(string)
    name                  = optional(string)
    internal              = optional(bool)
    ip_address_type       = optional(string)
    vpc_key               = optional(string)
    ipam_pools            = optional(map(string))
    sg_key                = optional(string)
    create_security_group = optional(bool)
    listeners             = optional(any)
    target_groups         = optional(any)
    tags                  = optional(map(string))
  }))
  default = {}
}

################################################################################
# Route53 Records
################################################################################
variable "route53_records" {
  description = "Map of Route53 record configurations"
  type = map(object({
    zone_key = optional(string)
    records  = optional(list(object({
      alb_key = optional(string)
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
# RDS
################################################################################
variable "rds_databases" {
  description = "Map of RDS database configurations"
  type = map(object({
    allocated_storage                     = optional(number)
    auto_minor_version_upgrade            = optional(bool)
    backup_retention_period               = optional(number)
    backup_window                         = optional(string)
    ca_cert_identifier                    = optional(string)
    copy_tags_to_snapshot                 = optional(bool)
    create_cloudwatch_log_group           = optional(bool)
    create_db_subnet_group                = optional(bool)
    create_monitoring_role                = optional(bool)
    db_name                               = optional(string)
    db_subnet_group_description           = optional(string)
    db_subnet_group_name                  = optional(string)
    dedicated_log_volume                  = optional(bool)
    enabled_cloudwatch_logs_exports       = optional(list(string))
    engine                                = optional(string)
    engine_lifecycle_support              = optional(string)
    engine_version                        = optional(string)
    family                                = optional(string)
    identifier                            = optional(string)
    instance_class                        = optional(string)
    iops                                  = optional(number)
    kms_key_id                            = optional(string)
    maintenance_window                    = optional(string)
    major_engine_version                  = optional(string)
    manage_master_user_password           = optional(bool)
    master_user_secret_kms_key_id         = optional(string)
    max_allocated_storage                 = optional(number)
    monitoring_interval                   = optional(number)
    monitoring_role_description           = optional(string)
    monitoring_role_name                  = optional(string)
    multi_az                              = optional(bool)
    network_type                          = optional(string)
    performance_insights_enabled          = optional(bool)
    performance_insights_kms_key_id       = optional(string)
    performance_insights_retention_period = optional(number)
    port                                  = optional(number)
    publicly_accessible                   = optional(bool)
    sg_key                                = optional(string)
    storage_encrypted                     = optional(bool)
    storage_type                          = optional(string)
    tags                                  = optional(map(string))
    username                              = optional(string)
    vpc_key                               = optional(string)
  }))
  default = {}
}

################################################################################
# ECR
################################################################################
variable "ecr_repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    repository_name                                  = optional(string)
    repository_image_tag_mutability                  = optional(string)
    repository_image_tag_mutability_exclusion_filter = optional(list(object({
      filter      = string
      filter_type = string
    })))
    repository_encryption_type        = optional(string)
    repository_image_scan_on_push     = optional(bool)
    repository_lifecycle_policy       = optional(any)
    tags                              = optional(map(string))
  }))
  default = {}
}

################################################################################
# ECS
################################################################################
variable "namespaces" {
  description = "Map of Service Discovery HTTP Namespace configurations"
  type = map(object({
    name        = optional(string)
    description = optional(string)
    tags        = optional(map(string))
  }))
  default = {}
}

variable "ecs_clusters" {
  description = "Map of ECS Cluster configurations"
  type = map(object({
    cluster_name                       = optional(string)
    default_capacity_provider_strategy = optional(map(any))
    cluster_setting                    = optional(list(map(string)))
    cluster_configuration              = optional(map(any))
    services                           = optional(map(any))
    tags                               = optional(map(string))
  }))
  default = {}
}

