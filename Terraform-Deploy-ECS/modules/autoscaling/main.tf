# Auto Scaling Target Configuration
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 20    # Maximum số lượng tasks
  min_capacity       = 2     # Minimum số lượng tasks (đảm bảo HA)
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = {
    Name        = "${var.service_name}-autoscaling-target"
    Environment = "production"
    Service     = var.service_name
  }
}

# 1. CPU Utilization Target Tracking Policy
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    
    target_value       = 70.0   # Target CPU 70%
    scale_out_cooldown = 120    # 5 phút cooldown khi scale out
    scale_in_cooldown  = 600    # 10 phút cooldown khi scale in
    disable_scale_in   = false  # Cho phép scale in
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# 2. Memory Utilization Target Tracking Policy
resource "aws_appautoscaling_policy" "memory_scaling" {
  name               = "${var.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    
    target_value       = 80.0   # Target Memory 80%
    scale_out_cooldown = 120    # 5 phút cooldown khi scale out
    scale_in_cooldown  = 600    # 10 phút cooldown khi scale in
    disable_scale_in   = false  # Cho phép scale in
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# CloudWatch Alarms for Monitoring
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.service_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Name        = "${var.service_name}-high-cpu-alarm"
    Environment = "production"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.service_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors ECS Memory utilization"
  alarm_actions       = [] # Add SNS topic ARN for notifications

  dimensions = {
    ServiceName = var.service_name
    ClusterName = var.cluster_name
  }

  tags = {
    Name        = "${var.service_name}-high-memory-alarm"
    Environment = "production"
  }
}