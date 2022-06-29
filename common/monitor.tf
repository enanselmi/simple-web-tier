resource "aws_sns_topic" "monitoring" {
  name = "test-alarm-sns"
}

#Crear suscripcion manualmente

resource "aws_sns_topic_policy" "monitoring" {
  arn    = aws_sns_topic.monitoring.arn
  policy = data.aws_iam_policy_document.monitoring_sns_topic_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "monitoring_sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__default_statement_ID"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = [aws_sns_topic.monitoring.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }

  statement {
    sid       = "Allow CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.monitoring.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_ssm_parameter" "windows_agent_config" {
  name  = "WindowsAgentConfig"
  type  = "String"
  value = file("../../common/data/WindowsAgentConfig.json")
}

resource "aws_cloudwatch_metric_alarm" "EC2_CPU_Usage_Alarm" {
  alarm_name          = "EC2_CPU_Usage_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu utilization exceeding 70%"
  ok_actions          = [aws_sns_topic.monitoring.arn]
  alarm_actions       = [aws_sns_topic.monitoring.arn]
}

resource "aws_cloudwatch_metric_alarm" "EC2_MEM_Usage_Alarm" {
  alarm_name          = "EC2_MEM_Usage_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "Memory % Committed Bytes In Use"
  namespace           = "MyWindowsServer"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 memory utilization exceeding 70%"
  ok_actions          = [aws_sns_topic.monitoring.arn]
  alarm_actions       = [aws_sns_topic.monitoring.arn]

  dimensions = {
    ImageId = "ami-041306c411c38a789"
  }
}

#FSx Alarm

# resource "aws_cloudwatch_metric_alarm" "FSx_Storage_Capacity_Alarm" {
#   alarm_name          = "FSx_Storage_Capacity_Alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "FreeStorageCapacity"
#   namespace           = "AWS/FSx"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "70"
#   alarm_description   = "This metric monitors FSx storage utilization exceeding 70%"
#   ok_actions          = [aws_sns_topic.monitoring.arn]
#   alarm_actions       = [aws_sns_topic.monitoring.arn]
# }
