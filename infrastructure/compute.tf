resource "aws_launch_template" "web_template" {
  name_prefix   = "web-server-template"
  image_id      = "ami-0c101f26f147fa7fd"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.web_server_key.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF
  )

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
  vpc_zone_identifier = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}