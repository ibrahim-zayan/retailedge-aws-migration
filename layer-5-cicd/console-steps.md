# Layer 5 — CI/CD Pipeline & Go-Live (Console Steps)

## Task 5.1 — GitHub Actions Pipeline

Added a `Dockerfile` at the repo root to containerize the PHP
application (based on `php:8.2-apache`, listening on port 8080).

Created `.github/workflows/deploy.yml` with 3 jobs:
- **test**: runs a basic PHP syntax check
- **build**: builds the Docker image and pushes it to Amazon ECR,
  authenticating via OIDC (no static AWS credentials stored)
- **deploy**: triggers an Auto Scaling Group instance refresh to
  roll out the new image, gated behind a manual approval
  (GitHub Environment with required reviewers), with automatic
  rollback on failure

Note: the AWS-side wiring (OIDC identity provider, IAM role, and
GitHub environment approval) was designed and documented but not
provisioned on a real AWS account, since this is a simulation with
no production AWS credentials to protect.

## Task 5.2 — CloudWatch Alarms

| Alarm | Status |
|---|---|
| `retailedge-alb-unhealthy-hosts` (UnHealthyHostCount > 0) | Created |
| `retailedge-alb-high-latency` (TargetResponseTime > 0.8s) | Created |
| `retailedge-db-cpu-spike` (RDS CPUUtilization > 80%) | Created |
| High Error Rate (ALB 5xx rate > 1%) | Documented only — no 5xx events have occurred yet, so CloudWatch has no data points for this metric to alarm on |
| Low Cache Hit Rate (ElastiCache hit rate < 70%) | Documented only — requires a Metric Math expression (CacheHits / (CacheHits + CacheMisses)) since ElastiCache doesn't expose a hit-rate metric directly |

All alarms notify via a shared SNS topic.

## Task 5.3 — Go-Live Checklist

**5 things to verify before flipping DNS:**

1. **Database sync** — replication lag between the old database and
   the new RDS instance is near zero (under 5 seconds)
2. **Application health** — the ALB reports all ASG instances as
   Healthy, and the app responds correctly to real requests
3. **Network and security** — security groups (alb-sg, app-sg,
   rds-sg) allow the correct traffic with no unexpected blocks
4. **Monitoring is live** — CloudWatch alarms are active and
   connected to SNS, so issues are caught before customers notice
5. **Rollback plan is ready** — the rollback plan is not just
   written but actually executable quickly if something goes wrong
   after cutover

**Safe DNS cutover using Route 53 Weighted Routing:**

Instead of switching 100% of traffic at once, Route 53 splits new
DNS resolutions between the old on-premises server and the new AWS
environment by weight (e.g. 90% old / 10% new on day one). If the
new environment proves stable, the weight shifts gradually (50/50,
then 10/90, then 100% AWS) over several days. This limits the blast
radius of any undiscovered issue in the new environment — only a
small percentage of users are affected at each stage, rather than
everyone at once.

## Task 5.4 (Bonus) — Cost Optimization Report

[هنضيفها بعد ما نخلص Task 5.4]
