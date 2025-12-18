###############################################
# Global Configuration
###############################################
create = true
region = "ap-south-1"

tags = {
  Owner     = "Shasank"
  ManagedBy = "Terraform"
  Project   = "aws-batch-rds-mysql-demo"
  Env       = "prod"
}

###############################################
# Compute Environment (Fargate)
###############################################
compute_environments = {
  mysql-batch-compute-env = {
    name = "aws-batch-mysql-prod-compute-env"

    compute_resources = {
      type          = "FARGATE"
      min_vcpus     = 0
      max_vcpus     = 8
      desired_vcpus = 0

      subnets = [
        "subnet-xxxxxxxxx"
      ]

      security_group_ids = []
    }

    state = "ENABLED"
  }
}

create_instance_iam_role          = false
instance_iam_role_use_name_prefix = false

###############################################
# IAM – Batch Service Role
###############################################
create_service_iam_role          = true
service_iam_role_name            = "aws-batch-mysql-prod-service-role"
service_iam_role_use_name_prefix = false

###############################################
# Job Queue
###############################################
create_job_queues = true
job_queues = {
  mysql-batch-job-queue = {
    name     = "mysql-batch-job-queue"
    priority = 1
    state    = "ENABLED"

    scheduling_policy_arn    = null # 👈 IMPORTANT
    create_scheduling_policy = false
    compute_environment_order = {
      mysql-batch-compute-env = {
        compute_environment_key = "mysql-batch-compute-env"
        order                   = 1
      }
    }
  }
}


###############################################
# Job Definitions
###############################################
job_definitions = {

  ###########################################
  # Inactive User Fetch Job
  ###########################################
  mysql-inactive-user-fetch-job-def = {
    name                  = "aws-batch-mysql-prod-inactive-user-fetch-job-def"
    type                  = "container"
    platform_capabilities = ["FARGATE"]

    container_properties = <<EOF
{
  "image": "987654321.dkr.ecr.ap-south-1.amazonaws.com/batchjobtest:latest",
  "command": ["powershell-scripts/powershellscript1.ps1"],
  "environment": [
    { "name": "S3_BUCKET", "value": "batchjob-db-bucket" }
  ],
  "resourceRequirements": [
    { "type": "VCPU", "value": "1" },
    { "type": "MEMORY", "value": "2048" }
  ],
  "executionRoleArn": "arn:aws:iam::987654321:role/aws-batch-mysql-prod-ecs-execution-role",
  "jobRoleArn": "arn:aws:iam::987654321:role/aws-batch-mysql-prod-job-role",
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/aws/batch/job",
      "awslogs-region": "ap-south-1",
      "awslogs-stream-prefix": "inactive-user"
    }
  }
}
EOF
  },

  ###########################################
  # User Insertion Job
  ###########################################
  mysql-user-insertion-job-def = {
    name                  = "aws-batch-mysql-prod-user-insertion-job-def"
    type                  = "container"
    platform_capabilities = ["FARGATE"]

    container_properties = <<EOF
{
  "image": "987654321.dkr.ecr.ap-south-1.amazonaws.com/batchjobtest:latest",
  "command": ["powershell-scripts/powershellscript2.ps1"],
  "environment": [
    { "name": "S3_BUCKET", "value": "batchjob-db-bucket" }
  ],
  "resourceRequirements": [
    { "type": "VCPU", "value": "1" },
    { "type": "MEMORY", "value": "2048" }
  ],
  "executionRoleArn": "arn:aws:iam::987654321:role/aws-batch-mysql-prod-ecs-execution-role",
  "jobRoleArn": "arn:aws:iam::987654321:role/aws-batch-mysql-prod-job-role",
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/aws/batch/job",
      "awslogs-region": "ap-south-1",
      "awslogs-stream-prefix": "user-insertion"
    }
  }
}
EOF
  }
}

###############################################
# EventBridge Scheduler
###############################################
create_eventbridge_scheduler = true

eventbridge_scheduler_role_name        = "aws-batch-mysql-prod-scheduler-role"
eventbridge_scheduler_role_description = "Allows EventBridge to submit AWS Batch MySQL jobs"

eventbridge_scheduler_role_tags = {
  Service = "EventBridge"
  Purpose = "BatchJobSubmission"
  Owner   = "Shasank"
  Env     = "prod"
}

