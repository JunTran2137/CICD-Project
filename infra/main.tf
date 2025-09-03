module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  # Cluster configuration
  cluster_name = local.name  
  cluster_service_connect_defaults = {
    namespace = aws_service_discovery_http_namespace.this.arn
  }

  # Infrastructure
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  # Monitoring
	cluster_setting = [
		{
			name	= "containerInsights"
			value = "enabled"
		}
	]
  
  # Encryption 
  cluster_configuration = {
    managed_storage_configuration = {
      kms_key_id                           = aws_kms_key.ecs_managed_storage.arn
      fargate_ephemeral_storage_kms_key_id = aws_kms_key.ecs_fargate_ephemeral.arn
    }
  }

  services = {
    cicd-lab-frontend = {
      # Task definition family
      family = "${local.name}-frontend"

      # Launch type
      requires_compatibilities = ["FARGATE"]

      # OS, Architecture, Network mode
      runtime_platform = {
				operating_system_family = "LINUX"
				cpu_architecture = "X86_64"
			}
      # network_mode = "awsvpc"

      # Task size
      cpu    = 1024
      memory = 3072		

      # Task roles
      tasks_iam_role_name = "${local.name}-frontend"
      tasks_iam_role_description = "Example tasks IAM role for ${local.name}"
      tasks_iam_role_tags = local.tags
      tasks_iam_role_policies = { 
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess" 
      }

      # Task execution role
      task_exec_secret_arns = []

      # Fault injection
			enable_fault_injection = false
      
      container_definitions = {
        container-1 = {
          # Container details
					name 		  = local.container_name
					image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
					essential = true

          # Private registry
          repositoryCredentials = {
            # credentialsParameter = null
          }
          # Port mappings
					portMappings = [
            {
              containerPort = local.container_port
              protocol      = "tcp"
              name          = local.container_name
              appProtocol   = "http"              
            }
          ]
          
          # Read only root file system
					readonlyRootFilesystem = false

          # Resource allocation limits
					cpu       = 512
          memory    = 1024
					memoryReservation = 512

          # Environment variables
          environment = [
            # {
            #   name  = null
            #   value = null
            # }
          ]
          environmentFiles = [
            # {
            #   type  = null
            #   value = null
            # }
          ]

          # Log collection
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              "awslogs-group"         = "/ecs/"
              "awslogs-region"        = "ap-southeast-2"
              "awslogs-stream-prefix" = "ecs"
              "awslogs-create-group"  = "true"
            }
          }

          # Restart policy
          restartPolicy = {
            enabled                   = false
            ignoredExitCodes         = []
            restartAttemptPeriod     = null
          }

          # HealthCheck
          healthCheck = {
            command     = []
            interval    = null
            timeout     = null
            startPeriod = null
            retries     = null
          }

          # Container timeouts
          startTimeout = null
          stopTimeout  = null
          
          # Docker configuration
          entryPoint      = []
          command         = []
          workingDirectory = null

          # Ulimits
          ulimits = [
            # {
            #   name      = null
            #   softLimit = null
            #   hardLimit = null
            # }          
          ]

          # Docker labels
          dockerLabels    = {}
        }
      }

      # Ephemeral storage
			ephemeral_storage = { 
        # size_in_gib = null
      }

      # Volume
			volume = {
        "efs" = {
          name = "efs-storage"
          configure_at_launch = false
          efs_volume_configuration = {
            file_system_id          = "fs-12345678"
            root_directory          = "/data"
            authorization_config = {
              access_point_id = "fsap-12345678"
              iam             = "ENABLED"
            }
            transit_encryption      = "ENABLED"
            transit_encryption_port = 2049
          }
        }
      }

      # Container mount points
      mountPoints = [
        {
          sourceVolume  = "efs-volume"
          containerPath = "/app/data"
          readOnly      = false
        }
      ]

      # Volumes from
      volumesFrom = [
        # {
        #   sourceContainer = "data-container"
        #   readOnly        = true
        # }
      ]

      # Task definition tags
			task_tags = local.tags

			# Service name
			name = "${local.name}-frontend"

      # Compute configuration
      capacity_provider_strategy = {
        fargate = {
          capacity_provider = "FARGATE"
          base              = 0
          weight            = 1
        }
      }
      platform_version = "LATEST"

			# Deployment configuration
			scheduling_strategy = "REPLICA"
			desired_count      = 1
			availability_zone_rebalancing = "ENABLED"
			health_check_grace_period_seconds = 0

      # Deployment options
      deployment_controller = {
        type = "ECS"
      }
      deployment_configuration = {
        strategy = "ROLLING"
      }
      deployment_minimum_healthy_percent = 100
      deployment_maximum_percent = 200
      
      # Deployment failure detection
      deployment_circuit_breaker = {
        enable   = true
        rollback = true
      }
      alarms = {
        enable      = true
        alarm_names = ["my-alarm-name"]
        rollback    = true
      }

			# Networking
			subnet_ids				 = module.vpc.private_subnets
			security_group_ids = [module.sg-ecs.security_group_id]
			assign_public_ip = false

			# Srvice Connect 
      service_connect_configuration = {
        enabled   = true
        namespace = aws_service_discovery_http_namespace.this.arn
        service = [
          {
            port_name      = local.container_name
            discovery_name = local.container_name
            client_alias = {
              dns_name = local.container_name
              port     = local.container_port
            }

            tls = {
              role_arn = module.tls_role.iam_role_arn
              issuer_cert_authority = {
                aws_pca_authority_arn = aws_acmpca_certificate_authority.this.arn
              }
              kms_key = module.tls_role.kms_key_arn
            }

            timeout = {
              idle_timeout_seconds = 3600
            }

            log_configuration = {
              log_driver = "awslogs"
              options = {
                "awslogs-group"         = "/ecs/aaa-service-r042kp2x"
                "awslogs-region"        = "ap-southeast-2"
                "awslogs-stream-prefix" = "ecs"
                "awslogs-create-group"  = "true"
              }
            }
          }
        ]
      }

      # Load balancing
      load_balancer = {
        service = {
          container_name   = local.container_name
          container_port   = local.container_port
          target_group_arn = module.alb.target_groups["ex_ecs"].arn
        }
      }

      # VPC Lattice
      vpc_lattice_configurations = {
        role_arn         = aws_iam_role.vpc_lattice_role.arn
        target_group_arn = module.vpc_lattice.target_groups["your-target-group"].arn
        port_name        = local.container_name
      }
      
      # Service auto scaling
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 10
      autoscaling_policies = {
        cpu_target_tracking = {
          policy_type = "TargetTrackingScaling"
          name        = "ECSServiceMetric"
          target_tracking_scaling_policy_configuration = {
            predefined_metric_specification = {
              predefined_metric_type = "ECSServiceAverageCPUUtilization"
            }
            target_value       = 70.0
            scale_out_cooldown = 300
            scale_in_cooldown  = 300
            disable_scale_in   = false
          }
        }
      }

      service_tags = local.tags
    }
  }

  tags = local.tags
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

	load_balancer_type = "application"
  name               = local.name
	internal           = false
	ip_address_type    = "ipv4"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
	security_groups    = [module.sg-alb.security_group_id]

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
		ecs = {
			target_type      = "ip"
			name             = "cicd-lab"
			protocol         = "HTTP"
			port             = 80
			ip_address_type	 = "ipv4"
			vpc_id           = module.vpc.vpc_id
			protocol_version = "HTTP1"

			health_check = {
				enabled             = true
				protocol            = "HTTP"
				path                = "/"
				port                = "traffic-port"
				healthy_threshold   = 5
				unhealthy_threshold = 2
				timeout             = 5				
				interval            = 30
				matcher             = "200"
			}

			tags = local.tags
		}
  }

  tags = local.tags
}

module "sg-alb" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.name}-alb"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["https-443-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_with_source_security_group_id = [ 
		{
			rule = "all-all"
		}
	 ]

	tags = local.tags
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs                 = local.azs
  private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  enable_nat_gateway = false
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  engine                   = "postgres"
  engine_version           = "14"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  
  identifier = local.name

  
  instance_class           = "db.t4g.large"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "completePostgresql"
  username = "complete_postgresql"
  port     = 5432

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
