resource "aws_sns_topic" "asg_event" {
  name = "asg_event_alert"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.asg_event.arn
  protocol  = "email"
  endpoint  = var.emailId
}

resource "aws_autoscaling_notification" "instance_event" {
  group_names       =  [var.autoscaling_group_name]
  topic_arn         = aws_sns_topic.asg_event.arn
  notifications = ["autoscaling:EC2_INSTANCE_LAUNCH", "autoscaling:EC2_INSTANCE_TERMINATE"]
}

#SNS Policy creation
data "aws_iam_policy_document" "sns_policy" {
statement {
    sid = "1"

    actions = [
      "SNS:CreateTopic",
      "SNS:SetTopicAttributes",
    ]

    resources = ["*"]
      
    
  }
}

resource "aws_iam_policy" "sns_policy" {
  name        = "SNSCreateTopicPolicy"
  policy = data.aws_iam_policy_document.sns_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_sns_policy" {
  role       = "ec2-terraform"
  policy_arn = aws_iam_policy.sns_policy.arn
}

