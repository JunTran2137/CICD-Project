variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "container_name" {
  description = "Container name"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
}

variable "container_memory" {
  description = "Container memory"
  type        = number
}

variable "container_memory_reservation" {
  description = "Container memory reservation"
  type        = number
}

variable "service_desired_count" {
  description = "Number of desired tasks"
  type        = number
}

variable "autoscaling_min_capacity" {
  description = "Minimum autoscaling capacity"
  type        = number
}

variable "autoscaling_max_capacity" {
  description = "Maximum autoscaling capacity"
  type        = number
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for RDS in GB"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}