create_scheduler_group = true
scheduler_group_name   = "aws-batch-mysql-prod-scheduler-group"

scheduler_group_tags = {
  Service = "EventBridge"
  Type    = "SchedulerGroup"
  Env     = "prod"
}

event_bridge_iam_policy_json = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowBatchJobSubmission",
      "Effect": "Allow",
      "Action": [
        "batch:SubmitJob",
        "batch:DescribeJobs",
        "batch:DescribeJobDefinitions"
      ],
      "Resource": [
        "arn:aws:batch:ap-south-1:987654321:job-definition/*",
        "arn:aws:batch:ap-south-1:987654321:job-queue/*"
      ]
    },
    {
      "Sid": "AllowPassBatchRoles",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::987654321:role/aws-batch-mysql-prod-ecs-execution-role",
        "arn:aws:iam::987654321:role/aws-batch-mysql-prod-job-role"
      ]
    }
  ]
}
POLICY

###############################################
# Batch Job Schedules
###############################################
###############################################
# Batch Job Schedules
###############################################
batch_schedules = {

  ###########################################
  # Inactive User Fetch Job (ONE TIME)
  ###########################################
  inactive_user_fetch_schedule = {
    name        = "aws-batch-mysql-prod-inactive-user-fetch-schedule"
    description = "One-time MySQL inactive user fetch batch job"
    state       = "ENABLED"

    # Runs once on 20 Dec 2025 at 02:00 IST
    schedule_expression          = "cron(3 0 16 12 ? 2025)"
    schedule_expression_timezone = "Asia/Kolkata"


    flexible_time_window = {
      mode = "OFF"
    }

    target = {
      job_name = "mysql-inactive-user-fetch-job"

      # MUST MATCH job_definitions MAP KEY
      job_definition_name = "mysql-inactive-user-fetch-job-def"

    }
  },

  ###########################################
  # User Insertion Job (ONE TIME)
  ###########################################
  user_insertion_schedule = {
    name        = "aws-batch-mysql-prod-user-insertion-schedule"
    description = "One-time MySQL user insertion batch job"
    state       = "ENABLED"

    # Runs once on 20 Dec 2025 at 02:30 IST
    schedule_expression          = "cron(3 0 16 12 ? 2025)"
    schedule_expression_timezone = "Asia/Kolkata"


    flexible_time_window = {
      mode = "OFF"
    }

    target = {
      job_name = "mysql-user-insertion-job"

      # MUST MATCH job_definitions MAP KEY
      job_definition_name = "mysql-user-insertion-job-def"
    }
  }
}




###############################################
# Execution Role (ECS Task Execution)
###############################################
create_execution_role      = true
execution_role_name        = "aws-batch-mysql-prod-ecs-execution-role"
execution_role_path        = "/"
execution_role_description = "ECS execution role for AWS Batch MySQL jobs"
create_attach_policy_json  = false

execution_role_policy_name = "aws-batch-mysql-prod-ecs-execution-policy"
execution_role_additional_policies = {
  ecs_execution = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

###############################################
# Job Role (Batch Job Containers)
###############################################
create_job_role               = true
job_role_name                 = "aws-batch-mysql-prod-job-role"
job_role_path                 = "/"
job_role_description          = "Job role for AWS Batch MySQL containers"
create_attach_job_policy_json = true

job_role_policy_name = "aws-batch-mysql-prod-job-policy"

job_role_iam_policy_json = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowMySQLSecretsAccess",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:ap-south-1:987654321:secret:prod/secret1-oabOvB"
    },
    {
      "Sid": "AllowBatchS3Access",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::batchjob-db-bucket",
        "arn:aws:s3:::batchjob-db-bucket/*"
      ]
    }
  ]
}
POLICY

create_security_group = true
vpc_id                = "vpc-0e25dd72c9e07eed7"
security_group_tags = {
  Owner     = "Shasank"
  ManagedBy = "Terraform"
}
ingress_rules = []
egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

create_cloudwatch_log_group = true
log_group_name              = "/aws/batch/job"
log_group_class             = "STANDARD"
cloud_watch_log_group_tags = {
  Owner     = "Shasank"
  ManagedBy = "Terraform"
}