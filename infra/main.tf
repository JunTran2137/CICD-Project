################################################################################
# VPC
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.vpcs

  name             = try(each.value.name, null)
  cidr             = try(each.value.cidr, null)
  enable_ipv6      = try(each.value.enable_ipv6, false)
  instance_tenancy = try(each.value.instance_tenancy, null)

  azs              = try(each.value.azs, [])
  private_subnets  = try(each.value.private_subnets, [])
  public_subnets   = try(each.value.public_subnets, [])
  database_subnets = try(each.value.database_subnets, [])

  enable_nat_gateway     = try(each.value.enable_nat_gateway, false)
  single_nat_gateway     = try(each.value.single_nat_gateway, false)
  one_nat_gateway_per_az = try(each.value.one_nat_gateway_per_az, false)

  enable_dns_hostnames = try(each.value.enable_dns_hostnames, true)
  enable_dns_support   = try(each.value.enable_dns_support, true)

  tags = try(merge(each.value.tags, var.environment_tags ), {})
}

################################################################################
# Security Group
################################################################################
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  for_each = var.sgs

  name        = try(each.value.name, null)
  description = try(each.value.description, null)
  vpc_id      = try(module.vpc[each.value.vpc_key].vpc_id, null)

  ingress_cidr_blocks = try(each.value.ingress_cidr_blocks, [])
  ingress_rules       = try(coalesce(each.value.ingress_rules, []), [])

  tags = try(merge(each.value.tags, var.environment_tags ), {})
}

resource "aws_security_group_rule" "this" {
  for_each = var.sg_rules

  security_group_id        = try(module.sg[each.value.sg_key].security_group_id, null)
  source_security_group_id = try(module.sg[each.value.source_sg_key].security_group_id, null)
  type                     = try(each.value.type, null)
  from_port                = try(each.value.from_port, null)
  to_port                  = try(each.value.to_port, null)
  protocol                 = try(each.value.protocol, null)
  description              = try(each.value.description, null)
}

################################################################################
# Route 53 Zone
################################################################################
module "route53_zones" {
  source = "terraform-aws-modules/route53/aws//modules/zones"

  for_each = var.route53_zones
  
  zones = try(each.value.zones, {})
  tags  = try(merge(each.value.tags, var.environment_tags ), {})
}

################################################################################
# ACM
################################################################################
module "acm" {
  source = "terraform-aws-modules/acm/aws"

  for_each = var.acms

  domain_name       = try(values(module.route53_zones[each.value.zone_key].route53_zone_name)[0], null)
  zone_id           = try(values(module.route53_zones[each.value.zone_key].route53_zone_zone_id)[0], null)
  export            = try(each.value.export, null)
  validation_method = try(each.value.validation_method, null)
  key_algorithm     = try(each.value.key_algorithm, null)

  subject_alternative_names = try([
    "*.${values(module.route53_zones[each.value.zone_key].route53_zone_name)[0]}"
  ], [])

  tags = try(merge(each.value.tags, var.environment_tags ), {})
}

################################################################################
# ALB
################################################################################
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  for_each = var.albs

  load_balancer_type    = try(each.value.load_balancer_type, null)
  name                  = try(each.value.name, null)
  internal              = try(each.value.internal, false)
  ip_address_type       = try(each.value.ip_address_type, null)
  vpc_id                = try(module.vpc[each.value.vpc_key].vpc_id, null)
  ipam_pools            = try(coalesce(each.value.ipam_pools, {}), {})
  subnets               = try(module.vpc[each.value.vpc_key].public_subnets, [])
  security_groups       = try([module.sg[each.value.sg_key].security_group_id], [])
  create_security_group = try(each.value.create_security_group, false)

  listeners = try({
    for k, v in each.value.listeners : k => merge(v, {
      certificate_arn = try(v.acm_key, null) != null ? module.acm[v.acm_key].acm_certificate_arn : null
    })
  }, {})
  
  target_groups = try({
    for k, v in each.value.target_groups : k => merge(v, {
      vpc_id = module.vpc[v.vpc_key].vpc_id
    })
  }, {})

  tags = try(merge(each.value.tags, var.environment_tags ), {})
}

