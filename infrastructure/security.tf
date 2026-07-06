//Should be used after the domain is validated and the certificate is issued. (add the domain_name to variable.tf as a default or in terraform.tfvars)
//Navigate to lb.tf and uncomment the certificate_arn line in the aws_lb_listener.
//Then navigate to cdn.tf and uncomment the viewer_certificate block that uses the acm_certificate_arn, and remove the cloudfront_default_certificate line.
//Finally, run terraform apply to update the resources with the new certificate.

#resource "aws_acm_certificate" "main" {
#  domain_name       = var.domain_name
#  validation_method = "DNS"
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}

resource "aws_wafv2_web_acl" "main" {
  name        = "main-alb-waf"
  description = "Production WAF for ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-CommonRules"
    priority = 1
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-alb-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.web_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.connectivity_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "connectivity_sg" {
  name        = "connectivity-sg"
  description = "Security group for EICE and VPC Endpoints"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow inbound traffic from application tier"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
