output "autoscaling_group_name" {
  value = aws_autoscaling_group.jDoodle-asg.name
}

output "asg-addNodes_policy_arn" {
  value = aws_autoscaling_policy.asg-addNodes.arn
}

output "asg-delNodes_policy_arn" {
  value = aws_autoscaling_policy.asg-delNodes.arn
}