################################################################################
# Route 53 Record
################################################################################
module "route53_records" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  for_each = var.route53_records

  zone_id = try(values(module.route53_zones[each.value.zone_key].route53_zone_zone_id)[0], null)

  records = try([
    for record in each.value.records : merge(record, {
      alias = merge(record.alias, {
        name    = try(record.alb_key, null) != null ? module.alb[record.alb_key].dns_name : null
        zone_id = try(record.alb_key, null) != null ? module.alb[record.alb_key].zone_id : null
      })
    })
  ], [])
}

################################################################################
# RDS
################################################################################
data "aws_kms_key" "master_user_secret_kms_key_id" {
  for_each = var.rds_databases

  key_id = try(each.value.master_user_secret_kms_key_id, null)
}

data "aws_kms_key" "performance_insights_kms_key_id" {
  for_each = var.rds_databases

  key_id = try(each.value.performance_insights_kms_key_id, null)
}

data "aws_kms_key" "kms_key_id" {
  for_each = var.rds_databases

  key_id = try(each.value.kms_key_id, null)
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  for_each = var.rds_databases

  # Engine options
  engine                   = try(each.value.engine, null)
  engine_version           = try(each.value.engine_version, null)
  engine_lifecycle_support = try(each.value.engine_lifecycle_support, null)
  
  # Availability and durability
  multi_az = try(each.value.multi_az, false)

  # Settings
  identifier                    = try(each.value.identifier, null)
  username                      = try(each.value.username, null)
  manage_master_user_password   = try(each.value.manage_master_user_password, true)
  master_user_secret_kms_key_id = try(data.aws_kms_key.master_user_secret_kms_key_id[each.key].arn, null)
  
  # Instance configuration
  instance_class = try(each.value.instance_class, null)

  # Storage
  storage_type          = try(each.value.storage_type, null)
  allocated_storage     = try(each.value.allocated_storage, null)
  iops                  = try(each.value.iops, null)
  storage_throughput    = try(each.value.storage_throughput, null)
  max_allocated_storage = try(each.value.max_allocated_storage, null)
  dedicated_log_volume  = try(each.value.dedicated_log_volume, false)

  # Subnet groups
  create_db_subnet_group      = try(each.value.create_db_subnet_group, true)
  db_subnet_group_name        = try(each.value.db_subnet_group_name, null)
  db_subnet_group_description = try(each.value.db_subnet_group_description, null)
  subnet_ids                  = try(module.vpc[each.value.vpc_key].database_subnets, [])

  # Connectivity
  network_type           = try(each.value.network_type, null)
  publicly_accessible    = try(each.value.publicly_accessible, false)
  vpc_security_group_ids = try([module.sg[each.value.sg_key].security_group_id], [])
  ca_cert_identifier     = try(each.value.ca_cert_identifier, null)
  port                   = try(each.value.port, null)

  # Tags
  tags = try(merge(each.value.tags, var.environment_tags ), {})

  # Database authentication
  iam_database_authentication_enabled = try(each.value.iam_database_authentication_enabled, false)

  # Monitoring role
  create_monitoring_role      = try(each.value.create_monitoring_role, true)
  monitoring_role_name        = try(each.value.monitoring_role_name, null)
  monitoring_role_description = try(each.value.monitoring_role_description, null)

  # Monitoring
  performance_insights_enabled          = try(each.value.performance_insights_enabled, true)
  performance_insights_retention_period = try(each.value.performance_insights_retention_period, null)
  performance_insights_kms_key_id       = try(data.aws_kms_key.performance_insights_kms_key_id[each.key].arn, null)
  monitoring_interval                   = try(each.value.monitoring_interval, null)
  create_cloudwatch_log_group           = try(each.value.create_cloudwatch_log_group, true)
  enabled_cloudwatch_logs_exports       = try(each.value.enabled_cloudwatch_logs_exports, [])

  # Database options
  db_name              = try(each.value.db_name, null)
  family               = try(each.value.family, null)
  major_engine_version = try(each.value.major_engine_version, null)

  # Backup
  backup_retention_period = try(each.value.backup_retention_period, null)
  backup_window           = try(each.value.backup_window, null)
  copy_tags_to_snapshot   = try(each.value.copy_tags_to_snapshot, true)
  storage_encrypted       = try(each.value.storage_encrypted, true)
  kms_key_id              = try(data.aws_kms_key.kms_key_id[each.key].arn, null)

  # Maintenance
  auto_minor_version_upgrade = try(each.value.auto_minor_version_upgrade, true)
  maintenance_window         = try(each.value.maintenance_window, null)
  deletion_protection        = try(each.value.deletion_protection, false)
}

