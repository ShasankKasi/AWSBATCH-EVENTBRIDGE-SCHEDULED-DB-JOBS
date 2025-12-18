################################################################################
# Compute Environment(s)
################################################################################

output "compute_environments" {
  description = "Map of compute environments created and their associated attributes"
  value       = module.batch.compute_environments
}

################################################################################
# Compute Environment - Instance Role
################################################################################

output "instance_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.batch.instance_iam_role_name
}

output "instance_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.batch.instance_iam_role_arn
}

output "instance_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.batch.instance_iam_role_unique_id
}

output "instance_iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.batch.instance_iam_instance_profile_arn
}

output "instance_iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.batch.instance_iam_instance_profile_id
}

output "instance_iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.batch.instance_iam_instance_profile_unique
}

################################################################################
# Compute Environment - Service Role
################################################################################

output "service_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.batch.service_iam_role_name
}

output "service_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.batch.service_iam_role_arn
}

output "service_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.batch.service_iam_role_unique_id
}

################################################################################
# Compute Environment - Spot Fleet Role
################################################################################

output "spot_fleet_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.batch.spot_fleet_iam_role_name
}

output "spot_fleet_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.batch.spot_fleet_iam_role_arn
}

output "spot_fleet_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.batch.spot_fleet_iam_role_unique_id
}

################################################################################
# Job Queue
################################################################################

output "job_queues" {
  description = "Map of job queues created and their associated attributes"
  value       = module.batch.job_queues
}

################################################################################
# Scheduling Policy
################################################################################

output "scheduling_policies" {
  description = "Map of scheduling policies created and their associated attributes"
  value       = module.batch.scheduling_policies
}

################################################################################
# Job Definitions
################################################################################

output "job_definitions" {
  description = "Map of job definitions created and their associated attributes"
  value       = module.batch.job_definitions
}

################################################################################
# EventBridge Scheduler
################################################################################
output "eventbridge_scheduler_role_arn" {
  description = "ARN of the IAM role assumed by EventBridge Scheduler"
  value       = try(aws_iam_role.eventbridge_scheduler_role[0].arn, null)
}

output "eventbridge_scheduler_role_name" {
  description = "Name of the EventBridge Scheduler role"
  value       = try(aws_iam_role.eventbridge_scheduler_role[0].name, null)
}

output "eventbridge_scheduler_group_name" {
  description = "Name of the EventBridge Scheduler group"
  value       = try(aws_scheduler_schedule_group.batch_scheduler_group[0].name, null)
}

################################################################################
# Batch Execution Role
################################################################################
output "batch_execution_role_arn" {
  description = "ARN of the Batch execution IAM role"
  value       = try(aws_iam_role.batch_execution_role[0].arn, null)
}

################################################################################
# Batch Task Role
################################################################################
output "batch_task_role_arn" {
  description = "ARN of the IAM role assumed by Batch tasks"
  value       = try(aws_iam_role.task_role[0].arn, null)
}

//CloudWatch Log Group Outputs


output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group"
  value       = try(aws_cloudwatch_log_group.this[0].arn, null)
}
