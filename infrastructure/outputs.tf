output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.web_alb.dns_name
}

output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main_db.endpoint
}