################################################################################
# ECR
################################################################################
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  for_each = var.ecr_repositories

  repository_name                                  = try(each.value.repository_name, null)
  repository_image_tag_mutability                  = try(each.value.repository_image_tag_mutability, null)
  repository_image_tag_mutability_exclusion_filter = try(each.value.repository_image_tag_mutability_exclusion_filter, null)
  repository_encryption_type                       = try(each.value.repository_encryption_type, null)
  repository_image_scan_on_push                    = try(each.value.repository_image_scan_on_push, true)
  repository_lifecycle_policy                      = try(jsonencode(each.value.repository_lifecycle_policy), null)

  tags = try(merge(each.value.tags, var.environment_tags ), {})
}

################################################################################
# ECS
################################################################################
resource "aws_service_discovery_http_namespace" "this" {
  for_each = var.namespaces

  name        = try(each.value.name, null)
  description = try(each.value.description, null)
  tags        = try(merge(each.value.tags, var.environment_tags ), {})
}

data "aws_kms_key" "ecs" {
  for_each = var.ecs_clusters

  key_id = try(each.value.kms_key_id, null)
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  for_each = var.ecs_clusters

  cluster_name = each.value.cluster_name

  cluster_service_connect_defaults = {
    namespace = aws_service_discovery_http_namespace.this[each.key].arn
  }

  default_capacity_provider_strategy = each.value.default_capacity_provider_strategy
  cluster_setting                    = each.value.cluster_setting

  cluster_configuration = merge(each.value.cluster_configuration, {
    execute_command_configuration = merge(each.value.cluster_configuration.execute_command_configuration, {
      kms_key_id = data.aws_kms_key.ecs[each.key].arn
    })

    # managed_storage_configuration = {
    #   kms_key_id                           = data.aws_kms_key.ecs[each.key].arn
    #   fargate_ephemeral_storage_kms_key_id = data.aws_kms_key.ecs[each.key].arn
    # }
  })

  services = {
    for k, v in each.value.services : k => merge(v, {
      task_exec_secret_arns = try([module.rds[v.rds_key].db_instance_master_user_secret_arn], [])

      container_definitions = {
        for k1, v1 in v.container_definitions : k1 => merge(v1, {
          image = try("${module.ecr[v1.ecr_key].repository_url}:latest", null)
        })
      }

      subnet_ids = module.vpc[v.vpc_key].private_subnets
      security_group_ids = [module.sg[v.sg_key].security_group_id]

      service_connect_configuration = merge(v.service_connect_configuration, {
        namespace = aws_service_discovery_http_namespace.this[each.key].arn
      })

      load_balancer = {
        for k1, v1 in v.load_balancer : k1 => merge(v1, {
          target_group_arn = module.alb[v1.alb_key].target_groups[v1.target_group_key].arn
        })
      }
    })
  }

  tags = try(merge(each.value.tags, var.environment_tags ), {})
}