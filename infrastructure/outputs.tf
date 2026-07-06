output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.web_alb.dns_name
}

output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main_db.endpoint
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}