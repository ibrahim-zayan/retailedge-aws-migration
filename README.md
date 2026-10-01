# RetailEdge — AWS Migration Project

Solutions Architect simulation: migrating a mid-size e-commerce company
from 3 bare-metal servers to a Multi-AZ, Three-Tier AWS architecture.

## Layer 1 — Architecture Design

Designed a Multi-AZ, three-tier AWS architecture and evaluated
migration strategy per component (Rehost for web/app, Replatform
for the database). TCO analysis projected ~74% cost reduction over
3 years compared to the current on-premises setup.

Full details: [layer-1-design/console-steps.md](./layer-1-design/console-steps.md)

---

## Layer 2 — Network Foundation & Security

Built a VPC (10.0.0.0/16) with 6 subnets across 2 Availability Zones,
an Internet Gateway, 2 NAT Gateways, and 4 route tables enforcing
strict tier isolation (public, private, database). Created 3
chained security groups (alb-sg → app-sg → rds-sg) so each tier only
accepts traffic from the tier directly in front of it.

Full details: [layer-2-network/console-steps.md](./layer-2-network/console-steps.md)

## Layer 3 — Compute & Auto Scaling

Built a Launch Template, Application Load Balancer, Target Group,
and Auto Scaling Group (min=2, max=10) serving a PHP application on
port 8080 behind the ALB on port 80. Configured a target tracking
scaling policy (60% CPU) and a scheduled scaling action for Friday
evenings, then verified the site serves traffic correctly through
the ALB.

Full details: [layer-3-compute/console-steps.md](./layer-3-compute/console-steps.md)

## Layer 4 — Data Layer & Migration

Provisioned RDS MySQL Multi-AZ (`retailedge-db`) with encrypted
storage and 7-day backups, plus an ElastiCache Redis cluster
(`retailedge-cache`) with Multi-AZ and encryption enabled. Wrote a
4-phase migration cutover plan (Full Load, CDC, Cutover, Rollback)
achieving near-zero RPO and under 2-minute RTO.

Full details: [layer-4-data/console-steps.md](./layer-4-data/console-steps.md) | [Migration Plan](./layer-4-data/migration_plan.md)

## Layer 5 — CI/CD Pipeline & Go-Live

Containerized the application with Docker and built a GitHub
Actions pipeline (test → build → deploy) using OIDC authentication,
manual approval, and automatic rollback. Created CloudWatch alarms
for latency, error rate, database CPU, and cache hit rate, with SNS
notifications. Wrote a Go-Live checklist and a safe DNS cutover plan
using Route 53 weighted routing.

Full details: [layer-5-cicd/console-steps.md](./layer-5-cicd/console-steps.md)
