module "batch" {
  # checkov:skip=CKV_TF_1: ADD REASON
  source = "terraform-aws-modules/batch/aws"
  create = try(coalesce(var.create, true), true)
  region = try(coalesce(var.region, "ap-south-1"), "ap-south-1")
  tags   = try(coalesce(var.tags, {}), {})

  compute_environments = local.compute_environments

  create_instance_iam_role               = try(coalesce(var.create_instance_iam_role, false), false)
  instance_iam_role_name                 = try(coalesce(var.instance_iam_role_name, null), null)
  instance_iam_role_use_name_prefix      = try(coalesce(var.instance_iam_role_use_name_prefix, false), false)
  instance_iam_role_path                 = try(coalesce(var.instance_iam_role_path, null), null)
  instance_iam_role_description          = try(coalesce(var.instance_iam_role_description, null), null)
  instance_iam_role_permissions_boundary = try(coalesce(var.instance_iam_role_permissions_boundary, null), null)
  instance_iam_role_additional_policies  = try(coalesce(var.instance_iam_role_additional_policies, {}), {})
  instance_iam_role_tags                 = try(coalesce(var.instance_iam_role_tags, {}), {})

  create_service_iam_role               = try(coalesce(var.create_service_iam_role, true), true)
  service_iam_role_name                 = try(coalesce(var.service_iam_role_name, null), null)
  service_iam_role_use_name_prefix      = try(coalesce(var.service_iam_role_use_name_prefix, false), false)
  service_iam_role_path                 = try(coalesce(var.service_iam_role_path, null), null)
  service_iam_role_description          = try(coalesce(var.service_iam_role_description, null), null)
  service_iam_role_permissions_boundary = try(coalesce(var.service_iam_role_permissions_boundary, null), null)
  service_iam_role_additional_policies  = try(coalesce(var.service_iam_role_additional_policies, {}), {})
  service_iam_role_tags                 = try(coalesce(var.service_iam_role_tags, {}), {})

  create_spot_fleet_iam_role               = try(coalesce(var.create_spot_fleet_iam_role, false), false)
  spot_fleet_iam_role_name                 = try(coalesce(var.spot_fleet_iam_role_name, null), null)
  spot_fleet_iam_role_use_name_prefix      = try(coalesce(var.spot_fleet_iam_role_use_name_prefix, false), false)
  spot_fleet_iam_role_path                 = try(coalesce(var.spot_fleet_iam_role_path, null), null)
  spot_fleet_iam_role_description          = try(coalesce(var.spot_fleet_iam_role_description, null), null)
  spot_fleet_iam_role_permissions_boundary = try(coalesce(var.spot_fleet_iam_role_permissions_boundary, null), null)
  spot_fleet_iam_role_additional_policies  = try(coalesce(var.spot_fleet_iam_role_additional_policies, {}), {})
  spot_fleet_iam_role_tags                 = try(coalesce(var.spot_fleet_iam_role_tags, {}), {})

  create_job_queues = try(coalesce(var.create_job_queues, true), true)
  job_queues        = try(coalesce(var.job_queues, {}), {})

  job_definitions = try(coalesce(var.job_definitions, {}), {})
  depends_on      = [aws_iam_role.batch_execution_role, aws_iam_role.task_role, aws_cloudwatch_log_group.this, aws_security_group.test]
}

################################################################################
# EventBridge Scheduler IAM Role
################################################################################

resource "aws_iam_role" "eventbridge_scheduler_role" {
  count = try(coalesce(var.create_eventbridge_scheduler, false), false) ? 1 : 0

  name        = try(coalesce(var.eventbridge_scheduler_role_name, null), null)
  name_prefix = try(coalesce(var.eventbridge_scheduler_role_use_name_prefix, false), false) ? var.eventbridge_scheduler_role_name : null
  path        = try(coalesce(var.eventbridge_scheduler_role_path, null), null)
  description = try(coalesce(var.eventbridge_scheduler_role_description, null), null)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  permissions_boundary = try(coalesce(var.eventbridge_scheduler_role_permissions_boundary, null), null)
  tags                 = try(coalesce(var.eventbridge_scheduler_role_tags, {}), {})
}

