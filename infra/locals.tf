locals {
  name = "${var.project}-${var.environment}"
  
  vpc_cidr = var.vpc_cidr
  azs      = var.availability_zones
  
  container_name = var.container_name
  container_port = var.container_port

  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
  }
}
