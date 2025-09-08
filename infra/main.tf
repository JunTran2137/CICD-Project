################################################################################
# VPC
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.vpcs

  name             = each.value.name
  cidr             = each.value.cidr
  enable_ipv6      = each.value.enable_ipv6
  instance_tenancy = each.value.instance_tenancy

  azs              = each.value.azs
  private_subnets  = each.value.private_subnets
  public_subnets   = each.value.public_subnets
  database_subnets = each.value.database_subnets

  enable_nat_gateway     = each.value.enable_nat_gateway
  single_nat_gateway     = each.value.single_nat_gateway
  one_nat_gateway_per_az = each.value.one_nat_gateway_per_az

  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support

  tags = each.value.tags
}

################################################################################
# Security Group
################################################################################
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  for_each = var.sgs

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc[each.value.vpc_key].vpc_id

  ingress_cidr_blocks = coalesce(each.value.ingress_cidr_blocks, [])
  ingress_rules       = coalesce(each.value.ingress_rules, [])

  tags = each.value.tags
}

resource "aws_security_group_rule" "this" {
  for_each = var.sg_rules

  security_group_id        = module.sg[each.value.sg_key].security_group_id
  source_security_group_id = module.sg[each.value.source_sg_key].security_group_id
  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  description              = each.value.description
}

################################################################################
# Route 53 Zone
################################################################################
module "route53_zones" {
  source = "terraform-aws-modules/route53/aws//modules/zones"

  for_each = var.route53_zones
  
  zones = each.value.zones
  tags  = each.value.tags
}

################################################################################
# ACM
################################################################################
module "acm" {
  source = "terraform-aws-modules/acm/aws"

  for_each = var.acms

  domain_name       = values(module.route53_zones[each.value.zone_key].route53_zone_name)[0]
  zone_id           = values(module.route53_zones[each.value.zone_key].route53_zone_zone_id)[0]
  export            = each.value.export
  validation_method = each.value.validation_method
  key_algorithm     = each.value.key_algorithm

  subject_alternative_names = [
    "*.${values(module.route53_zones[each.value.zone_key].route53_zone_name)[0]}"
  ]

  tags = each.value.tags
}

################################################################################
# ALB
################################################################################
# module "alb" {
#   source = "terraform-aws-modules/alb/aws"

#   for_each = var.albs

# 	load_balancer_type = each.value.load_balancer_type
#   name               = each.value.name
# 	internal           = each.value.internal
# 	ip_address_type    = each.value.ip_address_type
#   vpc_id             = module.vpc[each.value.vpc_key].vpc_id
#   subnets            = module.vpc[each.value.vpc_key].public_subnets
#   security_groups    = [module.sg[each.value.sg_key].security_group_id]

#   listeners = {
#     for k, v in each.value.listeners : k => merge(v, {
#       target_group_key = try(v.target_group_key, null)
#       target_group_arn = try(v.target_group_key != null ? module.alb[each.key].target_groups[v.target_group_key].arn : null, null)
#       additional_certificate_arns = try(k == "https" ? [module.wildcard_cert.acm_certificate_arn] : [], [])
#     })
#   }

#   target_groups = {
#     for k, v in each.value.target_groups : k => merge(v, {
#       vpc_id = module.vpc[each.value.vpc_key].vpc_id
#     })
#   }

#   tags = each.value.tags
# }

################################################################################
# Route 53 Record
################################################################################
# module "route53_records" {
#   source = "terraform-aws-modules/route53/aws//modules/records"

#   for_each = var.route53_records

#   zone_id = module.route53_zones.zone_ids[each.value.zone_key]
#   records = {
#     for k, v in each.value.records : k => merge(v, {
#       name    = module.alb[each.value.records.alias_key].dns_name
#       zone_id = module.alb[each.value.records.alias_key].zone_id
#     })
#   }
# }


# module "vpc_lattice" {
#   source = "terraform-aws-modules/vpc-lattice/aws"
  
#   name = "example"
  
#   target_groups = {
#     "your-target-group" = {
#       type = "IP"
#       targets = {
#         target1 = {
#           ip        = "10.0.0.1"
#           port      = 80
#         }
#       }
#     }
#   }
# }

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
#     managed_storage_configuration = {
#       kms_key_id                           = aws_kms_key.ecs_managed_storage.arn
#       fargate_ephemeral_storage_kms_key_id = aws_kms_key.ecs_fargate_ephemeral.arn
#     }
#   }

#   services = {
#     for service_key, service in each.value.services : service_key => merge(
#       service,
#       {
#         service_connect_configuration = try(
#           service.service_connect_configuration != null ? merge(
#             service.service_connect_configuration,
#             {
#               service = [
#                 for svc in service.service_connect_configuration.service : merge(
#                   svc,
#                   {
#                     tls = merge(
#                       svc.tls,
#                       {
#                         role_arn = aws_iam_role.tls_role.arn,
#                         issuer_cert_authority = {
#                           aws_pca_authority_arn = aws_acmpca_certificate_authority.this.arn
#                         },
#                         kms_key = aws_kms_key.ecs_managed_storage.arn
#                       }
#                     )
#                   }
#                 )
#               ]
#             }
#           ) : null,
#           null
#         ),
#         load_balancer = try(
#           service.load_balancer != null ? {
#             for lb_key, lb in service.load_balancer : lb_key => merge(
#               lb,
#               {
#                 target_group_arn = module.alb[each.key].target_groups[lb.target_group_key].arn
#               }
#             )
#           } : null,
#           null
#         ),
#         vpc_lattice_configurations = try(
#           service.vpc_lattice_configurations != null ? merge(
#             service.vpc_lattice_configurations,
#             {
#               role_arn = aws_iam_role.vpc_lattice_role.arn,
#               target_group_arn = module.vpc_lattice.target_groups["your-target-group"].arn
#             }
#           ) : null,
#           null
#         )
#       }
#     )
#   }

#   tags = local.tags
# }







# module "db" {
#   source = "terraform-aws-modules/rds/aws"

#   for_each = var.dbs

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