resource "aws_iam_role_policy" "eventbridge_scheduler_batch_policy" {
  count = try(coalesce(var.create_eventbridge_scheduler, false), false) ? 1 : 0

  name = try(coalesce(var.eventbridge_scheduler_policy_name, null), null)
  role = aws_iam_role.eventbridge_scheduler_role[0].id

  policy = var.event_bridge_iam_policy_json
}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler_additional_policies" {
  for_each = try(coalesce(var.create_eventbridge_scheduler, false), false) ? try(coalesce(var.eventbridge_scheduler_additional_policies, {}), {}) : {}

  role       = aws_iam_role.eventbridge_scheduler_role[0].name
  policy_arn = each.value
}

################################################################################
# EventBridge Scheduler Schedule Group
################################################################################

resource "aws_scheduler_schedule_group" "batch_scheduler_group" {
  count = try(coalesce(var.create_eventbridge_scheduler, false), false) && try(coalesce(var.create_scheduler_group, false), false) ? 1 : 0

  name = try(coalesce(var.scheduler_group_name, null), null)
  tags = try(coalesce(var.tags, {}), {})
}

################################################################################
# EventBridge Scheduler Schedule
################################################################################

resource "aws_scheduler_schedule" "batch_job_schedule" {
  for_each = try(coalesce(var.create_eventbridge_scheduler, false), false) ? try(coalesce(var.batch_schedules, {}), {}) : {}

  name                         = try(coalesce(each.value.name, each.key), each.key)
  group_name                   = try(coalesce(var.create_scheduler_group, false), false) ? aws_scheduler_schedule_group.batch_scheduler_group[0].name : try(coalesce(var.scheduler_group_name, null), null)
  description                  = try(coalesce(each.value.description, null), null)
  state                        = try(coalesce(each.value.state, null), null)
  schedule_expression          = try(coalesce(each.value.schedule_expression, null), null)
  schedule_expression_timezone = try(coalesce(each.value.schedule_expression_timezone, null), null)
  start_date                   = try(coalesce(each.value.start_date, null), null)
  end_date                     = try(coalesce(each.value.end_date, null), null)
  kms_key_arn                  = try(coalesce(each.value.kms_key_arn, null), null)

  flexible_time_window {
    mode                      = try(coalesce(each.value.flexible_time_window.mode, null), null)
    maximum_window_in_minutes = try(coalesce(each.value.flexible_time_window.maximum_window_in_minutes, null), null)
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:batch:submitJob"
    role_arn = try(coalesce(var.eventbridge_scheduler_role_arn, null), null) != null ? var.eventbridge_scheduler_role_arn : aws_iam_role.eventbridge_scheduler_role[0].arn

    input = jsonencode({
      JobName  = try(coalesce(each.value.target.job_name, null), null)
      JobQueue = try(coalesce(values(module.batch.job_queues)[0].arn, null), null)
      JobDefinition = try(
        coalesce(module.batch.job_definitions[each.value.target.job_definition_name].arn, null),
        null
      )
    })

    dynamic "retry_policy" {
      for_each = try(coalesce(each.value.target.retry_policy, null), null) != null ? [each.value.target.retry_policy] : []
      content {
        maximum_retry_attempts       = try(coalesce(retry_policy.value.maximum_retry_attempts, null), null)
        maximum_event_age_in_seconds = try(coalesce(retry_policy.value.maximum_event_age_in_seconds, null), null)
      }
    }

    dynamic "dead_letter_config" {
      for_each = try(coalesce(each.value.target.dead_letter_config, null), null) != null ? [each.value.target.dead_letter_config] : []
      content {
        arn = try(coalesce(dead_letter_config.value.arn, null), null)
      }
    }
  }

  depends_on = [module.batch]
}

resource "aws_iam_role" "batch_execution_role" {
  count = try(coalesce(var.create_execution_role, false), false) ? 1 : 0

  name        = try(coalesce(var.execution_role_name, null), null)
  name_prefix = try(coalesce(var.execution_role_use_name_prefix, false), false) ? var.execution_role_name : null
  path        = try(coalesce(var.execution_role_path, null), null)
  description = try(coalesce(var.execution_role_description, null), null)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  permissions_boundary = try(coalesce(var.execution_role_permissions_boundary, null), null)
  tags                 = try(coalesce(var.execution_role_tags, {}), {})
}

