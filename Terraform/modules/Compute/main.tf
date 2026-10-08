# =========================
# Launch Template
# =========================

resource "aws_launch_template" "app" {
  name_prefix   = "retailedge-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.app_security_group_id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash

    yum update -y
    yum install -y httpd

    sed -i 's/^Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
      <title>RetailEdge</title>
    </head>
    <body>
      <h1>RetailEdge Application Server</h1>
      <p>Server is running successfully.</p>
    </body>
    </html>
    HTML

    systemctl enable httpd
    systemctl start httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "retailedge-app"
    }
  }
}


# =========================
# Application Load Balancer
# =========================

resource "aws_lb" "app" {
  name               = "retailedge-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = var.public_subnet_ids

  security_groups = [
    var.alb_security_group_id
  ]

  tags = {
    Name = "retailedge-alb"
  }
}


# =========================
# Target Group
# =========================

resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "app-target-group"
  }
}


# =========================
# ALB Listener
# =========================

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.app.arn
      }
    }
  }
}


# =========================
# Auto Scaling Group
# =========================

resource "aws_autoscaling_group" "app" {
  name = "retailedge-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.app_subnet_ids

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 90
    }
  }

  tag {
    key                 = "Name"
    value               = "retailedge-app"
    propagate_at_launch = true
  }
}


# =========================
# CPU Target Tracking
# =========================

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "retailedge-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}
resource "aws_autoscaling_schedule" "friday_peak" {
  scheduled_action_name  = "friday-peak-scale-up"
  autoscaling_group_name = aws_autoscaling_group.app.name
  min_size               = 2
  max_size               = 10
  desired_capacity       = 6
  recurrence             = "0 20 * * 5"
  time_zone              = "UTC"
}