# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alerts"
  })
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  count = length(var.alert_email_addresses)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_addresses[count.index]
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.load_balancer_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Load Balancer Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", var.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Instance Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "${var.project_name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB response time"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "high_4xx_errors" {
  alarm_name          = "${var.project_name}-high-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors ALB 4xx errors"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  alarm_name          = "${var.project_name}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors ALB 5xx errors"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.project_name}-unhealthy-targets"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors healthy target count"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup  = var.target_group_name
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}
