output "ecr_repo_url" {
  description = "ECR Repository URL"
  value       = {for k, v in module.ecr : k => v.repository_url}
}

# output "ecs_service_name" {
#   description = "ECS Service Name"
#   value       = {for k, v in module.ecs : k => values({for k1, v1 in v.services : k1 => v1.name})}
# }

# output "task_definition_arn" {
#   description = "ECS Task Definition ARN"
#   value       = {for k, v in module.ecs : k => values({for k1, v1 in v.services : k1 => v1.task_definition_arn})}
# }

# output "container_name" {
#   description = "ECS Container Name"
#   value = {
#     for k, v in module.ecs : k => values({
# 			for k1, v1 in v.services : k1 => values({
# 				for k2, v2 in v1.container_definitions : k2 => 
# 					v2.container_definition.name
# 			})
# 		})
# 	}
# }


output "ecs_info" {
  description = "ECS Services Info including service name, task definition ARN, and container names"
  value = {
    for k, v in module.ecs : k => {
			cluster_name = v.cluster_name
			
			services = {
				for k1, v1 in v.services : k1 => {
					service_name        = v1.name
					task_definition_arn = v1.task_definition_arn
					container_names     = [for k2, v2 in v1.container_definitions : v2.container_definition.name]
				}
			}
    }
  }
}