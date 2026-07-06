resource "aws_sns_topic" "admin_notifications" {
  name = "admin-notifications-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.admin_notifications.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm" {
  alarm_name          = "web-server-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.admin_notifications.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "web_status_check_alarm" {
  alarm_name          = "web-server-status-check-fail"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_actions       = [aws_sns_topic.admin_notifications.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}