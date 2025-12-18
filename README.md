# AWS Batch + EventBridge Scheduler – Scheduled Database Jobs

This repository contains a reference implementation for running **scheduled and ad-hoc database workloads on AWS** using **AWS Batch with Fargate** and **EventBridge Scheduler**.

The solution demonstrates how to:
- Run containerized SQL workloads as Batch jobs
- Trigger jobs using cron or one-time schedules via EventBridge Scheduler
- Execute workloads in private subnets using Fargate
- Securely fetch database credentials from AWS Secrets Manager
- Capture execution logs using CloudWatch Logs and store outputs in Amazon S3

All infrastructure is provisioned using **Terraform**, and workloads are packaged as Docker images.

---

## 📖 Full Documentation

The complete architecture, Terraform implementation, security model, and troubleshooting details are explained in the blog post:

👉 **Running Scheduled Database Workloads Using AWS Batch and EventBridge Scheduler**  
🔗 *<BLOG_URL_HERE>*

---

## 🏗️ Architecture (High Level)

EventBridge Scheduler → AWS Batch Job Queue → Fargate Compute Environment  
→ Containerized PowerShell workload → Database (RDS)  
→ Logs in CloudWatch, outputs in S3

---

## 📂 Repository Structure

.
```text
├── infra/
│   ├── main.tf                 # AWS Batch, EventBridge, IAM, networking
│   ├── variables.tf            # Terraform input variables
│   ├── outputs.tf              # Terraform outputs
│   ├── versions.tf             # Provider and Terraform version constraints
│   └── terraform.tfvars        # Environment-specific values
│
├── workloads/
│   ├── Dockerfile              # PowerShell-based batch workload image
│   ├── powershell-scripts/     # PowerShell scripts executed by Batch jobs
│   └── queryFiles/             # SQL queries executed against the database
│
└── README.md

```
---

## 📌 Notes

- This repository is intended as a **reference architecture**, not a reusable Terraform module
- An existing database and S3 bucket are required
- See the blog post for setup, deployment, and troubleshooting details


