resource "aws_db_subnet_group" "this" {
  name       = "retailedge-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "retailedge-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "retailedge-db"
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  db_name                = "retailedge"
  username               = "admin"

  manage_master_user_password = true

  multi_az                = true
  storage_encrypted       = true
  backup_retention_period = 7

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]

  skip_final_snapshot = true

  tags = {
    Name = "retailedge-db"
  }
}
resource "aws_elasticache_subnet_group" "this" {
  name       = "retailedge-cache-subnet-group"
  subnet_ids = var.db_subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "retailedge-cache"
  description          = "RetailEdge Redis cache"

  engine               = "redis"
  node_type            = "cache.t4g.small"
  num_cache_clusters   = 2
  port                 = 6379
automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  subnet_group_name = aws_elasticache_subnet_group.this.name

  tags = {
    Name = "retailedge-cache"
  }
}
    