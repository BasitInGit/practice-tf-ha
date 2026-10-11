resource "aws_launch_template" "practice_app_ha" {
  name          = "practice-app-ha"
  description   = "Launch template for web application instances"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.practice_ha_profile.id
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.practice_ec2_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforces IMDSv2
    http_put_response_hop_limit = 1
  }

  user_data = filebase64("userdata.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "practice-app"
      Environment = "dev"
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_autoscaling_group" "practice_ha_asg" {
  name_prefix      = "practice-ha-asg-"
  desired_capacity = 3
  min_size         = 3
  max_size         = 6

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.practice_app_ha.id
    version = "$Latest"
  }

  # Health check settings
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.practice_ha_tg.arn]

}
