resource "aws_launch_template" "web_template" {
  name_prefix   = "web-server-template"
  image_id      = "ami-0c101f26f147fa7fd"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.web_server_key.key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl start nginx
    systemctl enable nginx

    yum install -y amazon-cloudwatch-agent
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
    
    cat <<EOC > /opt/aws/amazon-cloudwatch-agent/etc/config.json
    ${file("cw_config.json")}
    EOC
    
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json -s
  EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.app_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-asg"
    }
  }
}

resource "aws_ec2_instance_connect_endpoint" "eice_a" {
  subnet_id          = aws_subnet.private_app_a.id
  security_group_ids = [aws_security_group.connectivity_sg.id]
}

resource "aws_ec2_instance_connect_endpoint" "eice_b" {
  subnet_id          = aws_subnet.private_app_b.id
  security_group_ids = [aws_security_group.connectivity_sg.id]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
  security_group_ids  = [aws_security_group.connectivity_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
  security_group_ids  = [aws_security_group.connectivity_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
  security_group_ids  = [aws_security_group.connectivity_sg.id]
  private_dns_enabled = true
}

resource "aws_key_pair" "web_server_key" {
  key_name   = "web-server-key"
  public_key = file("${path.module}/ssh-keys/id_rsa_webserver.pub")
}

resource "aws_autoscaling_group" "web_asg" {
  vpc_zone_identifier = [aws_subnet.private_app_a.id,aws_subnet.private_app_b.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}