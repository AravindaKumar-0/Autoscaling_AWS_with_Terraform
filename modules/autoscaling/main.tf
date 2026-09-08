resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-"
  image_id      = "ami-0b6d9d3d33ba97d99"
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.app_security_group_id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash

dnf update -y
dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>DevOps Auto Scaling</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: linear-gradient(135deg, #eef2ff, #f8fafc);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .container {
            width: 90%;
            max-width: 700px;
            background: white;
            padding: 50px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
        }

        h1 {
            margin-bottom: 10px;
            font-size: 36px;
        }

        .subtitle {
            color: #64748b;
            font-size: 18px;
            margin-bottom: 35px;
        }

        .status {
            display: inline-block;
            padding: 12px 24px;
            border-radius: 30px;
            background: #dcfce7;
            color: #166534;
            font-weight: bold;
            margin-bottom: 30px;
        }

        .architecture {
            text-align: left;
            background: #f8fafc;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 25px;
        }

        .architecture p {
            margin: 12px 0;
        }

        .footer {
            color: #94a3b8;
            font-size: 14px;
            margin-top: 25px;
        }
    </style>
</head>

<body>

    <div class="container">

        <h1>DevOps Auto Scaling</h1>

        <div class="subtitle">
            AWS Infrastructure Automation
        </div>

        <div class="status">
            Application Running
        </div>

        <div class="architecture">

            <p><strong>Infrastructure</strong></p>

            <p>Terraform → Jenkins → AWS</p>

            <p>ALB → Auto Scaling Group → EC2</p>

            <p>Multi-AZ Architecture</p>

        </div>

        <p>
            This application is running behind an
            <strong>Application Load Balancer</strong>
            and an <strong>Auto Scaling Group</strong>.
        </p>

        <div class="footer">
            Terraform Auto Scaling Project
        </div>

    </div>

</body>
</html>
HTML

systemctl restart httpd
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }

    triggers = [
      "launch_template"
    ]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project_name}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70
  }
}
