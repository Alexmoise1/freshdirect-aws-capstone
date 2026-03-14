# FreshDirect Cloud Infrastructure — AWS Capstone Project

**IT Bachelor's Capstone in Cloud Computing and Solutions**  
Purdue University Global | March 2026

---

## Overview

This repository documents the end-to-end AWS cloud infrastructure migration for FreshDirect, a mid-sized food distribution company. The project migrated an aging on-premises platform to a scalable, secure, and highly available cloud-native environment on Amazon Web Services, delivering production-grade infrastructure across nine units of structured development.

The standout contribution of this project is the **Cloud Operations Autonomy Agent** — an AI-powered system built on AWS Lambda and the Anthropic Claude API that autonomously detects, analyzes, and reports infrastructure anomalies without human intervention.

---

## Architecture

![FreshDirect System Architecture](architecture_diagram.png)

**Region:** us-east-1 (N. Virginia)  
**Model:** PaaS — Multi-tier, Multi-Availability Zone (us-east-1a, 1b, 1c)  
**Deployment:** Terraform Infrastructure as Code — 47 AWS resources

---

## Tech Stack

| Layer | Services |
|---|---|
| **Application** | AWS App Runner, Application Load Balancer |
| **Database** | Amazon RDS Aurora (Multi-AZ, KMS encrypted) |
| **Serverless / AI** | AWS Lambda (Python 3.12), Anthropic Claude API |
| **Security** | AWS IAM, KMS, WAF, GuardDuty, CloudTrail |
| **Messaging** | Amazon SNS, Amazon SQS |
| **Observability** | Amazon CloudWatch, AWS Backup |
| **Storage** | Amazon S3 (SSE-KMS) |
| **Identity** | Amazon Cognito, AWS Secrets Manager |
| **IaC** | Terraform (HashiCorp) |
| **DNS / Routing** | Amazon Route 53 |

---

## Key Features

### 🤖 Cloud Operations Autonomy Agent
An event-driven AI pipeline that transforms infrastructure monitoring from reactive to proactive:
- CloudWatch detects threshold breaches → SNS routes the alarm → Lambda invokes the agent
- Agent aggregates real-time context from App Runner, RDS, CloudWatch logs, and scaling events
- Anthropic Claude API performs root cause analysis and generates structured incident reports
- Reports delivered to CloudWatch logs and operations team via email simultaneously
- **Cost: ~$2/month** vs. ~$400/month equivalent on-premises monitoring

### 🏗️ Infrastructure as Code
- All 47 AWS resources provisioned through a single Terraform configuration
- Full resource tagging for governance, cost allocation, and audit traceability
- Entire environment rebuildable from scratch in under 30 minutes
- Version-controlled, environment-agnostic, and portable across AWS accounts

### 🔒 Enterprise Security (7 controls)
- IAM least-privilege roles scoped per service — no wildcard permissions
- KMS customer-managed keys for RDS Aurora and S3 at rest encryption
- TLS 1.2+ enforced end-to-end across all network segments
- AWS WAF with OWASP Top 10 managed rule set at the ALB
- GuardDuty continuous AI-driven threat detection — zero findings in production
- CloudTrail multi-region audit logging with S3 Object Lock immutability
- MFA enforced for all administrative console access

### 📈 Cost Efficiency
| | AWS (This Project) | On-Premises Equivalent |
|---|---|---|
| Monthly Cost | ~$187/mo | ~$3,450/mo |
| Annual Savings | | ~$39,156 |
| 5-Year Savings | | ~$195,780 |
| Reduction | | ~94.6% |

---

## Project Team

| Name | Role | Responsibilities |
|---|---|---|
| **Alex Moise** | Architecture Lead & AI Agent Developer | VPC, RDS, Lambda, AI Agent, Terraform |
| **Mehak Saeed** | Security & Governance Lead | IAM, KMS, GuardDuty, CloudTrail, WAF |
| **Chris Thomas** | Application & DevOps Lead | App Runner, CI/CD, Cognito, Secrets Manager |
| **Tyler Kizer** | Monitoring & Observability Lead | CloudWatch, SNS, Alarms, AWS Backup |

---

## Project Timeline

| Unit | Phase | Status |
|---|---|---|
| Unit 1 | Project Planning & Requirements | ✅ Complete |
| Unit 2 | High-Level Architecture Design | ✅ Complete |
| Unit 3 | Detailed Architecture & Security Design | ✅ Complete |
| Unit 4 | Security & Governance Deployment | ✅ Complete |
| Unit 5 | Application & Storage Integration | ✅ Complete |
| Unit 6 | Ingestion Infrastructure Validation | ✅ Complete |
| Unit 7 | Optimization & AI Agent Deployment | ✅ Complete |
| Unit 8 | Final Infrastructure Hardening | ✅ Complete |
| Unit 9 | Project Finalization & Documentation | ✅ Complete |

---

## Repository Contents

```
├── README.md                          # This file
├── architecture_diagram.png           # Full system architecture (Unit 3)
├── FreshdirectAWSCapstone.pdf         # Final capstone document (52 pages)
├── terraform/                         # Terraform IaC configuration
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/
│       ├── rds/
│       ├── lambda/
│       ├── iam/
│       ├── kms/
│       ├── sns/
│       └── cloudwatch/
├── lambda/                            # AI Agent Lambda function
│   └── freshdirect_ai_agent.py
└── screenshots/                       # AWS console validation evidence
    ├── terraform_init_plan.jpg
    ├── lambda_ai_agent_test.jpg
    ├── sns_security_alerts.jpg
    ├── iam_roles.jpg
    ├── cloudtrail_config.jpg
    ├── waf_guardduty.jpg
    ├── cloudwatch_sqs_dashboard.jpg
    ├── sns_freshfood_alerts.jpg
    └── aws_backup_resources.jpg
```

---

## AI Agent — How It Works

```
CloudWatch Alarm (threshold breach)
        ↓
SNS SecurityAlerts Topic
        ↓
Lambda FreshDirect_AI_Agent (Python 3.12)
        ↓
Aggregates: App Runner health + RDS metrics + CloudWatch logs + scaling events
        ↓
Anthropic Claude API (root cause analysis)
        ↓
┌─────────────────────┬──────────────────────────┐
│  CloudWatch Logs    │  Email: ops-alerts@       │
│  (audit trail)      │  directfreshfoods.com     │
└─────────────────────┴──────────────────────────┘
```

---

## Security Notice

Before cloning or forking this repository:
- **Never commit** `.tfstate` or `.tfstate.backup` files
- **Never commit** `.tfvars` files containing real credentials
- **Never commit** `.env` files or files containing API keys
- The `.gitignore` in this repo excludes all of the above by default

---

## Full Documentation

📄 [FreshdirectAWSCapstone.pdf](./FreshdirectAWSCapstone.pdf) — 52-page final capstone document covering all four team member sections, architecture diagrams, AWS console screenshots, cost analysis, and references.

---

## License

This project was created for academic purposes as part of the IT Bachelor's Capstone in Cloud Computing and Solutions at Purdue University Global. All AWS architecture, Terraform code, and AI Agent implementation are original work by the project team.
