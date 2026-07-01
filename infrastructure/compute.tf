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
  EOF
  )

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