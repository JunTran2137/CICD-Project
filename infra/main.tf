################################################################################
# VPC
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.vpcs

  name             = try(each.value.name, null)
  cidr             = try(each.value.cidr, null)
  enable_ipv6      = try(each.value.enable_ipv6, false)
  instance_tenancy = try(each.value.instance_tenancy, "default")

  azs              = try(each.value.azs, [])
  private_subnets  = try(each.value.private_subnets, [])
  public_subnets   = try(each.value.public_subnets, [])
  database_subnets = try(each.value.database_subnets, [])

  enable_nat_gateway     = try(each.value.enable_nat_gateway, false)
  single_nat_gateway     = try(each.value.single_nat_gateway, false)
  one_nat_gateway_per_az = try(each.value.one_nat_gateway_per_az, false)

  enable_dns_hostnames = try(each.value.enable_dns_hostnames, true)
  enable_dns_support   = try(each.value.enable_dns_support, true)

  tags = try(each.value.tags, {})
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

  tags = try(each.value.tags, {})
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
  tags  = try(each.value.tags, {})
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

  tags = try(each.value.tags, {})
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

  tags = try(each.value.tags, {})
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
# module "rds" {
#   source = "terraform-aws-modules/rds/aws"

#   for_each = var.rds_databases

#   # Engine options
#   engine                   = each.value.engine
#   engine_version           = each.value.engine_version
#   engine_lifecycle_support = each.value.engine_lifecycle_support
  
#   # Availability and durability
#   multi_az = each.value.multi_az

#   # Settings
#   identifier                    = each.value.identifier
#   username                      = each.value.username
#   manage_master_user_password   = each.value.manage_master_user_password
#   master_user_secret_kms_key_id = each.value.master_user_secret_kms_key_id
  
#   # Instance configuration
#   instance_class = each.value.instance_class

#   # Storage
#   storage_type          = each.value.storage_type
#   allocated_storage     = each.value.allocated_storage
#   iops                  = each.value.iops
#   max_allocated_storage = each.value.max_allocated_storage
#   dedicated_log_volume  = each.value.dedicated_log_volume

#   # Subnet groups
#   create_db_subnet_group      = each.value.create_db_subnet_group
#   db_subnet_group_name        = each.value.db_subnet_group_name
#   db_subnet_group_description = each.value.db_subnet_group_description
#   subnet_ids                  = module.vpc[each.value.vpc_key].database_subnets

#   # Connectivity
#   network_type           = each.value.network_type
#   publicly_accessible    = each.value.publicly_accessible
#   vpc_security_group_ids = [module.sg[each.value.sg_key].security_group_id]
#   ca_cert_identifier     = each.value.ca_cert_identifier
#   port                   = each.value.port

#   # Tags
#   tags = each.value.tags

#   # Monitoring role
#   create_monitoring_role      = each.value.create_monitoring_role
#   monitoring_role_name        = each.value.monitoring_role_name
#   monitoring_role_description = each.value.monitoring_role_description

#   # Monitoring
#   performance_insights_enabled          = each.value.performance_insights_enabled
#   performance_insights_retention_period = each.value.performance_insights_retention_period
#   performance_insights_kms_key_id       = each.value.performance_insights_kms_key_id
#   monitoring_interval                   = each.value.monitoring_interval
#   create_cloudwatch_log_group           = each.value.create_cloudwatch_log_group
#   enabled_cloudwatch_logs_exports       = each.value.enabled_cloudwatch_logs_exports  

#   # Database options
#   db_name              = each.value.db_name
#   family               = each.value.family                # DB parameter group
#   major_engine_version = each.value.major_engine_version  # DB option group

#   # Backup
#   backup_retention_period = each.value.backup_retention_period
#   backup_window           = each.value.backup_window
#   copy_tags_to_snapshot   = each.value.copy_tags_to_snapshot
#   storage_encrypted       = each.value.storage_encrypted
#   kms_key_id              = each.value.kms_key_id

#   # Maintenance
#   auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
#   maintenance_window         = each.value.maintenance_window  
#   deletion_protection        = false  
# }

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

  tags = try(each.value.tags, {})
}

################################################################################
# ECS
################################################################################
resource "aws_service_discovery_http_namespace" "this" {
  for_each = var.namespaces

  name        = try(each.value.name, null)
  description = try(each.value.description, null)
  tags        = try(each.value.tags, {})
}

# module "ecs" {
#   source = "terraform-aws-modules/ecs/aws"

#   for_each = var.ecs_clusters

#   cluster_name = each.value.cluster_name

#   cluster_service_connect_defaults = {
#     namespace = aws_service_discovery_http_namespace.this.arn
#   }

#   default_capacity_provider_strategy = each.value.default_capacity_provider_strategy
#   cluster_setting                    = each.value.cluster_setting

#   cluster_configuration = {
#     for k, v in each.value.cluster_configuration : k => merge(v, {
#       execute_command_configuration = merge(v.execute_command_configuration, {
#           kms_key_id = module.kms["ecs-exec"].kms_key_id
#       })

#       managed_storage_configuration = {
#         kms_key_id                           = aws_kms_key.ecs_managed_storage.arn
#         fargate_ephemeral_storage_kms_key_id = aws_kms_key.ecs_fargate_ephemeral.arn
#       }
#     })
#   }

#   services = {
#     for k, v in each.value.services : k => merge(v, {
#       service_connect_configuration = merge(v.service_connect_configuration, {
#         service = [
#           for service in v.service_connect_configuration : merge(service, {
#             tls = merge(v1.tls, {
#               role_arn = aws_iam_role.tls_role.arn,

#               issuer_cert_authority = {
#                 aws_pca_authority_arn = aws_acmpca_certificate_authority.this.arn
#               },

#               kms_key = aws_kms_key.ecs_managed_storage.arn
#             })
#           })
#         ]}
#       )

#       load_balancer = {
#         for k2, v2 in v.load_balancer : k2 => merge(v2, {
#           target_group_arn = module.alb[each.key].target_groups[v2.target_group_key].arn
#         })
#       }
#     })
#   }

#   tags = local.tags
# }