resource "aws_iam_role_policy" "execution_batch_policy" {
  count = try(coalesce(var.create_attach_policy_json, false), false) ? 1 : 0

  name = try(coalesce(var.execution_role_policy_name, null), null)
  role = aws_iam_role.batch_execution_role[0].id

  policy = try(coalesce(var.execution_role_iam_policy_json, null), null)
}

resource "aws_iam_role_policy_attachment" "execution_additional_policies" {
  for_each = try(coalesce(var.create_execution_role, false), false) ? try(coalesce(var.execution_role_additional_policies, {}), {}) : {}

  role       = aws_iam_role.batch_execution_role[0].name
  policy_arn = each.value

}

resource "aws_iam_role" "task_role" {
  count = try(coalesce(var.create_job_role, false), false) ? 1 : 0

  name        = try(coalesce(var.job_role_name, null), null)
  name_prefix = try(coalesce(var.job_role_use_name_prefix, false), false) ? var.job_role_name : null
  path        = try(coalesce(var.job_role_path, null), null)
  description = try(coalesce(var.job_role_description, null), null)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  permissions_boundary = try(coalesce(var.job_role_permissions_boundary, null), null)
  tags                 = try(coalesce(var.job_role_tags, {}), {})
}

resource "aws_iam_role_policy" "task_policy" {
  count = try(coalesce(var.create_attach_job_policy_json, false), false) ? 1 : 0

  name = try(coalesce(var.job_role_policy_name, null), null)
  role = aws_iam_role.task_role[0].id

  policy = try(coalesce(var.job_role_iam_policy_json, null), null)
}

resource "aws_iam_role_policy_attachment" "task_additional_policies" {
  for_each = try(coalesce(var.create_job_role, false), false) ? try(coalesce(var.job_role_additional_policies, {}), {}) : {}

  role       = aws_iam_role.task_role[0].name
  policy_arn = each.value

}


resource "aws_cloudwatch_log_group" "this" {
  count             = try(coalesce(var.create_cloudwatch_log_group, false), false) ? 1 : 0
  name              = try(coalesce(var.log_group_name, null), null)
  name_prefix       = try(coalesce(var.log_group_name_prefix, null), null)
  retention_in_days = try(coalesce(var.log_group_retention_in_days, null), null)
  skip_destroy      = try(coalesce(var.log_group_skip_destroy, null), null)
  log_group_class   = try(coalesce(var.log_group_class, null), null)
  kms_key_id        = try(coalesce(var.log_group_kms_key_id, null), null)


  tags = try(coalesce(var.cloud_watch_log_group_tags, {}), {})
}

resource "aws_security_group" "test" {
  count  = try(coalesce(var.create_security_group, true), true) ? 1 : 0
  vpc_id = try(coalesce(var.vpc_id, null), null)

  dynamic "ingress" {
    for_each = try(coalesce(var.ingress_rules, []), [])
    content {
      from_port   = try(coalesce(ingress.value.from_port, null), null)
      to_port     = try(coalesce(ingress.value.to_port, null), null)
      protocol    = try(coalesce(ingress.value.ip_protocol, null), null)
      cidr_blocks = try(coalesce(ingress.value.cidr_blocks, []), [])
    }
  }

  dynamic "egress" {
    for_each = try(coalesce(var.egress_rules, []), [])
    content {
      from_port   = try(coalesce(egress.value.from_port, null), null)
      to_port     = try(coalesce(egress.value.to_port, null), null)
      protocol    = try(coalesce(egress.value.protocol, null), null)
      cidr_blocks = try(coalesce(egress.value.cidr_blocks, []), [])
    }
  }

  tags = try(coalesce(var.security_group_tags, {}), {})
}
locals {
  compute_environments = {
    for k, v in var.compute_environments : k => merge(v, {
      compute_resources = merge(v.compute_resources, {
        security_group_ids = concat(
          try(v.compute_resources.security_group_ids, []),
          [aws_security_group.test[0].id] # safe to add dynamically here
        )
      })
    })
  }
}
