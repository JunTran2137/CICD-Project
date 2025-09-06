module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  for_each = var.ecs_clusters

  cluster_name = each.value.cluster_name 
  cluster_service_connect_defaults = {
    namespace = aws_service_discovery_http_namespace.this.arn
  }
  default_capacity_provider_strategy = each.value.default_capacity_provider_strategy
  cluster_setting                    = each.value.cluster_setting
  cluster_configuration              = each.value.cluster_configuration
  services                           = each.value.services

  tags = local.tags
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  for_each = var.albs

	load_balancer_type = each.value.load_balancer_type
  name               = each.value.name
	internal           = each.value.internal
	ip_address_type    = each.value.ip_address_type
  vpc_id             = module.vpc[each.value.vpc_key].vpc_id
  subnets            = module.vpc[each.value.vpc_key].public_subnets
  security_groups    = [module.sg[each.value.sg_key].security_group_id]

  listeners = each.value.listeners

  target_groups = each.value.target_groups

  tags = each.value.tags
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  for_each = var.sgs

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc[each.value.vpc_key].vpc_id

  ingress_cidr_blocks = each.value.ingress_cidr_blocks
  ingress_rules       = each.value.ingress_rules

  egress_rules                         = each.value.egress_rules
  egress_with_source_security_group_id = each.value.egress_with_source_security_group_id

  tags = each.value.tags
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  for_each = var.vpcs

  name = each.value.name
  cidr = each.value.cidr

  azs              = each.value.azs
  private_subnets  = each.value.private_subnets
  public_subnets   = each.value.public_subnets

  enable_nat_gateway     = each.value.enable_nat_gateway
  single_nat_gateway     = each.value.single_nat_gateway
  one_nat_gateway_per_az = each.value.one_nat_gateway_per_az

  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support

  tags = each.value.tags
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  engine                   = "postgres"
  engine_version           = "14"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  
  identifier = local.name

  
  instance_class           = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  port     = var.db_port

  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(15 days)"

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  family                   = "postgres14" # DB parameter group
  major_engine_version     = "14"         # DB option group


  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  cloudwatch_log_group_tags = {
    "Sensitive" = "high"
  }
}
