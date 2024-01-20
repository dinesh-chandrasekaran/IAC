resource "null_resource" "loadAverage_script" {
  triggers = {
    auto_scaling_group_name = var.auto_scaling_group_name
    aws_region              = var.region
    sns_topic_arn           = var.sns_topic_arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      (crontab -l 2>/dev/null; echo "*/5 * * * * ../../loadMonitor.sh ${var.auto_scaling_group_name} ${var.region} ${var.sns_topic_arn}") | crontab -
    EOT

  }
}

