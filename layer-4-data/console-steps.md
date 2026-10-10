# Layer 4 — Data Layer & Migration (Console Steps)

## Task 4.1 — RDS Multi-AZ + ElastiCache

Created an RDS MySQL instance (`retailedge-db`) with Multi-AZ enabled
(primary in us-east-1a, secondary in us-east-1b), db.t3.medium,
100 GiB gp3 storage, storage encryption enabled, and 7-day backup
retention. Adjusted monitoring from Advanced to Standard Database
Insights to control cost.

![RDS Configuration](./rds-configuration.png)

Created an ElastiCache Redis cluster (`retailedge-cache`) with
cache.t4g.small nodes, 2 total nodes (1 primary + 1 replica),
Multi-AZ enabled, auto-failover enabled, and encryption enabled
both at-rest and in-transit.

![ElastiCache Configuration](./elasticache-configuration.png)

## Task 4.3 — Answers

**What is the difference between RPO and RTO?**

RPO (Recovery Point Objective) is how much data, measured in time,
an organization can afford to lose in a failure — it answers "how
far back can our last good backup be?" RTO (Recovery Time Objective)
is how long the system can stay down before recovering — it answers
"how fast do we need to be back online?"

**Based on our configuration, what are the expected RPO and RTO
values?**

With RDS Multi-AZ using synchronous replication, RPO is close to
zero (seconds) since data is written to both the primary and
standby before a transaction is confirmed. RTO is typically under
2 minutes, since Multi-AZ failover is automatic and does not
require manual intervention.

## Task 4.4 (Bonus) — Why ElastiCache alongside RDS

ElastiCache reduces how often the application needs to query RDS
directly. Reading data from memory (RAM) is much faster than reading
from a database. When the same data (like a popular product's
details, or a frequent search result) is requested thousands of
times per hour, there's no need to hit RDS every single time —
instead, the first request fetches it from RDS and stores it in the
cache, and every subsequent request for the same data is served
directly from the cache, which is much faster and reduces load on RDS.

### Cache Hit / Cache Miss Flow

1. The application requests data and checks ElastiCache first.
2. **Cache hit:** the data is already in the cache, so it's returned
   immediately without touching RDS at all.
3. **Cache miss:** the data isn't in the cache, so the application
   queries RDS, fetches the result, saves it into the cache for next
   time, then returns it to the user.

As the cache hit rate increases, load on RDS decreases and response
times improve for users.

## Design Correction — Dedicated Security Group for ElastiCache

The ElastiCache cluster was originally attached to `rds-sg` (port 3306),
but Redis listens on port 6379. The corrected design uses a dedicated
`cache-sg` that allows port 6379 from `app-sg` only.
Details: [layer-2-network/console-steps.md](../layer-2-network/console-steps.md)
