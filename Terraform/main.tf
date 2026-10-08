data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

module "network" {
  source = "./modules/Network"
}

module "compute" {
  source = "./modules/Compute"

  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size
  app_port         = var.app_port
  alb_port         = var.alb_port
  ami_id           = data.aws_ami.amazon_linux.id

  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  app_subnet_ids        = module.network.app_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  app_security_group_id = module.network.app_security_group_id
}
module "data" {
  source = "./modules/Data"

  db_subnet_ids        = module.network.db_subnet_ids
  db_security_group_id = module.network.db_security_group_id
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
}