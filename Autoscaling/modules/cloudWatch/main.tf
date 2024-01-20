resource "aws_launch_template" "jDoodle" {
  name                    = "jDoodle"
  image_id                = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
}

resource "aws_autoscaling_group" "jDoodle-asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  health_check_type    = "EC2"
  health_check_grace_period = 300
  force_delete         = true
  availability_zones = ["ap-southeast-2a"]

  launch_template {
    id      = aws_launch_template.jDoodle.id
  }

  tag {
    key                 = "Doodle-asg"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "asg-addNodes" {
  name                   = "add_nodes"
  scaling_adjustment    = 1
  cooldown              = 300
  adjustment_type       = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.jDoodle-asg.name
}

resource "aws_autoscaling_policy" "asg-delNodes" {
  name                   = "Delete_nodes"
  scaling_adjustment    = -1
  cooldown              = 300
  adjustment_type       = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.jDoodle-asg.name
}
